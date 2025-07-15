import 'package:flutter/material.dart';

class PathPainter extends CustomPainter {
  final List<Offset> nodePositions;
  final int unlockedLevel;
  final int animatingIndex;

  PathPainter({
    required this.nodePositions,
    required this.unlockedLevel,
    required this.animatingIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;
    
    final paint = Paint()..color = Colors.grey.shade400..style = PaintingStyle.stroke..strokeWidth = 3.0;

    for (int i = 0; i < nodePositions.length - 1; i++) {
      final start = nodePositions[i] + const Offset(40, 80);
      final end = nodePositions[i + 1] + const Offset(40, 0);
      final path = _buildCubicPath(start, end);
      
      _drawDashedPath(canvas, path, paint);

      if (i + 1 > unlockedLevel && animatingIndex != i) {
        final lockPoint = _getPointOnCubicBezier(0.5, start, Offset(start.dx, start.dy + 60), Offset(end.dx, end.dy - 60), end);
        _drawIcon(canvas, Icons.lock, lockPoint, Colors.brown.shade400);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const double dashWidth = 8.0;
    const double dashSpace = 4.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }
  
  Path _buildCubicPath(Offset start, Offset end) {
      final path = Path();
      path.moveTo(start.dx, start.dy);
      path.cubicTo(start.dx, start.dy + 60, end.dx, end.dy - 60, end.dx, end.dy);
      return path;
  }
  
  void _drawIcon(Canvas canvas, IconData icon, Offset position, Color color) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(fontSize: 24.0, fontFamily: icon.fontFamily, color: color),
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, position - Offset(textPainter.width / 2, textPainter.height / 2));
  }
  
  Offset _getPointOnCubicBezier(double t, Offset p0, Offset p1, Offset p2, Offset p3) {
    final u = 1 - t;
    final tt = t * t;
    final uu = u * u;
    final uuu = uu * u;
    final ttt = tt * t;
    return p0 * uuu + p1 * 3 * uu * t + p2 * 3 * u * tt + p3 * ttt;
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return oldDelegate.unlockedLevel != unlockedLevel || oldDelegate.animatingIndex != animatingIndex;
  }
}