import 'package:flutter/material.dart';
import 'drawing_point.dart';

enum ShapeType {
  freehand,
  line,
  circle,
  rectangle,
}

class Stroke {
  final List<DrawingPoint> points;
  final Color color;
  final double width;
  final ShapeType shapeType;

  // For perfect shapes, we can store their bounds/start-end
  final Offset? shapeStart;
  final Offset? shapeEnd;

  Stroke({
    required this.points,
    required this.color,
    required this.width,
    this.shapeType = ShapeType.freehand,
    this.shapeStart,
    this.shapeEnd,
  });

  Stroke copyWith({
    List<DrawingPoint>? points,
    Color? color,
    double? width,
    ShapeType? shapeType,
    Offset? shapeStart,
    Offset? shapeEnd,
  }) {
    return Stroke(
      points: points ?? this.points,
      color: color ?? this.color,
      width: width ?? this.width,
      shapeType: shapeType ?? this.shapeType,
      shapeStart: shapeStart ?? this.shapeStart,
      shapeEnd: shapeEnd ?? this.shapeEnd,
    );
  }
}
