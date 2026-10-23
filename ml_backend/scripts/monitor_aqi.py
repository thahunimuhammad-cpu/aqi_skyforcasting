
import json
import os
import time
from pathlib import Path

import requests
import firebase_admin
from firebase_admin import credentials, messaging


API_URL = (
    "http://127.0.0.1:8000/"
    "predict/live-next-hour?city=lahore"
)

CHECK_INTERVAL_SECONDS = 600  # 10 minutes
AQI_CHANGE_THRESHOLD = 10

STATE_FILE = Path(__file__).resolve().parent / "aqi_state.json"


def initialize_firebase():
    if firebase_admin._apps:
        return

    credentials_path = os.environ.get(
        "GOOGLE_APPLICATION_CREDENTIALS"
    )

    if not credentials_path:
        raise RuntimeError(
            "Set GOOGLE_APPLICATION_CREDENTIALS "
            "to your Firebase service-account JSON path."
        )

    firebase_admin.initialize_app(
        credentials.Certificate(credentials_path)
    )


def fetch_aqi():
    response = requests.get(API_URL, timeout=30)
    response.raise_for_status()

    data = response.json()

    current_aqi = float(data["current_aqi"])
    predicted_aqi = float(data["predicted_aqi"])

    return current_aqi, predicted_aqi, data.get("location", "Unknown")


def load_state():
    if not STATE_FILE.exists():
        return None

    with STATE_FILE.open("r", encoding="utf-8") as file:
        return json.load(file)


def save_state(state):
    with STATE_FILE.open("w", encoding="utf-8") as file:
        json.dump(state, file, indent=2)


def send_notification(old_aqi, new_aqi, location):
    direction = "increased" if new_aqi > old_aqi else "decreased"

    message = messaging.Message(
        topic="aqi_alerts",
        notification=messaging.Notification(
            title=f"AQI Forecast Update — {location}",
            body=(
                f"Next-hour predicted AQI {direction} "
                f"from {old_aqi:.0f} to {new_aqi:.0f}. "
                "This is an experimental forecast estimate."
            ),
        ),
        data={
            "type": "aqi_forecast_update",
            "old_aqi": str(round(old_aqi)),
            "predicted_aqi": str(round(new_aqi)),
            "location": location,
        },
    )

    return messaging.send(message)


def monitor_once():
    current_aqi, predicted_aqi, location = fetch_aqi()

    print(f"\nLocation: {location}")
    print(f"Current AQI: {current_aqi}")
    print(f"Predicted next-hour AQI: {predicted_aqi}")

    state = load_state()

    # First run: save a baseline, but don't send an alert.
    if state is None:
        save_state({
            "last_notified_predicted_aqi": predicted_aqi,
            "latest_current_aqi": current_aqi,
            "latest_predicted_aqi": predicted_aqi,
        })
        print("Baseline saved. No notification on first run.")
        return

    old_aqi = float(state["last_notified_predicted_aqi"])
    difference = abs(predicted_aqi - old_aqi)

    print(f"Change from notification baseline: {difference:.1f}")

    if difference >= AQI_CHANGE_THRESHOLD:
        # Save new baseline only after FCM accepts the message.
        message_id = send_notification(
            old_aqi, predicted_aqi, location
        )

        state["last_notified_predicted_aqi"] = predicted_aqi
        print("FCM notification accepted:", message_id)
    else:
        print("Change below threshold; no notification.")

    state["latest_current_aqi"] = current_aqi
    state["latest_predicted_aqi"] = predicted_aqi
    save_state(state)


def main():
    initialize_firebase()
    print("AQI monitoring started. Press Ctrl+C to stop.")

    while True:
        try:
            monitor_once()
        except Exception as error:
            print("Monitoring error:", error)

        time.sleep(CHECK_INTERVAL_SECONDS)


if __name__ == "__main__":
    main()
