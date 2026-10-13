import 'dart:io';
import 'package:aqi_forcasting/providers/aqi_result_provider.dart';
import 'package:aqi_forcasting/providers/sky_aqi_provider.dart';
import 'package:aqi_forcasting/screens/result_screen/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SkyAqiLoadingScreen extends StatefulWidget {
  const SkyAqiLoadingScreen({super.key});

  @override
  State<SkyAqiLoadingScreen> createState() => _SkyAqiLoadingScreenState();
}

class _SkyAqiLoadingScreenState extends State<SkyAqiLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  static const Color _navy = Color(0xFF0A2A5E);
  static const Color _blue = Color(0xFF1565C0);
  static const Color _sky = Color(0xFF4DA3F0);
  static const Color _bg = Color(0xFFF1F7FD);
  static const Color _textDark = Color(0xFF0F2A4A);
  static const Color _textMuted = Color(0xFF8EA0B8);

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Trigger analysis sequence via Provider
   WidgetsBinding.instance.addPostFrameCallback((_) {
  context.read<SkyAqiProvider>().startAnalysisPipeline(() {
    if (!mounted) return;

    // Result pehle generate karein, phir screen kholein
    context.read<AqiResultProvider>().generateAnalysisResult(
      location: 'Lahore, Pakistan',
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AnalysisResultScreen()),
    );
  });
}); 
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SkyAqiProvider>();
    final currentStep = provider.loadingStepIndex;
    final imagePath = provider.selectedImagePath;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _sky.withValues(alpha: 0.22),
                              _sky.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                      RotationTransition(
                        turns: _rotationController,
                        child: const SizedBox(
                          width: 142,
                          height: 142,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.5,
                            strokeCap: StrokeCap.round,
                            valueColor: AlwaysStoppedAnimation<Color>(_blue),
                            backgroundColor: Color(0xFFD6E6F7),
                          ),
                        ),
                      ),
                      Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: _blue.withValues(alpha: 0.22),
                              blurRadius: 24,
                              spreadRadius: 1,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child:
                              imagePath != null && File(imagePath).existsSync()
                              ? Image.file(File(imagePath), fit: BoxFit.cover)
                              : Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [_navy, _blue, _sky],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.cloud_outlined,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Analyzing your sky...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 36),

              // Steps List
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE3EDF8)),
                  boxShadow: [
                    BoxShadow(
                      color: _navy.withValues(alpha: 0.07),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildStepRow(
                      0,
                      'Checking photo',
                      Icons.image_search_rounded,
                      currentStep,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 42.0, top: 4, bottom: 4),
                      child: Divider(height: 12, color: Color(0xFFE8F0F9)),
                    ),
                    _buildStepRow(
                      1,
                      'Getting weather data',
                      Icons.thermostat_outlined,
                      currentStep,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 42.0, top: 4, bottom: 4),
                      child: Divider(height: 12, color: Color(0xFFE8F0F9)),
                    ),
                    _buildStepRow(
                      2,
                      'Estimating PM2.5',
                      Icons.air_rounded,
                      currentStep,
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(
    int stepIndex,
    String label,
    IconData icon,
    int activeStep,
  ) {
    final bool isFinished = stepIndex < activeStep;
    final bool isCurrent = stepIndex == activeStep;

    Color labelColor = _textMuted;
    FontWeight labelWeight = FontWeight.w500;

    if (isFinished) {
      labelColor = const Color(0xFF334155);
    } else if (isCurrent) {
      labelColor = _blue;
      labelWeight = FontWeight.bold;
    }

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFinished
                ? const Color(0xFFDCFCE7)
                : isCurrent
                ? const Color(0xFFDBEAFE)
                : const Color(0xFFEEF3F9),
          ),
          child: Center(
            child: isFinished
                ? const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF16A34A),
                    size: 18,
                  )
                : isCurrent
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_blue),
                    ),
                  )
                : Icon(icon, color: _textMuted, size: 15),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: labelWeight,
              color: labelColor,
            ),
          ),
        ),
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Text(
              'IN PROGRESS',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: _blue,
                letterSpacing: 0.8,
              ),
            ),
          ),
      ],
    );
  }
}
