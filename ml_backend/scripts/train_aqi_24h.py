
from pathlib import Path

import joblib
import numpy as np
import pandas as pd

from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import (
    mean_absolute_error,
    mean_squared_error,
    r2_score,
)

# --------------------------------------------------
# 1. PATHS AND CONFIGURATION
# --------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent.parent

DATA_FILE = BASE_DIR / "data" / "combined_hourly.csv"
MODEL_DIR = BASE_DIR / "models"
MODEL_FILE = MODEL_DIR / "aqi_24h_model.joblib"

HORIZON = 24
TEST_RATIO = 0.20
GAP_HOURS = 24

WEATHER_FEATURES = [
    "temperature_2m",
    "relative_humidity_2m",
    "precipitation",
    "cloud_cover",
    "wind_speed_10m",
    "pressure_msl",
]

LAG_HOURS = [1, 3, 6, 12, 24]
ROLLING_WINDOWS = [6, 24]


# --------------------------------------------------
# 2. LOAD AND VALIDATE DATA
# --------------------------------------------------

def load_data():
    if not DATA_FILE.exists():
        raise FileNotFoundError(
            f"Dataset not found: {DATA_FILE}"
        )

    df = pd.read_csv(DATA_FILE, parse_dates=["time"])

    required_columns = ["time", "us_aqi"] + WEATHER_FEATURES
    missing_columns = [
        col for col in required_columns
        if col not in df.columns
    ]

    if missing_columns:
        raise ValueError(
            f"Missing dataset columns: {missing_columns}"
        )

    df = df.sort_values("time").reset_index(drop=True)

    if df["time"].isna().any():
        raise ValueError("Dataset contains invalid timestamps.")

    if df["time"].duplicated().any():
        raise ValueError(
            "Duplicate timestamps found. Clean the dataset first."
        )

    # Future forecast rows ko historical training se exclude karo.
    now = pd.Timestamp.now().floor("h")
    df = df.loc[df["time"] <= now].copy()
    df = df.reset_index(drop=True)

    if len(df) == 0:
        raise ValueError(
            "No historical rows found before the current time."
        )

    # Lag aur target shifts tabhi hourly meaning rakhte hain
    # jab har consecutive timestamp mein 1 hour ka difference ho.
    time_gaps = df["time"].diff().dropna()

    if not time_gaps.eq(pd.Timedelta(hours=1)).all():
        raise ValueError(
            "Hourly timestamps mein gaps hain. "
            "Missing hours ko investigate karke data clean karo."
        )

    # Invalid negative AQI values ko missing samjho.
    df["us_aqi"] = pd.to_numeric(
        df["us_aqi"], errors="coerce"
    )
    df.loc[df["us_aqi"] < 0, "us_aqi"] = np.nan

    # Numeric weather columns ensure karo.
    for col in WEATHER_FEATURES:
        df[col] = pd.to_numeric(
            df[col], errors="coerce"
        )

    print("Historical rows:", len(df))
    print("First timestamp:", df["time"].min())
    print("Last timestamp:", df["time"].max())
    print("Missing AQI values:", df["us_aqi"].isna().sum())

    return df


# --------------------------------------------------
# 3. FEATURE ENGINEERING
# --------------------------------------------------

def create_features(df):
    df = df.copy()

    # Calendar features
    df["hour"] = df["time"].dt.hour
    df["day_of_week"] = df["time"].dt.dayofweek
    df["month"] = df["time"].dt.month

    # Past AQI values. shift() preserves missing hours as NaN;
    # we do not drop missing AQI rows before creating lags.
    for lag in LAG_HOURS:
        df[f"aqi_lag_{lag}h"] = df["us_aqi"].shift(lag)

    # Rolling averages of past observations only.
    # shift(1) prevents the current AQI from entering the mean.
    past_aqi = df["us_aqi"].shift(1)

    for window in ROLLING_WINDOWS:
        df[f"aqi_rolling_mean_{window}h"] = (
            past_aqi
            .rolling(window=window, min_periods=window)
            .mean()
        )

    # Target: AQI exactly 24 rows / hours in the future.
    df["target_aqi_24h"] = df["us_aqi"].shift(-HORIZON)

    feature_columns = (
        WEATHER_FEATURES
        + ["hour", "day_of_week", "month"]
        + [f"aqi_lag_{lag}h" for lag in LAG_HOURS]
        + [
            f"aqi_rolling_mean_{window}h"
            for window in ROLLING_WINDOWS
        ]
    )

    # Require all input features and future target to be available.
    # Missing AQI values are not filled with invented values.
    model_df = df.dropna(
        subset=feature_columns + ["target_aqi_24h"]
    ).copy()

    return model_df, feature_columns


# --------------------------------------------------
# 4. CHRONOLOGICAL SPLIT WITH 24-HOUR GAP
# --------------------------------------------------

def split_data(df):
    if len(df) < 150:
        raise ValueError(
            f"Only {len(df)} usable samples. "
            "Collect more historical data before evaluating."
        )

    split_index = int(len(df) * (1 - TEST_RATIO))

    # The 24 samples immediately after training are excluded.
    # This ensures training targets finish before test input times.
    test_start = split_index + GAP_HOURS

    train_df = df.iloc[:split_index].copy()
    test_df = df.iloc[test_start:].copy()

    if len(train_df) == 0 or len(test_df) < 10:
        raise ValueError(
            "Not enough data after applying the 24-hour gap."
        )

    # Verify that the last training target is earlier than
    # the first test input timestamp.
    last_train_target_time = (
        train_df["time"] + pd.Timedelta(hours=HORIZON)
    ).max()

    first_test_input_time = test_df["time"].min()

    if last_train_target_time >= first_test_input_time:
        raise ValueError(
            "Training target period overlaps the test input period."
        )

    return train_df, test_df


# --------------------------------------------------
# 5. TRAIN AND EVALUATE
# --------------------------------------------------

def main():
    df = load_data()
    model_df, feature_columns = create_features(df)

    train_df, test_df = split_data(model_df)

    X_train = train_df[feature_columns]
    y_train = train_df["target_aqi_24h"]

    X_test = test_df[feature_columns]
    y_test = test_df["target_aqi_24h"]

    print("\nUsable samples:", len(model_df))
    print("Training samples:", len(train_df))
    print("Testing samples:", len(test_df))
    print("Gap between train and test input rows:", GAP_HOURS)
    print("Last training input:", train_df["time"].max())
    print("First testing input:", test_df["time"].min())
    print("Features:", len(feature_columns))

    model = RandomForestRegressor(
        n_estimators=300,
        max_depth=8,
        min_samples_leaf=5,
        max_features=0.8,
        random_state=42,
        n_jobs=-1,
    )

    print("\nTraining improved 24-hour AQI model...")
    model.fit(X_train, y_train)

    predictions = model.predict(X_test)

    # Baseline: predict that AQI 24 hours later equals current AQI.
    baseline = test_df["us_aqi"].to_numpy()

    # Also compare against the AQI observed 24 hours before
    # the prediction time, when available.
    previous_day = test_df["aqi_lag_24h"].to_numpy()

    print("\n--- Persistence baseline: current AQI ---")
    print(f"MAE:  {mean_absolute_error(y_test, baseline):.2f}")
    print(
        f"RMSE: {mean_squared_error(y_test, baseline) ** 0.5:.2f}"
    )

    print("\n--- Previous-day baseline: AQI 24h ago ---")
    print(f"MAE:  {mean_absolute_error(y_test, previous_day):.2f}")
    print(
        f"RMSE: {mean_squared_error(y_test, previous_day) ** 0.5:.2f}"
    )

    print("\n--- Improved Random Forest ---")
    print(f"MAE:  {mean_absolute_error(y_test, predictions):.2f}")
    print(
        f"RMSE: {mean_squared_error(y_test, predictions) ** 0.5:.2f}"
    )
    print(f"R2:   {r2_score(y_test, predictions):.3f}")

    # Show some real test predictions.
    report = pd.DataFrame({
        "input_time": test_df["time"].to_numpy(),
        "target_time": (
            test_df["time"] + pd.Timedelta(hours=HORIZON)
        ).to_numpy(),
        "actual_aqi_24h": y_test.to_numpy(),
        "predicted_aqi_24h": np.round(predictions, 2),
        "current_aqi": test_df["us_aqi"].to_numpy(),
    })

    print("\n--- Sample predictions ---")
    print(report.head(15).to_string(index=False))

    # Save the model and exact feature order for API integration.
    MODEL_DIR.mkdir(parents=True, exist_ok=True)

    joblib.dump(
        {
            "model": model,
            "features": feature_columns,
            "target": "us_aqi_24_hours_ahead",
            "horizon_hours": HORIZON,
            "model_type": "RandomForestRegressor",
        },
        MODEL_FILE,
    )

    print("\nModel saved to:", MODEL_FILE)
    print("Training completed.")


if __name__ == "__main__":
    main()
