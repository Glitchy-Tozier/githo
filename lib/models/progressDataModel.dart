class ProgressData {
  DateTime lastActiveDate;
  DateTime challengeStartingDate;
  int completedReps;
  int completedTrainings;
  int level;

  ProgressData({
    required this.challengeStartingDate,
    required this.lastActiveDate,
    required this.completedReps,
    required this.completedTrainings,
    required this.level,
  });

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();

    map["lastActiveDate"] = lastActiveDate.toString();
    map["challengeStartingDate"] = challengeStartingDate.toString();
    map["completedReps"] = completedReps;
    map["completedTrainings"] = completedTrainings;
    map["level"] = level;

    return map;
  }

  factory ProgressData.fromMap(Map<String, dynamic> map) {
    return ProgressData(
      lastActiveDate: DateTime.parse(map["lastActiveDate"]),
      challengeStartingDate: DateTime.parse(map["challengeStartingDate"]),
      completedReps: map["completedReps"],
      completedTrainings: map["completedTrainings"],
      level: map["level"],
    );
  }
}
