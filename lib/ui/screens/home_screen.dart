import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/glass_card.dart';
import '../../core/theme/app_theme.dart';
import 'drawing_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // App Title
              Center(
                child: Text(
                  'HandConnect',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      const Shadow(
                        color: AppTheme.neonCyan,
                        blurRadius: 10,
                      )
                    ],
                  ),
                ).animate().fade(duration: 800.ms).slideY(begin: -0.2),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Draw with your fingers',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ).animate().fade(delay: 300.ms).slideY(begin: -0.2),
              ),
              
              const Spacer(),
              
              // Start Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DrawingScreen(),
                      ),
                    );
                  },
                  child: GlassCard(
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.camera_alt_outlined,
                          color: AppTheme.neonCyan,
                          size: 40,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'Start Drawing',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .shimmer(duration: 2000.ms, color: Colors.white10),
                ),
              ),
              
              const SizedBox(height: 30),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
