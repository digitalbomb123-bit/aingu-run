import 'package:flutter/material.dart';

class ReactionText extends StatelessWidget {
  final String text;

  const ReactionText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -80 * value), // floats up
          child: Opacity(
            opacity: 1.0 - (value * 0.8), // fades out slightly
            child: Text(
              text,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.redAccent,
                fontWeight: FontWeight.w900,
                fontSize: 32,
                shadows: [
                  const Shadow(
                    color: Colors.white,
                    blurRadius: 10,
                  ),
                  const Shadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
