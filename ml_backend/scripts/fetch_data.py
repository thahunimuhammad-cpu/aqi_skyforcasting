
import requests
import pandas as pd
from pathlib import Path

# Lahore, Pakistan
LATITUDE = 31.5204
LONGITUDE = 74.3587
TIMEZONE = "Asia/Karachi"

# Project folders
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
DATA_DIR.mkdir(parents=True, exist_ok=True)


def fetch_json(url, params):
    response = requests.get(url, params=params, timeout=60)
    response.raise_for_status()
    return response.json()


def main():
    # 1. Weather data
    weather_url = "https://api.open-meteo.com/v1/forecast"

    weather_params = {
        "latitude": LATITUDE,
        "longitude": LONGITUDE,
        "timezone": TIMEZONE,
        "past_days": 30,
        "forecast_days": 7,
        "hourly": [
            "temperature_2m",
            "relative_humidity_2m",
            "precipitation",
            "cloud_cover",
            "wind_speed_10m",
            "pressure_msl",
        ],
        "daily": [
            "temperature_2m_max",
            "temperature_2m_min",
            "precipitation_sum",
            "wind_speed_10m_max",
        ],
    }

    weather = fetch_json(weather_url, weather_params)

    weather_df = pd.DataFrame(weather["hourly"])
    weather_df["time"] = pd.to_datetime(weather_df["time"])

    weather_df.to_csv(DATA_DIR / "weather_hourly.csv", index=False)

    daily_df = pd.DataFrame(weather["daily"])
    daily_df.to_csv(DATA_DIR / "weather_daily.csv", index=False)

    print("Weather rows:", len(weather_df))

    # 2. Air-quality data
    aqi_url = "https://air-quality-api.open-meteo.com/v1/air-quality"

    aqi_params = {
        "latitude": LATITUDE,
        "longitude": LONGITUDE,
        "timezone": TIMEZONE,
        "past_days": 30,
        "forecast_days": 7,
        "hourly": [
            "pm2_5",
            "pm10",
            "nitrogen_dioxide",
            "ozone",
            "us_aqi",
        ],
    }

    air = fetch_json(aqi_url, aqi_params)

    aqi_df = pd.DataFrame(air["hourly"])
    aqi_df["time"] = pd.to_datetime(aqi_df["time"])

    aqi_df.to_csv(DATA_DIR / "aqi_hourly.csv", index=False)

    print("Air-quality rows:", len(aqi_df))

    # 3. Merge by local timestamp
    combined = pd.merge(
        weather_df,
        aqi_df,
        on="time",
        how="inner",
        validate="one_to_one",
    )

    combined = combined.sort_values("time")
    combined.to_csv(DATA_DIR / "combined_hourly.csv", index=False)

    print("\nCombined dataset shape:", combined.shape)
    print("\nMissing values:")
    print(combined.isna().sum())
    print("\nLatest rows:")
    print(combined.tail())
    print("\nCSV files saved to:", DATA_DIR)


if __name__ == "__main__":
    main()
