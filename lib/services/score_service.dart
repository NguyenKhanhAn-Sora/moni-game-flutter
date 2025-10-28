import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/score_model.dart';

class ScoreService {
  static const String _keyPrefix = 'scores_';

  Future<void> saveScore(String mode, int moves) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$mode';

    List<ScoreModel> scores = await getScores(mode);

    scores.add(ScoreModel(mode: mode, moves: moves, date: DateTime.now()));

    scores.sort((a, b) => a.moves.compareTo(b.moves));

    if (scores.length > 10) {
      scores = scores.sublist(0, 10);
    }

    final jsonList = scores.map((s) => s.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<List<ScoreModel>> getScores(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$mode';
    final jsonString = prefs.getString(key);

    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ScoreModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<ScoreModel?> getBestScore(String mode) async {
    final scores = await getScores(mode);
    if (scores.isEmpty) return null;
    return scores.first;
  }

  Future<void> clearScores(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$mode';
    await prefs.remove(key);
  }

  Future<void> clearAllScores() async {
    final prefs = await SharedPreferences.getInstance();
    final modes = ['2x2', '4x4', '6x6', '6x8'];
    for (var mode in modes) {
      await prefs.remove('$_keyPrefix$mode');
    }
  }

  Future<bool> isTopScore(String mode, int moves) async {
    final scores = await getScores(mode);
    if (scores.length < 10) return true;
    return moves < scores.last.moves;
  }
}
