class ScanHistoryModel {
  final String id;
  final String location;
  final int aqi;
  final String pm25Text;
  final String date;
  final String imagePath;

  const ScanHistoryModel({
    required this.id,
    required this.location,
    required this.aqi,
    required this.pm25Text,
    required this.date,
    required this.imagePath,
  });
}