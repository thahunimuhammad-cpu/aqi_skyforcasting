class WeatherModel {
  final String cityName;
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
}