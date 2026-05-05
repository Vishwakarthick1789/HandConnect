import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';

class FloatingToolbar extends ConsumerWidget {
  const FloatingToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We only need the current color to highlight the selected button, 
    // but DrawingNotifier doesn't expose just the current color via state.
    // To make it simple, we can just let it be stateless visually or 
    // update DrawingNotifier to expose current color. For now, we will just dispatch the color change.
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: AppTheme.drawingColors.map((color) {
              return GestureDetector(
                onTap: () {
                  ref.read(drawingProvider.notifier).setColor(color);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
