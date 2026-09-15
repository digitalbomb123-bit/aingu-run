import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/game_controller.dart';
import '../widgets/game_over_card.dart';
import '../widgets/running_stickman.dart';

class GameScreen extends StatefulWidget {
  final GameController controller;
  final int? challengeScore;
  final VoidCallback onGoHome;

  const GameScreen({
    super.key,
    required this.controller,
    required this.challengeScore,
    required this.onGoHome,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    double dx = 0;
    double dy = 0;
    
    if (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.keyW) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      dy -= 1;
    }
    if (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.keyS) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      dy += 1;
    }
    if (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.keyA) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      dx -= 1;
    }
    if (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.keyD) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      dx += 1;
    }

    // Normalize
    if (dx != 0 && dy != 0) {
      dx *= 0.7071;
      dy *= 0.7071;
    }

    widget.controller.setKeyboardVector(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: Scaffold(
        body: SafeArea(
          child: widget.controller.isGameOver
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GameOverCard(
                      controller: widget.controller,
                      challengeScore: widget.challengeScore,
                      onPlayAgain: widget.controller.startGame,
                      onGoHome: widget.onGoHome,
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    widget.controller.updateScreenSize(Size(constraints.maxWidth, constraints.maxHeight));

                    return MouseRegion(
                      onHover: (event) {
                        widget.controller.setMouseTarget(event.localPosition.dx, event.localPosition.dy);
                      },
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          widget.controller.setMouseTarget(details.localPosition.dx, details.localPosition.dy);
                        },
                        onPanDown: (details) {
                          widget.controller.setMouseTarget(details.localPosition.dx, details.localPosition.dy);
                        },
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            // Background
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/background.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                            
                            Positioned(
                              left: widget.controller.playerPos.x - widget.controller.playerRadius,
                              top: widget.controller.playerPos.y - widget.controller.playerRadius,
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..rotateY((widget.controller.playerRotation.abs() > pi / 2) ? pi : 0),
                                child: RunningStickman(
                                  size: widget.controller.playerRadius * 2,
                                  isRunning: widget.controller.isPlayerMoving,
                                ),
                              ),
                            ),

                            // Aingu
                            Positioned(
                              left: widget.controller.ainguPos.x - widget.controller.ainguRadius,
                              top: widget.controller.ainguPos.y - widget.controller.ainguRadius,
                              child: Transform.rotate(
                                angle: widget.controller.ainguRotation,
                                child: Container(
                                  width: widget.controller.ainguRadius * 2,
                                  height: widget.controller.ainguRadius * 2,
                                  child: Image.asset(
                                    widget.controller.survivalSeconds > 10 
                                        ? 'assets/images/face.png' 
                                        : 'assets/images/aingu.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),

                            // Fake Aingu
                            if (widget.controller.hasFakeAingu && widget.controller.fakeAinguPos != null)
                              Positioned(
                                left: widget.controller.fakeAinguPos!.x - widget.controller.ainguRadius,
                                top: widget.controller.fakeAinguPos!.y - widget.controller.ainguRadius,
                                child: Opacity(
                                  opacity: 0.5,
                                  child: Container(
                                    width: widget.controller.ainguRadius * 2,
                                    height: widget.controller.ainguRadius * 2,
                                    child: Image.asset(
                                      widget.controller.survivalSeconds > 10
                                          ? 'assets/images/face.png'
                                          : 'assets/images/aingu.png',
                                      fit: BoxFit.contain,
                                      color: Colors.grey,
                                      colorBlendMode: BlendMode.saturation,
                                    ),
                                  ),
                                ),
                              ),

                            // Floating messages
                            if (widget.controller.currentMessage != null)
                              Positioned(
                                top: constraints.maxHeight * 0.2,
                                left: 0,
                                right: 0,
                                child: Text(
                                  widget.controller.currentMessage!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              
                            // Warning Shake/Pulse
                            if (widget.controller.warningMessage != null)
                              Positioned(
                                bottom: constraints.maxHeight * 0.2,
                                left: 0,
                                right: 0,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 1.0, end: 1.2),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: Text(
                                        widget.controller.warningMessage!,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                  onEnd: () {
                                    // A simple continuous pulse trick using a stateful widget would be better, but this works for a quick pulse effect.
                                  },
                                ),
                              ),

                            // HUD
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TIME: ${widget.controller.survivalSeconds.toStringAsFixed(1)}s',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(
                                    'SCORE: ${widget.controller.score}',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  if (widget.challengeScore != null)
                                    Text(
                                      'CHALLENGE: ${widget.challengeScore! / 10}s',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                    ),
                                ],
                              ),
                            ),
                            
                            // Virtual Joystick (only on touch devices, but we'll show it generally bottom left for this demo if screen width is narrow, or just let it exist)
                            // We can use a simple custom joystick or an invisible gesture detector overlay.
                            // Actually, onPanUpdate on the whole screen works as "touch to move towards".
                            // For a real joystick, we would add a UI element here.
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
