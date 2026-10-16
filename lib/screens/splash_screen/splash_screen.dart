import 'package:aqi_forcasting/screens/login_screen/login_screen.dart';
import 'package:flutter/material.dart';
class SkyAqiSplashScreen extends StatefulWidget {
  const SkyAqiSplashScreen({super.key});

  @override
  State<SkyAqiSplashScreen> createState() =>
      _SkyAqiSplashScreenState();
}

class _SkyAqiSplashScreenState
    extends State<SkyAqiSplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A2A5E),
              Color(0xFF1565C0),
              Color(0xFF4DA3F0),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PAKISTAN AIR TELEMETRY',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.6,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5CF2A6),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF5CF2A6)
                                      .withValues(alpha: 0.7),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Middle Main Content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCentralGraphic(),

                  const SizedBox(height: 36),

                  const Text(
                    'SkyAQI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Estimate air quality from the sky',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'آسمان کی تصویر سے ہوا کا معیار جانیں',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Computer Vision Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.22),
                          Colors.white.withValues(alpha: 0.10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 17,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'COMPUTER VISION TELEMETRY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Bottom Indicators and Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(isActive: true),
                        _buildDot(isActive: false),
                        _buildDot(isActive: false),
                      ],
                    ),

                    const SizedBox(height: 26),

                    Container(
                      width: 40,
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'v1.0 • Pakistan Clean Air Initiative',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.4,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'LAHORE • KARACHI • ISLAMABAD • PESHAWAR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Central Circle Graphic
  Widget _buildCentralGraphic() {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft glow
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),

          // Outer Circle
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1,
              ),
            ),
          ),

          // Middle Circle
          Container(
            width: 184,
            height: 184,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.38),
                width: 1.5,
              ),
            ),
          ),

          // Inner Glass Circle
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.40),
                  Colors.white.withValues(alpha: 0.14),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A2A5E).withValues(alpha: 0.35),
                  blurRadius: 28,
                  spreadRadius: 1,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CC_',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),

          // Sparkle Badge
          Positioned(
            top: 38,
            right: 38,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFF1565C0),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Carousel Dot
  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white
            : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}