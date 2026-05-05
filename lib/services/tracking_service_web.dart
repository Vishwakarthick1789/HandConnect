import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackingService {
  final Ref ref;
  
  TrackingService(this.ref);

  Future<void> init() async {
    log('TrackingService initialized (Web mode - Camera ML disabled)');
    // No simulation. User must draw with mouse/touch on Web.
  }

  Future<void> processImage(CameraImage image) async {
    // TFLite is not supported on web. Do nothing.
  }

  void dispose() {
    // Nothing to dispose
  }
}
