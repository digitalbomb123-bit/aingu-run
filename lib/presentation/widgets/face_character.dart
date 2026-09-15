import 'package:flutter/material.dart';

class FlailingStickBody extends StatefulWidget {
  const FlailingStickBody({super.key});

  @override
  State<FlailingStickBody> createState() => _FlailingStickBodyState();
}

class _FlailingStickBodyState extends State<FlailingStickBody> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150))
      ..repeat(reverse: true);
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
          painter: StickBodyPainter(_controller.value),
        );
      },
    );
  }
}

class StickBodyPainter extends CustomPainter {
  final double animValue;

  StickBodyPainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    
    // Body (wiggles a bit)
    final bodyWiggle = (animValue - 0.5) * 15;
    
    // Spine
    final path = Path();
    path.moveTo(centerX, 0);
    path.quadraticBezierTo(centerX + bodyWiggle, size.height * 0.3, centerX, size.height * 0.5);
    canvas.drawPath(path, paint);
    
    // Arms flailing wildly
    final armSwing = (animValue - 0.5) * 80;
    canvas.drawLine(Offset(centerX + (bodyWiggle/2), size.height * 0.15), Offset(centerX - 50, size.height * 0.4 + armSwing), paint);
    canvas.drawLine(Offset(centerX + (bodyWiggle/2), size.height * 0.15), Offset(centerX + 50, size.height * 0.4 - armSwing), paint);
    
    // Legs running/kicking
    final legSwing = (animValue - 0.5) * 60;
    canvas.drawLine(Offset(centerX, size.height * 0.5), Offset(centerX - 40 + legSwing, size.height * 0.9), paint);
    canvas.drawLine(Offset(centerX, size.height * 0.5), Offset(centerX + 40 + legSwing, size.height * 0.9), paint);
  }

  @override
  bool shouldRepaint(covariant StickBodyPainter oldDelegate) {
    return oldDelegate.animValue != animValue;
  }
}

class FaceCharacter extends StatelessWidget {
  final double scale;
  final double rotation;
  final bool isFake;
  final VoidCallback onTap;

  const FaceCharacter({
    super.key,
    required this.scale,
    required this.rotation,
    required this.isFake,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        transform: Matrix4.identity()
          ..scale(scale)
          ..rotateZ(rotation),
        transformAlignment: Alignment.topCenter,
        width: 120,
        height: 240, // Extended height for the body
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Stick Body below the head
            Positioned(
              top: 100, // Starts at the "neck"
              child: SizedBox(
                width: 120,
                height: 140,
                child: const FlailingStickBody(),
              ),
            ),
            
            // The Face
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: ColorFiltered(
                  colorFilter: isFake 
                    ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                    : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                  child: Image.asset(
                    'assets/images/face.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isFake ? Colors.grey : const Color(0xFFFFD54F),
                      child: const Center(
                        child: Text('😂', style: TextStyle(fontSize: 70)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
