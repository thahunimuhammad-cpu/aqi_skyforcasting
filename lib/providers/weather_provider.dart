import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherProvider extends ChangeNotifier {
  int _selectedCityIndex = 0;
  final List<String> _cities = ['Lahore', 'Karachi', 'Islamabad', 'Peshawar'];

  WeatherModel _currentCityWeather = const WeatherModel(
    cityName: 'Lahore',
    aqi: 184,
    status: 'Unhealthy',
    humidity: '62%',
    wind: '8 km/h',
  );

  int get selectedCityIndex => _selectedCityIndex;
  List<String> get cities => _cities;
  WeatherModel get currentCityWeather => _currentCityWeather;

  void selectCity(int index) {
    _selectedCityIndex = index;
    _currentCityWeather = WeatherModel(
      cityName: _cities[index],
      aqi: 150 + (index * 12),
      status: 'Unhealthy',
      humidity: '${60 + index}%',
      wind: '${8 + index} km/h',
    );
    notifyListeners();
  }
}