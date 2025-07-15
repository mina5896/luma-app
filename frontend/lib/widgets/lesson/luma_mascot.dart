import 'package:flutter/material.dart';
import 'dart:math' as math;

// The different states our mascot can be in.
enum MascotState { reading, thinking, happy, sad, celebrating }

class LumaMascot extends StatefulWidget {
  final MascotState state;
  const LumaMascot({super.key, required this.state});

  @override
  State<LumaMascot> createState() => _LumaMascotState();
}

class _LumaMascotState extends State<LumaMascot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // We use a CustomPaint to draw our mascot.
        return CustomPaint(
          size: const Size(100, 110),
          painter: _MascotPainter(
            state: widget.state,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}

// The CustomPainter class that does the actual drawing.
class _MascotPainter extends CustomPainter {
  final MascotState state;
  final double animationValue;

  _MascotPainter({required this.state, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // --- Define Paints ---
    final bulbPaint = Paint()..color = Colors.yellow.shade600;
    final basePaint = Paint()..color = Colors.grey.shade400;
    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // --- Base position and animation values ---
    final bobbing = math.sin(animationValue * 2 * math.pi) * 2;
    final center = Offset(size.width / 2, size.height / 2 + bobbing);
    final bulbRadius = size.width * 0.4;

    // --- Draw the Mascot Body ---
    canvas.drawRect(Rect.fromCenter(center: center + Offset(0, bulbRadius + 5), width: 25, height: 15), basePaint);
    canvas.drawCircle(center, bulbRadius, bulbPaint);

    // --- Draw different states ---
    switch (state) {
      case MascotState.reading:
        // --- THIS IS THE CORRECTED PART ---
        // Draw the eyes FIRST, so the glasses are on top.
        _drawEyes(canvas, center, bulbRadius, happy: true, reading: true);
        _drawGlasses(canvas, center, bulbRadius, linePaint);
        break;
      case MascotState.celebrating:
        final jump = (math.sin(animationValue * math.pi * 2).abs()) * -20;
        final celebratingCenter = center + Offset(0, jump);
        _drawEyes(canvas, celebratingCenter, bulbRadius, happy: true, reading: false);
        _drawMouth(canvas, celebratingCenter, bulbRadius, happy: true, open: true);
        _drawConfetti(canvas, size, animationValue);
        break;
      // Other cases remain the same
      case MascotState.thinking:
        _drawThinkingHand(canvas, center, bulbRadius, linePaint);
        _drawThinkingBubble(canvas, center - Offset(bulbRadius * 0.8, bulbRadius + 25), animationValue);
        _drawEyes(canvas, center, bulbRadius, happy: true, reading: false, thinking: true);
        _drawMouth(canvas, center, bulbRadius, happy: false, open: false);
        break;
      case MascotState.happy:
        _drawEyes(canvas, center, bulbRadius, happy: true, reading: false);
        _drawMouth(canvas, center, bulbRadius, happy: true, open: true);
        break;
      case MascotState.sad:
        _drawEyes(canvas, center, bulbRadius, happy: false, reading: false);
        _drawMouth(canvas, center, bulbRadius, happy: false, open: false);
        break;
    }
  }

  void _drawGlasses(Canvas canvas, Offset center, double bulbRadius, Paint paint) {
    final glassRadius = bulbRadius * 0.3;
    final leftGlassCenter = center + Offset(-bulbRadius * 0.4, -bulbRadius * 0.1);
    final rightGlassCenter = center + Offset(bulbRadius * 0.4, -bulbRadius * 0.1);

    canvas.drawCircle(leftGlassCenter, glassRadius, paint);
    canvas.drawCircle(rightGlassCenter, glassRadius, paint);
    canvas.drawLine(leftGlassCenter + Offset(glassRadius, 0), rightGlassCenter - Offset(glassRadius, 0), paint);
  }

  void _drawConfetti(Canvas canvas, Size size, double animationValue) {
    final random = math.Random(1); // Use a seed for consistent "randomness"
    for (int i = 0; i < 30; i++) {
      final color = Colors.primaries[random.nextInt(Colors.primaries.length)];
      final paint = Paint()..color = color.withOpacity(1.0 - animationValue);
      final startX = random.nextDouble() * size.width;
      final startY = size.height * animationValue;
      canvas.drawCircle(Offset(startX, startY), random.nextDouble() * 4 + 2, paint);
    }
  }

  void _drawEyes(Canvas canvas, Offset center, double bulbRadius, {required bool happy, required bool reading, bool thinking = false}) {
    final eyePathPaint = Paint()..color = Colors.black.withOpacity(0.8)..strokeWidth = 2..style = PaintingStyle.stroke;
    final leftEyeCenter = center + Offset(-bulbRadius * 0.4, -bulbRadius * 0.2);
    final rightEyeCenter = center + Offset(bulbRadius * 0.4, -bulbRadius * 0.2);

    if (reading) {
      final eyePath = Path();
      eyePath.moveTo(leftEyeCenter.dx - 5, leftEyeCenter.dy);
      eyePath.quadraticBezierTo(leftEyeCenter.dx, leftEyeCenter.dy + 7, leftEyeCenter.dx + 5, leftEyeCenter.dy);
      eyePath.moveTo(rightEyeCenter.dx - 5, rightEyeCenter.dy);
      eyePath.quadraticBezierTo(rightEyeCenter.dx, rightEyeCenter.dy + 7, rightEyeCenter.dx + 5, rightEyeCenter.dy);
      canvas.drawPath(eyePath, eyePathPaint);
    } else if (happy) {
      final eyePath = Path();
      final yOffset = thinking ? 1 : 2;
      final xControl = thinking ? 0 : 5;
      eyePath.moveTo(leftEyeCenter.dx - 5, leftEyeCenter.dy + yOffset);
      eyePath.quadraticBezierTo(leftEyeCenter.dx, leftEyeCenter.dy - 3, leftEyeCenter.dx + xControl, leftEyeCenter.dy + yOffset);
      eyePath.moveTo(rightEyeCenter.dx - xControl, rightEyeCenter.dy + yOffset);
      eyePath.quadraticBezierTo(rightEyeCenter.dx, rightEyeCenter.dy - 3, rightEyeCenter.dx + 5, rightEyeCenter.dy + yOffset);
      canvas.drawPath(eyePath, eyePathPaint);
    } else { // Sad
      final eyePath = Path();
      eyePath.moveTo(leftEyeCenter.dx - 5, leftEyeCenter.dy);
      eyePath.quadraticBezierTo(leftEyeCenter.dx, leftEyeCenter.dy + 5, leftEyeCenter.dx + 5, leftEyeCenter.dy);
      eyePath.moveTo(rightEyeCenter.dx - 5, rightEyeCenter.dy);
      eyePath.quadraticBezierTo(rightEyeCenter.dx, rightEyeCenter.dy + 5, rightEyeCenter.dx + 5, rightEyeCenter.dy);
      canvas.drawPath(eyePath, eyePathPaint);
    }
  }

  void _drawMouth(Canvas canvas, Offset center, double bulbRadius, {required bool happy, required bool open}) {
    final mouthPaint = Paint()..color = Colors.black.withOpacity(0.8)..strokeWidth = 2..style = PaintingStyle.stroke;
    final mouthPath = Path();
    final mouthY = center.dy + bulbRadius * 0.3;

    if (happy) {
      mouthPath.moveTo(center.dx - 10, mouthY);
      mouthPath.quadraticBezierTo(center.dx, mouthY + (open ? 12 : 5), center.dx + 10, mouthY);
    } else {
      mouthPath.moveTo(center.dx - 8, mouthY + 5);
      mouthPath.quadraticBezierTo(center.dx, mouthY + 2, center.dx + 8, mouthY + 5);
    }
    canvas.drawPath(mouthPath, mouthPaint);
  }
  
  void _drawThinkingHand(Canvas canvas, Offset center, double bulbRadius, Paint paint) {
    final handPath = Path();
    final chinPoint = center + Offset(bulbRadius * 0.4, bulbRadius * 0.7);
    handPath.moveTo(chinPoint.dx + 20, chinPoint.dy - 10);
    handPath.quadraticBezierTo(chinPoint.dx + 5, chinPoint.dy, chinPoint.dx, chinPoint.dy);
    canvas.drawPath(handPath, paint);
  }

  void _drawThinkingBubble(Canvas canvas, Offset center, double animationValue) {
    final bubblePaint = Paint()..color = Colors.grey.shade300;
    final dotPaint = Paint()..color = Colors.grey.shade600;

    canvas.drawCircle(center + const Offset(10, 15), 3, bubblePaint);
    canvas.drawCircle(center + const Offset(5, 5), 5, bubblePaint);
    
    final mainBubbleCenter = center - const Offset(10, 10);
    canvas.drawCircle(mainBubbleCenter, 15, bubblePaint);

    final dotOffset = math.sin(animationValue * math.pi * 4) * 3;
    canvas.drawCircle(mainBubbleCenter - Offset(5, -dotOffset * 0.5), 1.5, dotPaint);
    canvas.drawCircle(mainBubbleCenter + Offset(0, dotOffset), 1.5, dotPaint);
    canvas.drawCircle(mainBubbleCenter + Offset(5, -dotOffset * 0.5), 1.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}