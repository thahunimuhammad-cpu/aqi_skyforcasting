from pathlib import Path

import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import requests
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

BASE_DIR = Path(__file__).resolve().parent.parent
MODEL_PATH = BASE_DIR / "models" / "aqi_next_hour_model.joblib"

saved = joblib.load(MODEL_PATH)
model = saved["model"]
features = saved["features"]

app = FastAPI(title="AQI Forecast API", version="1.0.0")


class PredictionInput(BaseModel):
    us_aqi: float = Field(ge=0, le=1000)
    temperature_2m: float
    relative_humidity_2m: float = Field(ge=0, le=100)
    precipitation: float = Field(ge=0)
    cloud_cover: float = Field(ge=0, le=100)
    wind_speed_10m: float = Field(ge=0)
    pressure_msl: float = Field(gt=0)
    hour: int = Field(ge=0, le=23)
    day_of_week: int = Field(ge=0, le=6)
    month: int = Field(ge=1, le=12)


@app.get("/")
def root():
    return {"message": "AQI Forecast API is running"}


@app.get("/health")
def health():
    return {"status": "ok", "model": "aqi_next_hour_model"}


@app.post("/predict/next-hour")
def predict_next_hour(data: PredictionInput):
    try:
        row = pd.DataFrame(
            [[getattr(data, name) for name in features]],
            columns=features,
        )
        prediction = float(model.predict(row)[0])

        return {
            "predicted_aqi": round(max(0, prediction), 2),
            "forecast_horizon": "next_hour",
            "model": "RandomForestRegressor",
            "note": "Experimental estimate; not for medical decisions.",
        }
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))
@app.get("/predict/live-next-hour")
def predict_live_next_hour():
    latitude = 31.5204
    longitude = 74.3587
    timezone = "Asia/Karachi"

    weather_url = "https://api.open-meteo.com/v1/forecast"
    air_url = "https://air-quality-api.open-meteo.com/v1/air-quality"

    weather_params = {
        "latitude": latitude,
        "longitude": longitude,
        "timezone": timezone,
        "past_days": 1,
        "forecast_days": 2,
        "hourly": [
            "temperature_2m",
            "relative_humidity_2m",
            "precipitation",
            "cloud_cover",
            "wind_speed_10m",
            "pressure_msl",
        ],
    }

    air_params = {
        "latitude": latitude,
        "longitude": longitude,
        "timezone": timezone,
        "past_days": 1,
        "forecast_days": 2,
        "hourly": ["us_aqi"],
    }

    try:
        weather_response = requests.get(
            weather_url, params=weather_params, timeout=30
        )
        weather_response.raise_for_status()
        weather = weather_response.json()["hourly"]

        air_response = requests.get(
            air_url, params=air_params, timeout=30
        )
        air_response.raise_for_status()
        air = air_response.json()["hourly"]

        weather_df = pd.DataFrame(weather)
        air_df = pd.DataFrame(air)

        df = pd.merge(weather_df, air_df, on="time", how="inner")
        df["time"] = pd.to_datetime(df["time"])
        df["hour"] = df["time"].dt.hour
        df["day_of_week"] = df["time"].dt.dayofweek
        df["month"] = df["time"].dt.month

        now = datetime.now(ZoneInfo(timezone))
        current_hour = now.replace(
            minute=0, second=0, microsecond=0, tzinfo=None
        )

        required = features
        valid = df[
            (df["time"] <= current_hour)
            & df[required].notna().all(axis=1)
        ].sort_values("time")

        if valid.empty:
            raise HTTPException(
                status_code=503,
                detail="No complete hourly weather and AQI data available."
            )

        latest = valid.iloc[-1]
        input_time = latest["time"]

        row = pd.DataFrame(
            [[latest[name] for name in features]],
            columns=features,
        )

        prediction = float(model.predict(row)[0])

        return {
            "location": "Lahore, Pakistan",
            "input_data_time": input_time.isoformat(),
            "forecast_for": (
                input_time + timedelta(hours=1)
            ).isoformat(),
            "current_aqi": round(float(latest["us_aqi"]), 2),
            "predicted_aqi": round(max(0, prediction), 2),
            "forecast_horizon": "next_hour",
            "source": "Open-Meteo hourly data",
            "note": (
                "Experimental estimate, not a verified observation "
                "or medical guidance."
            ),
        }

    except HTTPException:
        raise
    except requests.RequestException as exc:
        raise HTTPException(
            status_code=502,
            detail=f"Weather/AQI data service error: {exc}",
        )
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))

