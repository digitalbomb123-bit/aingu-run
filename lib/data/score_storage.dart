import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('scores')
          .orderBy('score', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => ScoreEntry.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching scores: $e");
      return [];
    }
  }

  static Future<void> saveScore(String name, int score) async {
    try {
      final playerName = name.isEmpty ? 'Anonymous' : name;
      await FirebaseFirestore.instance.collection('scores').add({
        'name': playerName,
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await saveBestScore(score);
    } catch (e) {
      print("Error saving score: $e");
    }
  }
}
