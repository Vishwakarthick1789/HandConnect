import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  CameraController? get controller => _controller;

  Future<void> init() async {
    try {
      bool hasPermission = true;
      
      if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
        final status = await Permission.camera.request().timeout(
          const Duration(seconds: 3),
          onTimeout: () => PermissionStatus.denied,
        );
        hasPermission = status.isGranted;
      }

      if (hasPermission) {
        _cameras = await availableCameras().timeout(
          const Duration(seconds: 5),
          onTimeout: () => [],
        );
        
        if (_cameras.isNotEmpty) {
          // Use the front camera by default
          final frontCamera = _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras.first,
          );

          _controller = CameraController(
            frontCamera,
            ResolutionPreset.medium, // Better performance for ML
            enableAudio: false,
          );

          await _controller!.initialize().timeout(
            const Duration(seconds: 5),
          );
        }
      }
    } catch (e) {
      // Ignore camera errors for web simulation or emulator without camera
      print("Camera init error: $e");
    }
  }

  void startImageStream(Function(CameraImage) onImage) {
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.startImageStream(onImage);
    }
  }

  void stopImageStream() {
    if (_controller != null && _controller!.value.isStreamingImages) {
      _controller!.stopImageStream();
    }
  }

  void dispose() {
    _controller?.dispose();
  }
}
