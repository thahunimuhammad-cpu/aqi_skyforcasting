import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aqi_forcasting/providers/auth_provider.dart';
import 'package:aqi_forcasting/providers/sky_aqi_provider.dart';
import 'package:aqi_forcasting/providers/aqi_result_provider.dart';
import 'package:aqi_forcasting/providers/scan_history_provider.dart';
import 'package:aqi_forcasting/providers/weather_provider.dart';
import 'package:aqi_forcasting/screens/splash_screen/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SkyAqiProvider()),
        ChangeNotifierProvider(create: (_) => AqiResultProvider()),
        ChangeNotifierProvider(create: (_) => ScanHistoryProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkyAQI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const SkyAqiSplashScreen(),
    );
  }
}