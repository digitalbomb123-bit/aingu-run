import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../data/score_storage.dart';

class GameController extends ChangeNotifier {
  Ticker? _ticker;
  Duration _lastTime = Duration.zero;
  Size _screenSize = Size.zero;
  final TickerProvider vsync;

  // Game State
  bool isPlaying = false;
  bool isGameOver = false;
  double survivalSeconds = 0.0;
  int bestScore = 0;
  List<ScoreEntry> scoreboard = [];
  String playerName = '';
  int? challengeScore;
  bool wonAchievement = false;

  // Positions (pixels)
  Point<double> playerPos = const Point(0, 0);
  Point<double> ainguPos = const Point(0, 0);
  
  Point<double> targetPlayerPos = const Point(-1, -1);
  Point<double> joystickDelta = const Point(0, 0);
  Point<double> keyboardDelta = const Point(0, 0);

  // Sizes & Speeds
  final double playerRadius = 25.0;
  double ainguBaseRadius = 50.0;
  double ainguRadius = 50.0;
  double ainguScale = 1.0;

  double ainguSpeedMultiplier = 1.0;
  double playerSpeed = 500.0; // px/sec
  double ainguBaseSpeed = 150.0; // px/sec

  // Visuals & Events
  String? currentMessage;
  String? warningMessage;
  bool isScreenShaking = false;
  bool hasFakeAingu = false;
  Point<double>? fakeAinguPos;
  double ainguRotation = 0.0;

  double _eventTimer = 0.0;
  int _lastDifficultyLevel = 0;
  bool _needsPositionInitialization = false;
  final Random _random = Random();
  final AudioPlayer bgmPlayer = AudioPlayer();
  final AudioPlayer sfxPlayer = AudioPlayer();

  GameController(this.vsync) {
    _initBestScore();
    _initAudio();
  }

  void _initAudio() {
    bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  int get score => (survivalSeconds * 10).floor();

  Future<void> _initBestScore() async {
    bestScore = await ScoreStorage.getBestScore();
    scoreboard = await ScoreStorage.getScoreboard();
    notifyListeners();
  }

  void updateScreenSize(Size size) {
    _screenSize = size;
    if (!isPlaying && !isGameOver) {
      playerPos = Point(size.width / 2, size.height / 2);
      targetPlayerPos = playerPos;
    } else if (_needsPositionInitialization) {
      _initializePositions();
      _needsPositionInitialization = false;
    }
  }

  void _initializePositions() {
    double spawnX = _random.nextBool() ? 50.0 : _screenSize.width - 50.0;
    double spawnY = _random.nextBool() ? 50.0 : _screenSize.height - 50.0;
    ainguPos = Point(spawnX, spawnY);
    playerPos = Point(_screenSize.width / 2, _screenSize.height / 2);
    targetPlayerPos = playerPos;
  }

  void startGame() {
    isPlaying = true;
    isGameOver = false;
    survivalSeconds = 0.0;
    wonAchievement = false;
    ainguSpeedMultiplier = 1.0;
    _lastDifficultyLevel = 0;
    currentMessage = null;
    warningMessage = null;
    isScreenShaking = false;
    hasFakeAingu = false;
    ainguScale = 1.0;
    ainguRadius = ainguBaseRadius;

    // Spawn Aingu far from player
    if (_screenSize != Size.zero) {
      _initializePositions();
    } else {
      _needsPositionInitialization = true;
    }

    _lastTime = Duration.zero;
    _ticker?.dispose();
    _ticker = vsync.createTicker(_tick)..start();
    
    // Play background music
    bgmPlayer.play(AssetSource('sounds/bg_music.mp3'));
    
    notifyListeners();
  }

  void _tick(Duration elapsed) {
    if (_lastTime == Duration.zero) {
      _lastTime = elapsed;
      return;
    }
    double dt = (elapsed - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = elapsed;

    if (!isPlaying) return;

    survivalSeconds += dt;
    _updateDifficulty();
    _updatePlayer(dt);
    _updateAingu(dt);
    _checkEvents(dt);
    _checkCollisions();
    _updateWarnings();

    notifyListeners();
  }

  void _updateDifficulty() {
    if (wonAchievement) return; // Stop difficulty at 60s

    int currentLevel = (survivalSeconds / 10).floor();
    if (currentLevel > _lastDifficultyLevel) {
      _lastDifficultyLevel = currentLevel;
      
      switch (currentLevel) {
        case 1:
          ainguSpeedMultiplier = 1.15;
          _showMessage("AINGU GOT FASTER 💀");
          break;
        case 2:
          ainguSpeedMultiplier = 1.3;
          _showMessage("AINGU IS ANGRY 😭");
          break;
        case 3:
          ainguSpeedMultiplier = 1.5;
          _showMessage("AINGU GOT FASTER 💀"); // Reusing for variety
          break;
        case 4:
          ainguSpeedMultiplier = 1.7;
          _showMessage("AINGU HAS ENTERED FINAL FORM 💀");
          break;
        case 5:
          ainguSpeedMultiplier = 2.0;
          _showMessage("AINGU HAS ENTERED FINAL FORM 💀");
          break;
        case 6:
          wonAchievement = true;
          _showMessage("YOU SURVIVED AINGU! 🏆😂", duration: 5.0);
          break;
        default:
          if (currentLevel > 6) {
             ainguSpeedMultiplier += 0.05;
          }
      }
    }
  }

  bool isPlayerMoving = false;
  double playerRotation = 0.0;

  void _updatePlayer(double dt) {
    Point<double> velocity = const Point(0, 0);

    // 1. Keyboard has highest priority
    if (keyboardDelta.x != 0 || keyboardDelta.y != 0) {
      velocity = keyboardDelta;
      targetPlayerPos = const Point(-1, -1); // Reset target
    } 
    // 2. Joystick
    else if (joystickDelta.x != 0 || joystickDelta.y != 0) {
      velocity = joystickDelta;
      targetPlayerPos = const Point(-1, -1);
    }
    // 3. Mouse target
    else if (targetPlayerPos.x >= 0 && targetPlayerPos.y >= 0) {
      double dx = targetPlayerPos.x - playerPos.x;
      double dy = targetPlayerPos.y - playerPos.y;
      double dist = sqrt(dx * dx + dy * dy);
      if (dist > 5) {
        velocity = Point(dx / dist, dy / dist);
      }
    }

    if (velocity.x != 0 || velocity.y != 0) {
      isPlayerMoving = true;
      playerRotation = atan2(velocity.y, velocity.x);
      
      double newX = playerPos.x + velocity.x * playerSpeed * dt;
      double newY = playerPos.y + velocity.y * playerSpeed * dt;
      
      // Clamp to screen
      newX = newX.clamp(playerRadius, _screenSize.width - playerRadius);
      newY = newY.clamp(playerRadius, _screenSize.height - playerRadius);
      
      playerPos = Point(newX, newY);
    } else {
      isPlayerMoving = false;
    }
  }

  void _updateAingu(double dt) {
    double dx = playerPos.x - ainguPos.x;
    double dy = playerPos.y - ainguPos.y;
    double dist = sqrt(dx * dx + dy * dy);

    if (dist > 0) {
      double speed = ainguBaseSpeed * ainguSpeedMultiplier;
      double moveX = (dx / dist) * speed * dt;
      double moveY = (dy / dist) * speed * dt;
      
      double newX = (ainguPos.x + moveX).clamp(ainguRadius, _screenSize.width - ainguRadius);
      double newY = (ainguPos.y + moveY).clamp(ainguRadius, _screenSize.height - ainguRadius);
      
      ainguPos = Point(newX, newY);
      
      // Rotate Aingu towards player slightly for effect
      ainguRotation = atan2(dy, dx);
    }
  }

  void _checkEvents(double dt) {
    _eventTimer -= dt;
    if (_eventTimer <= 0) {
      _eventTimer = 5.0 + _random.nextDouble() * 10.0; // 5-15s between events
      if (survivalSeconds > 10) {
        _triggerRandomEvent();
      }
    }
  }

  void _triggerRandomEvent() {
    int event = _random.nextInt(5);
    switch (event) {
      case 0:
        // Teleport
        double spawnX = _random.nextBool() ? 50.0 : _screenSize.width - 50.0;
        double spawnY = _random.nextBool() ? 50.0 : _screenSize.height - 50.0;
        ainguPos = Point(spawnX, spawnY);
        _showMessage("HE'S CHEATING 💀");
        break;
      case 1:
        // Fake Aingu
        hasFakeAingu = true;
        fakeAinguPos = Point(_random.nextDouble() * _screenSize.width, _random.nextDouble() * _screenSize.height);
        _showMessage("WHICH ONE IS REAL? 😂");
        Future.delayed(const Duration(seconds: 4), () {
          hasFakeAingu = false;
        });
        break;
      case 2:
        // Huge
        ainguScale = 2.0;
        ainguRadius = ainguBaseRadius * 1.5;
        _showMessage("WHY IS HE SO BIG?!");
        Future.delayed(const Duration(seconds: 4), () {
          ainguScale = 1.0;
          ainguRadius = ainguBaseRadius;
        });
        break;
      case 3:
        // Tiny
        ainguScale = 0.5;
        ainguRadius = ainguBaseRadius * 0.5;
        _showMessage("WHERE DID AINGU GO?");
        Future.delayed(const Duration(seconds: 4), () {
          ainguScale = 1.0;
          ainguRadius = ainguBaseRadius;
        });
        break;
      case 4:
        // Speed boost
        double oldMultiplier = ainguSpeedMultiplier;
        ainguSpeedMultiplier += 1.0;
        _showMessage("OH NO 💀");
        Future.delayed(const Duration(seconds: 3), () {
          ainguSpeedMultiplier = oldMultiplier;
        });
        break;
    }
  }

  void _checkCollisions() {
    double dx = playerPos.x - ainguPos.x;
    double dy = playerPos.y - ainguPos.y;
    double dist = sqrt(dx * dx + dy * dy);

    if (dist < (playerRadius + ainguRadius * 0.8)) {
      _gameOver();
    }
  }

  void _updateWarnings() {
    double dx = playerPos.x - ainguPos.x;
    double dy = playerPos.y - ainguPos.y;
    double dist = sqrt(dx * dx + dy * dy);

    if (dist < 150) {
      warningMessage = "RUN BRO RUN 💀";
      isScreenShaking = true;
    } else if (dist < 300) {
      warningMessage = "AINGU IS GETTING CLOSE 👀";
      isScreenShaking = false;
    } else {
      warningMessage = null;
      isScreenShaking = false;
    }
  }

  void _gameOver() {
    isPlaying = false;
    isGameOver = true;
    _ticker?.stop();
    isScreenShaking = false;
    
    // Pause background music and play scream
    bgmPlayer.pause();
    sfxPlayer.play(AssetSource('sounds/scream.mp3'));
    
    ScoreStorage.saveScore(playerName, score);
    _initBestScore(); // Refresh scoreboard
  }

  void _showMessage(String text, {double duration = 2.0}) {
    currentMessage = text;
    Future.delayed(Duration(milliseconds: (duration * 1000).toInt()), () {
      if (currentMessage == text) {
        currentMessage = null;
        notifyListeners();
      }
    });
  }

  void setKeyboardVector(double dx, double dy) {
    keyboardDelta = Point(dx, dy);
  }

  void setJoystickVector(double dx, double dy) {
    joystickDelta = Point(dx, dy);
  }

  void setMouseTarget(double x, double y) {
    targetPlayerPos = Point(x, y);
  }

  @override
  void dispose() {
    bgmPlayer.dispose();
    sfxPlayer.dispose();
    _ticker?.dispose();
    super.dispose();
  }
}
