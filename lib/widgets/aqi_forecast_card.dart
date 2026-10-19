
import 'package:flutter/material.dart';
import '../services/aqi_api_service.dart';

class AqiForecastCard extends StatefulWidget {
  const AqiForecastCard({
    super.key,
    required this.city,
  });

  final String city;

  @override
  State<AqiForecastCard> createState() => _AqiForecastCardState();
}

class _AqiForecastCardState extends State<AqiForecastCard> {
  late Future<Map<String, dynamic>> _forecast;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  @override
  void didUpdateWidget(covariant AqiForecastCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.city.trim().toLowerCase() !=
        widget.city.trim().toLowerCase()) {
      _loadForecast();
    }
  }

  void _loadForecast() {
    final city = widget.city.trim();

    _forecast = city.isEmpty
        ? Future.error(Exception('Please select a city first.'))
        : AqiApiService.getLiveForecast(city: city);
  }

  void _refresh() {
    setState(_loadForecast);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _forecast,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AQI Forecast',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2A5E),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Forecast load nahi ho saka.\n${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ),
              ],
            );
          }

          final data = snapshot.data!;
          final currentAqi = data['current_aqi'];
          final predictedAqi = data['predicted_aqi'];
          final location = data['location'] ?? widget.city;
          final forecastFor = data['forecast_for'] ?? '';
          final note =
              data['note'] ?? 'Experimental forecast estimate.';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.air,
                    color: Color(0xFF1565C0),
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Next-Hour AQI Forecast',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2A5E),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _refresh,
                    tooltip: 'Refresh forecast',
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                location.toString(),
                style: const TextStyle(color: Color(0xFF6B7F99)),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _AqiValue(
                      label: 'Current AQI',
                      value: currentAqi,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AqiValue(
                      label: 'Predicted AQI',
                      value: predictedAqi,
                      highlighted: true,
                    ),
                  ),
                ],
              ),
              if (forecastFor.toString().isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Forecast time: ${forecastFor.toString().replaceFirst('T', ' ')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7F99),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                note.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  color: Color(0xFF6B7F99),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AqiValue extends StatelessWidget {
  const _AqiValue({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final dynamic value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted
            ? const Color(0xFFEAF3FF)
            : const Color(0xFFF1F7FD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7F99),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value?.toString() ?? '--',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
        ],
      ),
    );
  }
}
