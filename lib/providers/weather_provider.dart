
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherProvider extends ChangeNotifier {
  int _selectedCityIndex = 0;

  final List<String> _cities = [
    'Lahore',
    'Karachi',
    'Islamabad',
    'Peshawar',
  ];

  WeatherModel? _currentCityWeather;
  bool _isLoading = false;
  String? _errorMessage;

  int get selectedCityIndex => _selectedCityIndex;
  List<String> get cities => _cities;
  WeatherModel? get currentCityWeather => _currentCityWeather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Apni nayi WeatherAPI key yahan enter karein.
  static const String apiKey = '083c6efc83bf444e80481539262708';

  WeatherProvider() {
    fetchWeatherForCity('Lahore');
  }

  Future<void> fetchWeatherForCity(String cityName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final url = Uri.https(
      'api.weatherapi.com',
      '/v1/current.json',
      {
        'key': apiKey,
        'q': cityName,
        'aqi': 'yes',
      },
    );

    try {
      final response = await http.get(url);

      debugPrint('Weather status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final location = data['location'];
        final current = data['current'];
        final condition = current['condition'];
        final airQuality = current['air_quality'];

        _currentCityWeather = WeatherModel(
          cityName: location['name'] ?? cityName,

          // WeatherAPI ka US EPA AQI index
          aqi: airQuality?['us-epa-index'] != null
              ? (airQuality['us-epa-index'] as num).toInt()
              : 0,

          status: condition['text'] ?? 'Unknown',
          humidity: '${current['humidity']}%',
          wind: '${current['wind_kph']} km/h',
        );

        debugPrint('Weather loaded for: ${location['name']}');
      } else {
        debugPrint('Weather response: ${response.body}');
        _errorMessage = 'Failed to load weather data '
            '(${response.statusCode})';
      }
    } catch (e, stackTrace) {
      debugPrint('Weather fetch error: $e');
      debugPrint('$stackTrace');
      _errorMessage = 'Weather fetch failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCity(int index) {
    if (index < 0 || index >= _cities.length) return;

    _selectedCityIndex = index;
    fetchWeatherForCity(_cities[index]);
  }
}
