import 'dart:math';
import 'package:flutter/material.dart';
import '../../controllers/game_controller.dart';
import 'game_screen.dart';

class GameHomeScreen extends StatefulWidget {
  final int? challengeScore;
  const GameHomeScreen({super.key, this.challengeScore});

  @override
  State<GameHomeScreen> createState() => _GameHomeScreenState();
}

class _GameHomeScreenState extends State<GameHomeScreen>
    with TickerProviderStateMixin {
  late GameController _controller;
  final TextEditingController _nameController = TextEditingController();
  final List<String> _subtitles = [
    "Aingu is coming. RUN!",
    "How long can you survive?",
    "Whatever you do, don't stop.",
    "Aingu has entered the chat 💀",
    "Run first. Ask questions later.",
    "Good luck bro 😂"
  ];
  late String _currentSubtitle;

  @override
  void initState() {
    super.initState();
    _controller = GameController(this);
    _currentSubtitle = _subtitles[Random().nextInt(_subtitles.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isPlaying || _controller.isGameOver) {
          return GameScreen(
            controller: _controller,
            challengeScore: widget.challengeScore,
            onGoHome: () {
              setState(() {
                _controller.isGameOver = false;
                _controller.isPlaying = false;
              });
            },
          );
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '🏃 AINGU RUN 💀',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 48,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentSubtitle,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: 150,
                        height: 150,
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
                        child: Image.asset(
                          'assets/images/aingu.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: const Color(0xFFFFD54F),
                            child: const Center(
                              child: Text('💀', style: TextStyle(fontSize: 80)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'How long can you survive?',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      if (widget.challengeScore != null) ...[
                        Text(
                          'CAN YOU BEAT THIS? 😂',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Someone survived Aingu for:\n${widget.challengeScore! / 10} seconds',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                      ],
                      SizedBox(
                        width: 250,
                        child: TextField(
                          controller: _nameController,
                          onChanged: (val) {
                            _controller.playerName = val;
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter your name...',
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (widget.challengeScore != null)
                        ElevatedButton(
                          onPressed: _controller.playerName.trim().isEmpty
                              ? null
                              : _controller.startGame,
                          child: const Text('BEAT THE SCORE 🏃'),
                        )
                      else
                        ElevatedButton(
                          onPressed: _controller.playerName.trim().isEmpty
                              ? null
                              : _controller.startGame,
                          child: const Text('RUN! 🏃'),
                        ),
                      if (_controller.scoreboard.isNotEmpty &&
                          widget.challengeScore == null) ...[
                        const SizedBox(height: 32),
                        Text(
                          '🏆 SCOREBOARD 🏆',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 300,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: _controller.scoreboard
                                .asMap()
                                .entries
                                .map((entry) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${entry.key + 1}. ${entry.value.name}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${entry.value.score}',
                                      style: const TextStyle(
                                          color: Colors.amber,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
