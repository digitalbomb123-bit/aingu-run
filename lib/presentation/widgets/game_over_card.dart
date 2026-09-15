import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';
import '../../controllers/game_controller.dart';

class GameOverCard extends StatefulWidget {
  final GameController controller;
  final int? challengeScore;
  final VoidCallback onPlayAgain;
  final VoidCallback onGoHome;

  const GameOverCard({
    super.key,
    required this.controller,
    required this.challengeScore,
    required this.onPlayAgain,
    required this.onGoHome,
  });

  @override
  State<GameOverCard> createState() => _GameOverCardState();
}

class _GameOverCardState extends State<GameOverCard> {
  late ConfettiController _confettiController;
  bool isNewHighScore = false;
  bool beatChallenge = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    if (widget.controller.score > widget.controller.bestScore) {
      isNewHighScore = true;
      _confettiController.play();
    } else if (widget.challengeScore != null && widget.controller.score > widget.challengeScore!) {
      beatChallenge = true;
      _confettiController.play();
    } else if (widget.controller.wonAchievement) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _getFunnyTitle() {
    double secs = widget.controller.survivalSeconds;
    if (secs < 5) return "BRO DIDN'T EVEN RUN 💀";
    if (secs < 10) return "AINGU SPEEDRUN ANY% 😂";
    if (secs < 20) return "At Least You Tried";
    if (secs < 30) return "Pretty Decent Escape Artist";
    if (secs < 45) return "AINGU'S Biggest Problem 😭";
    if (secs < 60) return "ABSOLUTE SURVIVOR 🔥";
    return "AINGU SURVIVOR 🏆";
  }

  Future<void> _shareScore() async {
    String text = "I survived Aingu for ${widget.controller.survivalSeconds.toStringAsFixed(1)} seconds 😂\n";
    if (widget.challengeScore != null && widget.controller.score > widget.challengeScore!) {
      text += "I beat your ${widget.challengeScore! / 10} second score.\n";
      text += "Try to beat me!\n";
    } else {
      text += "Can you survive longer?\n";
      text += "🏃 AINGU RUN\n";
    }
    
    final currentUrl = Uri.base.origin + Uri.base.path;
    final shareUrl = "$currentUrl?challenge=${widget.controller.score}";
    
    text += shareUrl;

    try {
      await Share.share(text);
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Score copied! Send it to your friends 😂')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "AINGU GOT YOU 💀",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                Text(
                  "YOU SURVIVED",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  "${widget.controller.survivalSeconds.toStringAsFixed(1)} SECONDS",
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  "SCORE",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  "${widget.controller.score}",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  _getFunnyTitle(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                if (widget.challengeScore != null) ...[
                  if (widget.controller.score > widget.challengeScore!)
                    Text(
                      "🔥 YOU BEAT THE CHALLENGE!",
                      style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  else
                    const Text(
                      "😂 AINGU GOT YOU",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  const SizedBox(height: 16),
                ],

                if (isNewHighScore)
                  const Text(
                    "🔥 NEW HIGH SCORE 🔥",
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: widget.onPlayAgain,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('PLAY AGAIN 🔄'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _shareScore,
                  icon: const Icon(Icons.share),
                  label: const Text('SHARE MY SCORE 📤'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: widget.onGoHome,
                  child: const Text('HOME'),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ),
      ],
    );
  }
}
