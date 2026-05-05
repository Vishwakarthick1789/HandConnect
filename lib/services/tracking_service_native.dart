import 'dart:developer';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hand_landmark.dart';
import '../models/gesture.dart';
import '../core/providers.dart';

class TrackingService {
  final Ref ref;
  Interpreter? _interpreter;
  bool _isProcessing = false;
  
  TrackingService(this.ref);

  Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/hand_landmark.tflite');
      log('TFLite model loaded successfully');
    } catch (e) {
      log('Error loading TFLite model: $e');
    }
  }

  Future<void> processImage(CameraImage image) async {
    if (_interpreter == null || _isProcessing) return;
    _isProcessing = true;

    try {
      // Extract planes before sending to isolate
      final planes = image.planes.map((p) => p.bytes).toList();
      final isolateData = IsolateData(
        planes,
        image.width,
        image.height,
        _interpreter!.address,
      );
      
      final result = await Isolate.run(() => _runInference(isolateData));
      
      if (result != null) {
        final landmarks = result.landmarks;
        _detectGesture(landmarks);
      }
    } catch (e) {
      log('Error processing image: $e');
    } finally {
      _isProcessing = false;
    }
  }
  
  static InferenceResult? _runInference(IsolateData data) {
    try {
      final interpreter = Interpreter.fromAddress(data.interpreterAddress);
      
      final inputShape = interpreter.getInputTensor(0).shape;
      final int inputSize = inputShape.length > 1 ? inputShape[1] : 224;
      
      var input = List.generate(
        1,
        (i) => List.generate(
          inputSize,
          (j) => List.generate(
            inputSize,
            (k) => [0.0, 0.0, 0.0],
          ),
        ),
      );
      
      // Better YUV to RGB Center-Crop approximation
      if (data.planes.isNotEmpty && data.planes[0].isNotEmpty) {
        final yPlane = data.planes[0];
        final minDim = math.min(data.width, data.height);
        final offsetX = (data.width - minDim) ~/ 2;
        final offsetY = (data.height - minDim) ~/ 2;
        
        final double scale = minDim / inputSize;
        
        for (int y = 0; y < inputSize; y++) {
          for (int x = 0; x < inputSize; x++) {
            // Map 224x224 back to the cropped center of the original image
            int srcX = offsetX + (x * scale).toInt();
            int srcY = offsetY + (y * scale).toInt();
            
            // Clamp
            srcX = srcX.clamp(0, data.width - 1);
            srcY = srcY.clamp(0, data.height - 1);
            
            int pixelIndex = srcY * data.width + srcX;
            if (pixelIndex < yPlane.length) {
              double val = yPlane[pixelIndex] / 255.0;
              input[0][y][x] = [val, val, val]; // Grayscale mapped to RGB channels
            }
          }
        }
      }
      
      var output = List.generate(1, (i) => List.filled(63, 0.0));
      
      interpreter.run(input, output);
      
      final flatOutput = output[0];
      List<HandLandmark> landmarks = [];
      
      bool isEmpty = flatOutput.every((element) => element == 0.0);
      
      if (isEmpty) {
        return null; // Model failed to find anything or input was bad
      } else {
        // Decode actual TFLite coordinates
        for (int i = 0; i < 21; i++) {
          int offset = i * 3;
          double rawX = flatOutput[offset];
          double rawY = flatOutput[offset + 1];
          
          landmarks.add(HandLandmark(
            x: rawX > 1.0 ? rawX / 224.0 : rawX,
            y: rawY > 1.0 ? rawY / 224.0 : rawY,
            z: flatOutput[offset + 2],
          ));
        }
      }

      return InferenceResult(landmarks);
    } catch (e) {
      log('Isolate error: $e');
      return null;
    }
  }

  void _detectGesture(List<HandLandmark> landmarks) {
    if (landmarks.length < 21) return;
    
    final indexTip = landmarks[8];
    final indexPip = landmarks[6];
    
    // Y coordinates increase downwards
    bool isIndexExtended = indexTip.y < indexPip.y;
    
    HandGesture currentGesture = isIndexExtended ? HandGesture.draw : HandGesture.pause;
    
    ref.read(gestureProvider.notifier).state = currentGesture;
    
    if (currentGesture == HandGesture.draw) {
      ref.read(drawingProvider.notifier).addPoint(Offset(indexTip.x, indexTip.y));
    } else {
      ref.read(drawingProvider.notifier).endStroke();
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}

class IsolateData {
  final List<Uint8List> planes;
  final int width;
  final int height;
  final int interpreterAddress;

  IsolateData(this.planes, this.width, this.height, this.interpreterAddress);
}

class InferenceResult {
  final List<HandLandmark> landmarks;

  InferenceResult(this.landmarks);
}
