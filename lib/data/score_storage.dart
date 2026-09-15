import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreEntry {
  final String name;
  final int score;

  ScoreEntry({required this.name, required this.score});

  Map<String, dynamic> toJson() => {'name': name, 'score': score};
  
  factory ScoreEntry.fromJson(Map<String, dynamic> json) {
    return ScoreEntry(
      name: json['name'] ?? 'Unknown',
      score: json['score'] ?? 0,
    );
  }
}

class ScoreStorage {
  static const String _bestScoreKey = 'best_score';
  static const String _scoreboardKey = 'scoreboard';
  
  static Future<int> getBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreKey) ?? 0;
  }
  
  static Future<void> saveBestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = prefs.getInt(_bestScoreKey) ?? 0;
    if (score > currentBest) {
      await prefs.setInt(_bestScoreKey, score);
    }
  }

  static Future<List<ScoreEntry>> getScoreboard() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_scoreboardKey);
    if (jsonStr != null) {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((e) => ScoreEntry.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  static Future<void> saveScore(String name, int score) async {
    final prefs = await SharedPreferences.getInstance();
    List<ScoreEntry> scores = await getScoreboard();
    scores.add(ScoreEntry(name: name.isEmpty ? 'Anonymous' : name, score: score));
    // Sort descending
    scores.sort((a, b) => b.score.compareTo(a.score));
    // Keep top 10
    if (scores.length > 10) {
      scores = scores.sublist(0, 10);
    }
    await prefs.setString(_scoreboardKey, jsonEncode(scores.map((e) => e.toJson()).toList()));
    
    // Also save best score for backward compatibility or simple high score checking
    await saveBestScore(score);
  }
}
