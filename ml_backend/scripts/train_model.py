import pandas as pd
import joblib

from pathlib import Path
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_FILE = BASE_DIR / "data" / "combined_hourly.csv"
MODEL_DIR = BASE_DIR / "models"
MODEL_DIR.mkdir(parents=True, exist_ok=True)

MODEL_FILE = MODEL_DIR / "aqi_next_hour_model.joblib"

def main():
    df = pd.read_csv(DATA_FILE, parse_dates=["time"])
    df = df.sort_values("time").reset_index(drop=True)

    # Sirf observed AQI rows use karo
    df = df.dropna(subset=["us_aqi"]).copy()

    df["hour"] = df["time"].dt.hour
    df["day_of_week"] = df["time"].dt.dayofweek
    df["month"] = df["time"].dt.month

    # Target: aglay ghantay ka AQI
    df["target_next_hour"] = df["us_aqi"].shift(-1)

    feature_cols = [
        "us_aqi",
        "temperature_2m",
        "relative_humidity_2m",
        "precipitation",
        "cloud_cover",
        "wind_speed_10m",
        "pressure_msl",
        "hour",
        "day_of_week",
        "month",
    ]

    df = df.dropna(subset=feature_cols + ["target_next_hour"])

    X = df[feature_cols]
    y = df["target_next_hour"]

    split_index = int(len(df) * 0.8)

    X_train = X.iloc[:split_index]
    X_test = X.iloc[split_index:]
    y_train = y.iloc[:split_index]
    y_test = y.iloc[split_index:]

    model = RandomForestRegressor(
        n_estimators=200,
        max_depth=8,
        min_samples_leaf=5,
        random_state=42,
        n_jobs=-1,
    )

    print("Training next-hour AQI model...")
    model.fit(X_train, y_train)

    predictions = model.predict(X_test)

    # Baseline: next-hour AQI = current-hour AQI
    baseline_predictions = X_test["us_aqi"].to_numpy()

    print("\n--- Baseline: current AQI ---")
    print(f"MAE: {mean_absolute_error(y_test, baseline_predictions):.2f}")
    print(f"RMSE: {mean_squared_error(y_test, baseline_predictions) ** 0.5:.2f}")
    print(f"R2: {r2_score(y_test, baseline_predictions):.3f}")

    print("\n--- Random Forest ---")
    print(f"MAE: {mean_absolute_error(y_test, predictions):.2f}")
    print(f"RMSE: {mean_squared_error(y_test, predictions) ** 0.5:.2f}")
    print(f"R2: {r2_score(y_test, predictions):.3f}")

    joblib.dump(
        {
            "model": model,
            "features": feature_cols,
            "target": "next_hour_us_aqi",
        },
        MODEL_FILE,
    )

    print("\nModel saved to:", MODEL_FILE)
    print("Training rows:", len(X_train))
    print("Testing rows:", len(X_test))

if __name__ == "__main__":
    main()
