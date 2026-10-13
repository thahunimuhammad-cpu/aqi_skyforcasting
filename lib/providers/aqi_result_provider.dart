import 'package:flutter/material.dart';
import '../models/aqi_result_model.dart';

class AqiResultProvider extends ChangeNotifier {
  AqiResultModel? _currentResult;

  AqiResultModel? get currentResult => _currentResult;

  void generateAnalysisResult({required String location}) {
    _currentResult = AqiResultModel(
      location: location,
      pm25: 142,
      aqi: 195,
      status: 'Unhealthy',
      humidity: '62%',
      wind: '8 km/h',
      time: '3:15 PM',
      urduAdvice: 'بچوں، دمہ کے مریضوں اور باہر کام کرنے والے افراد کو کھلی فضا میں سرگرمیوں سے گریز اور ماسک کا استعمال کرنا چاہیے۔',
      englishAdvice: 'Sensitive groups, children & outdoor workers should wear N95 masks and limit prolonged outdoor exertion.',
    );
    notifyListeners();
  }
}