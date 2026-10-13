import 'dart:math';
import 'package:aqi_forcasting/providers/aqi_result_provider.dart'; // 1. AqiResultProvider import karein
import 'package:aqi_forcasting/screens/photos_screen/photos.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class AnalysisResultScreen extends StatelessWidget {
  const AnalysisResultScreen({super.key});

  static const Color _navy = Color(0xFF0A2A5E);
  static const Color _blue = Color(0xFF1565C0);
  static const Color _bg = Color(0xFFF1F7FD);
  static const Color _textDark = Color(0xFF0F2A4A);
  static const Color _textMuted = Color(0xFF6B7F99);
  static const Color _border = Color(0xFFE3EDF8);

  Future<void> _shareAnalysis(BuildContext context) async {
    // 2. AqiResultProvider se currentResult read karein[cite: 14]
    final result = context.read<AqiResultProvider>().currentResult;
    if (result == null) return;

    final String report = '''
AIR QUALITY ANALYSIS REPORT

 Location: ${result.location}

 PM2.5: ${result.pm25} µg/m³
 AQI: ${result.aqi}
 Air Quality: ${result.status}

 Humidity: ${result.humidity}
 Wind Speed: ${result.wind}
 Analysis Time: ${result.time}

 HEALTH ADVICE
${result.englishAdvice}

اردو مشورہ:
${result.urduAdvice}

Note: This result is estimated from a photo, not a direct sensor reading.
''';

    try {
      await SharePlus.instance.share(
        ShareParams(text: report, subject: 'Air Quality Analysis Report'),
      );
    } catch (e) {
      debugPrint('Error sharing AQI report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. AqiResultProvider se currentResult watch karein[cite: 14]
    final result = context.watch<AqiResultProvider>().currentResult;

    if (result == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _navy),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Analysis Result',
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Share Analysis',
            icon: const Icon(Icons.share_outlined, color: _navy),
            onPressed: () => _shareAnalysis(context),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: _navy),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: _blue, size: 20),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                result.location,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _border),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, color: Color(0xFFEF4444), size: 6),
                            SizedBox(width: 6),
                            Text(
                              'Live Optical Calibrated',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // PM2.5 Gauge Card
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: _border),
                      boxShadow: [
                        BoxShadow(
                          color: _navy.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 190,
                          height: 190,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(190, 190),
                                painter: ArcGaugePainter(
                                  progress: 0.72,
                                  trackColor: const Color(0xFFE8F0F9),
                                  progressColor: const Color(0xFFB91C1C),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'PM2.5 DENSITY',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _textMuted,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Text(
                                    '${result.pm25}',
                                    style: const TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFB91C1C),
                                      height: 1,
                                    ),
                                  ),
                                  const Text(
                                    'µg/m³',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFFCA5A5)),
                                    ),
                                    child: Text(
                                      result.status,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF991B1B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'AQI ${result.aqi} • Unhealthy Range (151–200)',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Metrics
                        Row(
                          children: [
                            _buildMetricItem(
                              icon: Icons.water_drop_outlined,
                              label: 'Humidity',
                              value: result.humidity,
                            ),
                            const SizedBox(width: 10),
                            _buildMetricItem(
                              icon: Icons.air_rounded,
                              label: 'Wind',
                              value: result.wind,
                            ),
                            const SizedBox(width: 10),
                            _buildMetricItem(
                              icon: Icons.access_time_rounded,
                              label: 'Time',
                              value: result.time,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Health Advice Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: const Color(0xFFFED7D7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Health Advice',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7F1D1D),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            result.urduAdvice,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.7,
                              color: Color(0xFF450A0A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          result.englishAdvice,
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF7F1D1D)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.bookmark_outline_rounded, size: 18, color: Colors.white),
                      label: const Text('Save Result', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFEAF3FD),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const PhotoPreviewScreen()),
                          (route) => route.isFirst,
                        );
                      },
                      icon: const Icon(Icons.camera_alt_outlined, color: _blue, size: 18),
                      label: const Text('New Photo', style: TextStyle(color: _blue)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: _blue, size: 14),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 11, color: _textMuted)),
              ],
            ),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark)),
          ],
        ),
      ),
    );
  }
}

class ArcGaugePainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  ArcGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 16;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (min(size.width, size.height) - strokeWidth) / 2;
    final double startAngle = 135 * (pi / 180);
    final double sweepAngle = 270 * (pi / 180);
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);

    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, startAngle, sweepAngle, false, trackPaint);

    final Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, startAngle, sweepAngle * progress.clamp(0.0, 1.0), false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant ArcGaugePainter oldDelegate) => true;
}