class ScoreModel {
  final String mode;
  final int moves;
  final DateTime date;

  ScoreModel({required this.mode, required this.moves, required this.date});

  Map<String, dynamic> toJson() {
    return {'mode': mode, 'moves': moves, 'date': date.toIso8601String()};
  }

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      mode: json['mode'] as String,
      moves: json['moves'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }

  @override
  String toString() {
    return 'ScoreModel(mode: $mode, moves: $moves, date: $date)';
  }
}
