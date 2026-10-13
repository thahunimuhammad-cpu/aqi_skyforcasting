class AqiResultModel {
  final String location;
  final int pm25;
  final int aqi;
  final String status;
  final String humidity;
  final String wind;
  final String time;
  final String urduAdvice;
  final String englishAdvice;

  const AqiResultModel({
    required this.location,
    required this.pm25,
    required this.aqi,
    required this.status,
    required this.humidity,
    required this.wind,
    required this.time,
    required this.urduAdvice,
    required this.englishAdvice,
  });
}