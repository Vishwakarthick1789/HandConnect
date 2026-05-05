import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../core/providers.dart';
import '../widgets/canvas_overlay.dart';
import '../widgets/floating_toolbar.dart';
import '../../models/gesture.dart';

class DrawingScreen extends ConsumerStatefulWidget {
  const DrawingScreen({super.key});

  @override
  ConsumerState<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends ConsumerState<DrawingScreen> {
  bool _isInitialized = false;
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final cameraService = ref.read(cameraServiceProvider);
    final trackingService = ref.read(trackingServiceProvider);

    await cameraService.init();
    await trackingService.init();

    try {
      cameraService.startImageStream((image) {
        trackingService.processImage(image);
      });
    } catch (e) {
      print("Stream error: $e");
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _saveDrawing() async {
    final galleryService = ref.read(galleryServiceProvider);
    final success = await galleryService.saveCanvas(_canvasKey);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Drawing saved to gallery!' : 'Failed to save drawing.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    ref.read(cameraServiceProvider).stopImageStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraService = ref.watch(cameraServiceProvider);
    final currentGesture = ref.watch(gestureProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview Background
          if (_isInitialized)
            (cameraService.controller != null)
                ? CameraPreview(cameraService.controller!)
                : Container(color: const Color(0xFF1A1A2E))
          else
            const Center(
              child: Text(
                'Initializing Camera...',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ),

          // Canvas Overlay wrapped in RepaintBoundary and GestureDetector for mouse/touch drawing
          RepaintBoundary(
            key: _canvasKey,
            child: GestureDetector(
              onPanStart: (details) {
                // Normalize coordinates for CanvasOverlay
                final RenderBox box = context.findRenderObject() as RenderBox;
                final size = box.size;
                final normalizedOffset = Offset(
                  details.localPosition.dx / size.width,
                  details.localPosition.dy / size.height,
                );
                // If touching screen, force gesture to draw and start stroke
                ref.read(gestureProvider.notifier).state = HandGesture.draw;
                ref.read(drawingProvider.notifier).startStroke(normalizedOffset);
              },
              onPanUpdate: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final size = box.size;
                final normalizedOffset = Offset(
                  details.localPosition.dx / size.width,
                  details.localPosition.dy / size.height,
                );
                ref.read(drawingProvider.notifier).addPoint(normalizedOffset);
              },
              onPanEnd: (details) {
                // Return to pause when touch ends
                ref.read(gestureProvider.notifier).state = HandGesture.pause;
                ref.read(drawingProvider.notifier).endStroke();
              },
              child: Container(
                color: Colors.transparent, // To capture gestures
                child: const CanvasOverlay(),
              ),
            ),
          ),
          
          // Gesture Indicator
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: currentGesture == HandGesture.draw 
                      ? Colors.green 
                      : Colors.white24,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    currentGesture == HandGesture.draw 
                        ? Icons.gesture 
                        : Icons.pan_tool,
                    color: currentGesture == HandGesture.draw 
                        ? Colors.green 
                        : Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentGesture.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Clear Button
          Positioned(
            bottom: 40,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'clearBtn',
              backgroundColor: Colors.white24,
              onPressed: () {
                ref.read(drawingProvider.notifier).clear();
              },
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
          ),
          
          // Save Button
          Positioned(
            bottom: 40,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'saveBtn',
              backgroundColor: Colors.white24,
              onPressed: _saveDrawing,
              child: const Icon(Icons.save_alt, color: Colors.white),
            ),
          ),
          
          // Floating Toolbar (Color Picker)
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingToolbar(),
            ),
          ),
          
          // Back Button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
