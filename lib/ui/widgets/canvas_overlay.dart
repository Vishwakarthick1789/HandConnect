import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../models/stroke.dart';

class CanvasOverlay extends ConsumerWidget {
  const CanvasOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strokes = ref.watch(drawingProvider);

    return RepaintBoundary(
      child: CustomPaint(
        painter: NeonPainter(strokes: strokes),
        child: Container(),
      ),
    );
  }
}

class NeonPainter extends CustomPainter {
  final List<Stroke> strokes;

  NeonPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty && stroke.shapeType == ShapeType.freehand) continue;

      final path = Path();
      
      if (stroke.shapeType == ShapeType.freehand) {
        final firstPoint = _scalePoint(stroke.points.first.offset, size);
        path.moveTo(firstPoint.dx, firstPoint.dy);

        for (int i = 1; i < stroke.points.length; i++) {
          final point = _scalePoint(stroke.points[i].offset, size);
          path.lineTo(point.dx, point.dy);
        }
      } else if (stroke.shapeStart != null && stroke.shapeEnd != null) {
        final start = _scalePoint(stroke.shapeStart!, size);
        final end = _scalePoint(stroke.shapeEnd!, size);
        final rect = Rect.fromPoints(start, end);

        switch (stroke.shapeType) {
          case ShapeType.line:
            path.moveTo(start.dx, start.dy);
            path.lineTo(end.dx, end.dy);
            break;
          case ShapeType.circle:
            path.addOval(rect);
            break;
          case ShapeType.rectangle:
            path.addRect(rect);
            break;
          case ShapeType.freehand:
            break;
        }
      }

      // 1. Draw the Outer Glow (Neon Effect)
      final glowPaint = Paint()
        ..color = stroke.color.withOpacity(0.5)
        ..strokeWidth = stroke.width * 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawPath(path, glowPaint);

      // 2. Draw the Inner Core (Solid Line)
      final corePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, corePaint);
    }
  }

  Offset _scalePoint(Offset normalizedOffset, Size size) {
    return Offset(
      normalizedOffset.dx * size.width,
      normalizedOffset.dy * size.height,
    );
  }

  @override
  bool shouldRepaint(covariant NeonPainter oldDelegate) {
    return oldDelegate.strokes != strokes;
  }
}
