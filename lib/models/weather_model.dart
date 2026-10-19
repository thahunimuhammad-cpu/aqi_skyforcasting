
class WeatherModel {
  final String cityName;

  // WeatherAPI US EPA index: 1 to 6; this is not a 0–500 AQI value.
  final int aqi;

  final String status;
  final String humidity;
  final String wind;

  const WeatherModel({
    required this.cityName,
    required this.aqi,
    required this.status,
    required this.humidity,
    required this.wind,
  });

  String get aqiCategory {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Moderate';
      case 3:
        return 'Unhealthy for Sensitive Groups';
      case 4:
        return 'Unhealthy';
      case 5:
        return 'Very Unhealthy';
      case 6:
        return 'Hazardous';
      default:
        return 'Unavailable';
    }
  }
}
