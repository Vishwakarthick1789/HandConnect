import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/stroke.dart';
import '../../models/drawing_point.dart';

class ShapeRecognizer {
  static Stroke recognizeAndSnap(Stroke stroke) {
    if (stroke.points.length < 10) return stroke;

    final points = stroke.points;
    final first = points.first.offset;
    final last = points.last.offset;

    // Calculate Bounding Box
    double minX = first.dx, maxX = first.dx;
    double minY = first.dy, maxY = first.dy;
    double pathLength = 0;

    for (int i = 1; i < points.length; i++) {
      final p1 = points[i - 1].offset;
      final p2 = points[i].offset;
      
      minX = min(minX, p2.dx);
      maxX = max(maxX, p2.dx);
      minY = min(minY, p2.dy);
      maxY = max(maxY, p2.dy);
      
      pathLength += _distance(p1, p2);
    }

    final width = maxX - minX;
    final height = maxY - minY;
    
    // Line Detection
    final startToEndDist = _distance(first, last);
    // If the path length is very close to the straight line distance between start and end
    if (pathLength > 0 && startToEndDist / pathLength > 0.85) {
      return stroke.copyWith(
        shapeType: ShapeType.line,
        shapeStart: first,
        shapeEnd: last,
      );
    }

    // Circle / Rectangle Detection (Closed Loops)
    // If start and end are close to each other relative to the overall size
    final maxDim = max(width, height);
    if (startToEndDist < maxDim * 0.3) {
      
      final aspectRatio = width / height;
      
      // Circle check (aspect ratio close to 1)
      if (aspectRatio > 0.7 && aspectRatio < 1.3) {
        // Calculate center and average radius
        final center = Offset(minX + width / 2, minY + height / 2);
        double avgRadius = 0;
        for (var p in points) {
          avgRadius += _distance(p.offset, center);
        }
        avgRadius /= points.length;

        // Check if most points are near this radius
        int closePoints = 0;
        for (var p in points) {
          final r = _distance(p.offset, center);
          if ((r - avgRadius).abs() < maxDim * 0.2) {
            closePoints++;
          }
        }

        if (closePoints / points.length > 0.7) {
          // It's a circle!
          return stroke.copyWith(
            shapeType: ShapeType.circle,
            shapeStart: Offset(minX, minY), // Rect top-left
            shapeEnd: Offset(maxX, maxY), // Rect bottom-right
          );
        }
      }
      
      // If not a circle, but a closed loop, let's assume it's a rectangle
      // For a better implementation, we would detect corners using angles.
      // We'll use a simpler heuristic: if the bounding box area is close to the 
      // polygon area, or just fallback to rectangle for any large closed loop.
      if (width > 0.05 && height > 0.05) { // Ensure it's not a tiny dot
          return stroke.copyWith(
            shapeType: ShapeType.rectangle,
            shapeStart: Offset(minX, minY),
            shapeEnd: Offset(maxX, maxY),
          );
      }
    }

    return stroke; // Leave as freehand if no pattern matches
  }

  static double _distance(Offset p1, Offset p2) {
    return sqrt(pow(p1.dx - p2.dx, 2) + pow(p1.dy - p2.dy, 2));
  }
}
