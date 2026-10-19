import pandas as pd
from pathlib import Path

path = Path("data/combined_hourly.csv")
df = pd.read_csv(path, parse_dates=["time"])

aqi_cols = ["pm2_5", "pm10", "nitrogen_dioxide", "ozone", "us_aqi"]

print("Dataset start:", df["time"].min())
print("Dataset end:", df["time"].max())
print("\nMissing values:")
print(df[aqi_cols].isna().sum())

print("\nFirst valid AQI timestamp:")
print(df.loc[df["us_aqi"].notna(), "time"].min())

print("\nLast valid AQI timestamp:")
print(df.loc[df["us_aqi"].notna(), "time"].max())

print("\nRows with all AQI values missing:")
print(df[aqi_cols].isna().all(axis=1).sum())

print("\nRows available for AQI training:")
print(df["us_aqi"].notna().sum())
