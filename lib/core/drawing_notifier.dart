import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stroke.dart';
import '../models/drawing_point.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/shape_recognizer.dart';

class DrawingNotifier extends StateNotifier<List<Stroke>> {
  DrawingNotifier() : super([]);

  Color _currentColor = AppTheme.neonCyan;
  double _currentWidth = 5.0;
  bool _isDrawing = false;

  void setColor(Color color) {
    _currentColor = color;
  }

  void setWidth(double width) {
    _currentWidth = width;
  }

  void startStroke(Offset offset) {
    _isDrawing = true;
    final newStroke = Stroke(
      points: [DrawingPoint(offset: offset)],
      color: _currentColor,
      width: _currentWidth,
    );
    state = [...state, newStroke];
  }

  void addPoint(Offset offset) {
    if (!_isDrawing || state.isEmpty) {
      startStroke(offset);
      return;
    }
    
    final lastStroke = state.last;
    final updatedPoints = [...lastStroke.points, DrawingPoint(offset: offset)];
    final updatedStroke = lastStroke.copyWith(points: updatedPoints);
    
    state = [
      ...state.sublist(0, state.length - 1),
      updatedStroke,
    ];
  }

  void endStroke() {
    if (_isDrawing && state.isNotEmpty) {
      final lastStroke = state.last;
      final recognizedStroke = ShapeRecognizer.recognizeAndSnap(lastStroke);
      
      state = [
        ...state.sublist(0, state.length - 1),
        recognizedStroke,
      ];
    }
    _isDrawing = false;
  }

  void clear() {
    state = [];
    _isDrawing = false;
  }
}
