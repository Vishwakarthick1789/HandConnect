import 'dart:developer';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class GalleryService {
  Future<bool> saveCanvas(GlobalKey repaintBoundaryKey) async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        log("RepaintBoundary not found");
        return false;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return false;
      
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final fileName = "HandConnect_${DateTime.now().millisecondsSinceEpoch}.png";

      if (Platform.isWindows) {
        // Save to Downloads on Windows
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          final file = File('${directory.path}\\$fileName');
          await file.writeAsBytes(pngBytes);
          log("Saved to Windows Downloads: ${file.path}");
          return true;
        }
        return false;
      } else {
        // 1. Request Storage Permission
        if (await _requestStoragePermission() == false) {
          log("Storage permission denied");
          return false;
        }

        // 3. Save to Gallery
        final result = await ImageGallerySaver.saveImage(
          pngBytes,
          quality: 100,
          name: fileName.replaceAll(".png", ""),
        );

        log("Save result: $result");
        return result['isSuccess'] == true;
      }
    } catch (e) {
      log('Error saving canvas: $e');
      return false;
    }
  }

  Future<bool> _requestStoragePermission() async {
    // Handling permissions for Android 13+ (photos) and below (storage)
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.photos,
    ].request();

    final storage = statuses[Permission.storage] ?? PermissionStatus.denied;
    final photos = statuses[Permission.photos] ?? PermissionStatus.denied;

    return storage.isGranted || photos.isGranted;
  }
}
