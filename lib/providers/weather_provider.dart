import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherProvider extends ChangeNotifier with WidgetsBindingObserver {
  int _selectedCityIndex = 0;

  final List<String> _cities = ['Lahore', 'Karachi', 'Islamabad', 'Peshawar'];

  WeatherModel? _currentCityWeather;
  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;

  int get selectedCityIndex => _selectedCityIndex;
  List<String> get cities => _cities;
  WeatherModel? get currentCityWeather => _currentCityWeather;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Apni nayi WeatherAPI key yahan enter karein.
  static const String apiKey = '083c6efc83bf444e80481539262708';

  WeatherProvider() {
    WidgetsBinding.instance.addObserver(this);
    fetchWeatherForCurrentLocation();
  }

  bool _refreshLocationOnResume = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _refreshLocationOnResume = true;
    } else if (state == AppLifecycleState.resumed && _refreshLocationOnResume) {
      _refreshLocationOnResume = false;
      fetchWeatherForCurrentLocation();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> fetchWeatherForCity(String cityName) async {
    final query = cityName.trim();
    if (query.isEmpty) {
      _errorMessage = 'Please enter a city name.';
      notifyListeners();
      return;
    }
    await _fetchWeather(query, fallbackCityName: query);
  }

  Future<void> fetchWeatherForCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _errorMessage = 'Turn on location services to see your local AQI.';
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _errorMessage = 'Location permission was denied.';
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permission is disabled. Allow it in your device settings.';
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      notifyListeners();

      await _fetchWeather(
        '${_currentPosition!.latitude},${_currentPosition!.longitude}',
        fallbackCityName: 'Current location',
      );
    } catch (e, stackTrace) {
      debugPrint('Current location error: $e');
      debugPrint('$stackTrace');
      _errorMessage = 'Could not get your current location: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchWeather(
    String query, {
    required String fallbackCityName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final url = Uri.https('api.weatherapi.com', '/v1/current.json', {
      'key': apiKey,
      'q': query,
      'aqi': 'yes',
    });

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
          cityName: location['name'] ?? fallbackCityName,

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
        _errorMessage =
            'Failed to load weather data '
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
