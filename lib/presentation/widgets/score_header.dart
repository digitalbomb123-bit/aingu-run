import 'package:flutter/material.dart';

class ScoreHeader extends StatelessWidget {
  final int score;
  final int time;
  final int combo;
  final int? challengeScore;

  const ScoreHeader({
    super.key,
    required this.score,
    required this.time,
    required this.combo,
    this.challengeScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatColumn(context, "SCORE", "$score"),
          if (challengeScore != null) ...[
            const SizedBox(width: 16),
            _buildStatColumn(context, "CHALLENGE", "$challengeScore", color: Colors.orange),
          ],
          if (combo > 1) ...[
            const SizedBox(width: 16),
            _buildStatColumn(context, "COMBO", "x$combo", color: Colors.redAccent),
          ],
          const SizedBox(width: 24),
          Container(width: 2, height: 40, color: Colors.grey[300]),
          const SizedBox(width: 24),
          _buildStatColumn(context, "TIME", "$time", 
            color: time <= 5 ? Colors.red : Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value, {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color ?? Colors.black87,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
