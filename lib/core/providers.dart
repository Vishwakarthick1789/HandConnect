import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/camera_service.dart';
import '../../services/tracking_service.dart';
import '../../services/gallery_service.dart';
import '../models/stroke.dart';
import '../models/gesture.dart';
import 'drawing_notifier.dart';

final cameraServiceProvider = Provider<CameraService>((ref) {
  final service = CameraService();
  ref.onDispose(() => service.dispose());
  return service;
});

final trackingServiceProvider = Provider<TrackingService>((ref) {
  final service = TrackingService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

final galleryServiceProvider = Provider<GalleryService>((ref) {
  return GalleryService();
});

final drawingProvider = StateNotifierProvider<DrawingNotifier, List<Stroke>>((ref) {
  return DrawingNotifier();
});

final gestureProvider = StateProvider<HandGesture>((ref) => HandGesture.none);
