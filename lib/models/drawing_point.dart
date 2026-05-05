import 'package:flutter/material.dart';

class DrawingPoint {
  final Offset offset;
  final double pressure; // For variable stroke width based on Z depth if available

  DrawingPoint({
    required this.offset,
    this.pressure = 1.0,
  });
}
