import 'package:flutter/material.dart';
import 'package:irawan_driweather/screens/home_screen.dart';

class OnboardScreen extends StatelessWidget {
  const OnboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final isDaytime = hour >= 6 && hour < 18;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDaytime
                ? [
                    const Color(0xFF87CEEB), 
                    const Color(0xFFE6F3FF), 
                  ]
                : [
                    const Color(0xFF191970), 
                    const Color(0xFF4169E1), 
                  ],
          ),
        ),
        child: Stack(
          children: [
            if (isDaytime) ...[
              Positioned(
                top: 80,
                left: 20,
                child: _buildCloud(size: 60, opacity: 0.8),
              ),
              Positioned(
                top: 120,
                right: 30,
                child: _buildCloud(size: 40, opacity: 0.6),
              ),
              Positioned(
                top: 180,
                left: 60,
                child: _buildCloud(size: 50, opacity: 0.7),
              ),
              Positioned(
                top: 220,
                right: 10,
                child: _buildCloud(size: 35, opacity: 0.5),
              ),
            ] else ...[
              Positioned(
                top: 80,
                left: 50,
                child: _buildStar(size: 8),
              ),
              Positioned(
                top: 120,
                right: 80,
                child: _buildStar(size: 6),
              ),
              Positioned(
                top: 160,
                left: 30,
                child: _buildStar(size: 10),
              ),
              Positioned(
                top: 200,
                right: 40,
                child: _buildStar(size: 7),
              ),
              Positioned(
                top: 100,
                left: 120,
                child: _buildStar(size: 5),
              ),
              Positioned(
                top: 240,
                left: 80,
                child: _buildStar(size: 9),
              ),
              Positioned(
                top: 280,
                right: 100,
                child: _buildStar(size: 6),
              ),
            ],

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),

                          if (isDaytime) ...[
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFD700),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700)
                                        .withOpacity(0.6),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            for (int i = 0; i < 8; i++)
                              Transform.rotate(
                                angle: (i * 45) * 3.14159 / 180,
                                child: Container(
                                  width: 4,
                                  height: 30,
                                  margin: const EdgeInsets.only(bottom: 140),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                          ] else ...[
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF5F5DC),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF5F5DC)
                                        .withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 130,
                              left: 160,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      const Color(0xFFE6E6FA).withOpacity(0.6),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 150,
                              left: 170,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      const Color(0xFFE6E6FA).withOpacity(0.4),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Never get caught\nin the rain again',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Stay ahead of the weather with our accurate forecasts',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: isDaytime
                            ? const Color(0xFF2196F3)
                            : const Color(0xFF191970),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloud({required double size, required double opacity}) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(size),
      ),
      child: Stack(
        children: [
          Positioned(
            left: size * 0.15,
            top: size * 0.1,
            child: Container(
              width: size * 0.4,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: size * 0.15,
            top: size * 0.05,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: size * 0.4,
            bottom: size * 0.1,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStar({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: size / 2,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
