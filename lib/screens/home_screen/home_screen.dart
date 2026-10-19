import 'package:aqi_forcasting/providers/sky_aqi_provider.dart';
import 'package:aqi_forcasting/providers/weather_provider.dart';
import 'package:aqi_forcasting/screens/photos_screen/photos.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:aqi_forcasting/widgets/aqi_forecast_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color _navy = Color(0xFF0A2A5E);
  static const Color _blue = Color(0xFF1565C0);
  static const Color _sky = Color(0xFF4DA3F0);
  static const Color _bg = Color(0xFFF1F7FD);
  static const Color _textMuted = Color(0xFF6B7F99);

  Future<void> _handleImageSelection(
    BuildContext context,
    ImageSource source,
  ) async {
    final provider = context.read<SkyAqiProvider>();
    bool success = await provider.pickSkyPhoto(source);

    if (success && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PhotoPreviewScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          'AQI Smog Forecasting',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_navy, _blue],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Weather Card Section
             // home_screen.dart me Consumer<WeatherProvider> component:
Consumer<WeatherProvider>(
  builder: (context, weatherProv, child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Field Widget
         // home_screen.dart me Consumer<WeatherProvider> component:
Consumer<WeatherProvider>(
  builder: (context, weatherProv, child) {
    final TextEditingController searchController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Field Widget
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search city (e.g. Multan, London)...',
              hintStyle: const TextStyle(color: _textMuted, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: _blue),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward, color: _navy),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  weatherProv.fetchWeatherForCity(searchController.text);
                },
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: _bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) {
              weatherProv.fetchWeatherForCity(value);
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: weatherProv.isLoading
                  ? null
                  : weatherProv.fetchWeatherForCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Use current location'),
            ),
          ),
          const Divider(height: 24),
          if (weatherProv.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (weatherProv.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                weatherProv.errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            )
          else if (weatherProv.currentCityWeather != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weatherProv.currentCityWeather!.cityName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _navy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${weatherProv.currentCityWeather!.status}',
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'AQI: ${weatherProv.currentCityWeather!.aqi}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Humidity: ${weatherProv.currentCityWeather!.humidity} | Wind: ${weatherProv.currentCityWeather!.wind}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _textMuted,
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  },
),
          const Divider(height: 24),
          if (weatherProv.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (weatherProv.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                weatherProv.errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            )
          else if (weatherProv.currentCityWeather != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weatherProv.currentCityWeather!.cityName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _navy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${weatherProv.currentCityWeather!.status}',
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'AQI: ${weatherProv.currentCityWeather!.aqi}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Humidity: ${weatherProv.currentCityWeather!.humidity} | Wind: ${weatherProv.currentCityWeather!.wind}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _textMuted,
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  },
),
              const SizedBox(height: 24),

              const SizedBox(height: 20),
              const AqiForecastCard(),
              const SizedBox(height: 24),

              // Hero card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_navy, _blue, _sky],
                    stops: [0.0, 0.55, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: _blue.withValues(alpha: 0.30),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.35),
                            Colors.white.withValues(alpha: 0.12),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.45),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.cloud,
                        size: 58,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Sky Air Quality Check',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Take a photo of the sky or select an image from your gallery to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Map Section
              Container(
                height: 220,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Consumer<WeatherProvider>(
                  builder: (context, weatherProv, child) {
                    final position = weatherProv.currentPosition;
                    final location = position == null
                        ? null
                        : LatLng(position.latitude, position.longitude);

                    if (location == null) {
                      return Center(
                        child: Text(
                          weatherProv.isLoading
                              ? 'Getting your current location...'
                              : 'Current location is not available.',
                          style: const TextStyle(color: _textMuted),
                        ),
                      );
                    }

                    return GoogleMap(
                      key: ValueKey(
                        '${location.latitude},${location.longitude}',
                      ),
                      initialCameraPosition: CameraPosition(
                        target: location,
                        zoom: 12,
                      ),
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      markers: {
                        Marker(
                          markerId: const MarkerId('current_location'),
                          position: location,
                          infoWindow: InfoWindow(
                            title: weatherProv.currentCityWeather?.cityName ??
                                'Current location',
                          ),
                        ),
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Camera Button
              Consumer<SkyAqiProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton.icon(
                    onPressed: provider.isPickingImage
                        ? null
                        : () => _handleImageSelection(
                            context,
                            ImageSource.camera,
                          ),
                    icon: const Icon(Icons.camera_alt, size: 20),
                    label: const Text('Take Sky Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: _blue.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Gallery Button
              Consumer<SkyAqiProvider>(
                builder: (context, provider, child) {
                  return OutlinedButton.icon(
                    onPressed: provider.isPickingImage
                        ? null
                        : () => _handleImageSelection(
                            context,
                            ImageSource.gallery,
                          ),
                    icon: const Icon(Icons.photo_library, size: 20),
                    label: const Text('Choose from Gallery'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _blue,
                      side: BorderSide(
                        color: _blue.withValues(alpha: 0.5),
                        width: 1.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // View History
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PhotoPreviewScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.history, size: 20),
                label: const Text('View History'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _navy,
                  side: BorderSide(
                    color: _navy.withValues(alpha: 0.2),
                    width: 1.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Footer Note
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _blue.withValues(alpha: 0.15)),
                ),
                child: const Text(
                  'Note: Image preview is available. AQI prediction and photo history storage require additional implementation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: _textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}