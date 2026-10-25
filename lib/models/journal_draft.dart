class JournalDraft {
  final String date;
  final String feeling;
  final String note;
  final int goalMinutes;

  const JournalDraft({
    required this.date,
    required this.feeling,
    required this.note,
    required this.goalMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'feeling': feeling,
      'note': note,
      'goalMinutes': goalMinutes,
    };
  }

  factory JournalDraft.fromJson(Map<String, dynamic> json) {
    return JournalDraft(
      date: json['date'] as String,
      feeling: json['feeling'] as String,
      note: json['note'] as String,
      goalMinutes: json['goalMinutes'] as int,
    );
  }
}