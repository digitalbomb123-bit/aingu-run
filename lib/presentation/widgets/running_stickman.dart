import 'dart:math';
import 'package:flutter/material.dart';

class RunningStickman extends StatefulWidget {
  final double size;
  final bool isRunning;

  const RunningStickman({super.key, required this.size, required this.isRunning});

  @override
  State<RunningStickman> createState() => _RunningStickmanState();
}

class _RunningStickmanState extends State<RunningStickman> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    if (widget.isRunning) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(RunningStickman oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRunning && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0.0;
    }
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
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _StickmanPainter(_controller.value, widget.isRunning),
        );
      },
    );
  }
}

class _StickmanPainter extends CustomPainter {
  final double animValue;
  final bool isRunning;

  _StickmanPainter(this.animValue, this.isRunning);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final topY = size.height * 0.1;
    
    // Head
    canvas.drawCircle(Offset(centerX, topY + size.height * 0.15), size.width * 0.15, paint..style = PaintingStyle.fill);

    // Revert style for lines
    paint.style = PaintingStyle.stroke;

    // Spine
    final spineStartY = topY + size.height * 0.3;
    final spineEndY = topY + size.height * 0.6;
    
    // If running, lean forward slightly
    final spineEndX = isRunning ? centerX + size.width * 0.05 : centerX;
    canvas.drawLine(Offset(centerX, spineStartY), Offset(spineEndX, spineEndY), paint);

    // Animation cycle
    final swing = isRunning ? sin(animValue * 2 * pi) : 0.0;
    
    final legSwing = swing * size.width * 0.4;
    final armSwing = -swing * size.width * 0.4;

    // Legs
    canvas.drawLine(Offset(spineEndX, spineEndY), Offset(centerX - legSwing, size.height * 0.9), paint);
    canvas.drawLine(Offset(spineEndX, spineEndY), Offset(centerX + legSwing, size.height * 0.9), paint);

    // Arms
    final armStartY = topY + size.height * 0.4;
    canvas.drawLine(Offset(centerX + (isRunning ? size.width * 0.02 : 0), armStartY), Offset(centerX - armSwing, armStartY + size.height * 0.2), paint);
    canvas.drawLine(Offset(centerX + (isRunning ? size.width * 0.02 : 0), armStartY), Offset(centerX + armSwing, armStartY + size.height * 0.2), paint);
  }

  @override
  bool shouldRepaint(covariant _StickmanPainter oldDelegate) {
    return oldDelegate.animValue != animValue || oldDelegate.isRunning != isRunning;
  }
}
