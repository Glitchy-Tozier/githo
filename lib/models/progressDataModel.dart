class ProgressData {
  DateTime lastActiveDate;
  DateTime currentStartingDate;
  int completedReps;
  int completedTrainings;
  int completedTrainingPeriods;

  ProgressData({
    required this.currentStartingDate,
    required this.lastActiveDate,
    required this.completedReps,
    required this.completedTrainings,
    required this.completedTrainingPeriods,
  });

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();

    map["lastActiveDate"] = lastActiveDate.toString();
    map["currentStartingDate"] = currentStartingDate.toString();
    map["completedReps"] = completedReps;
    map["completedTrainings"] = completedTrainings;
    map["completedTrainingPeriods"] = completedTrainingPeriods;

    return map;
  }

  factory ProgressData.fromMap(Map<String, dynamic> map) {
    return ProgressData(
      lastActiveDate: DateTime.parse(map["lastActiveDate"]),
      currentStartingDate: DateTime.parse(map["currentStartingDate"]),
      completedReps: map["completedReps"],
      completedTrainings: map["completedTrainings"],
      completedTrainingPeriods: map["completedTrainingPeriods"],
    );
  }
}
