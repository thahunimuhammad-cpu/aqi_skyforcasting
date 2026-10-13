import 'package:flutter/material.dart';
import '../models/scan_history_model.dart';

class ScanHistoryProvider extends ChangeNotifier {
  final List<ScanHistoryModel> _historyList = [
    const ScanHistoryModel(
      id: 'scan_1',
      location: 'Mall Road, Lahore',
      aqi: 172,
      pm25Text: 'PM2.5: 118 µg/m³',
      date: 'Yesterday, 4:15 PM',
      imagePath: '',
    ),
  ];

  List<ScanHistoryModel> get historyList => List.unmodifiable(_historyList);

  void addScan(ScanHistoryModel scan) {
    _historyList.insert(0, scan);
    notifyListeners();
  }
}