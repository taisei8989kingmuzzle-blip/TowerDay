class TowerDay {
  final String date;
  final String feeling;
  final String note;
  final int screenTimeMinutes;
  final int goalMinutes;

  TowerDay({
    required this.date,
    required this.feeling,
    required this.note,
    required this.screenTimeMinutes,
    required this.goalMinutes,
  });

  Map <String, dynamic> toJson() {
    return {
      'date': date,
      'feeling': feeling,
      'note': note,
      'screenTimeMinutes': screenTimeMinutes,
      'goalMinutes': goalMinutes,
    };

  }

  factory TowerDay.fromJson(Map<String, dynamic> json) {
    return TowerDay(
      date: json['date'] as String,
      feeling: json['feeling'] as String,
      note: json['note'] as String,
      screenTimeMinutes: json['screenTimeMinutes'] as int, 
      goalMinutes: json['goalMinutes'] as int,
    );
  }
}