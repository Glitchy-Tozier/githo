class DataShortcut {
  // Contains some useful, regularly used values.

  static const List<String> timeFrames = [
    "hour",
    "day",
    "week",
    "month",
  ];
  static const List<String> adjectiveTimeFrames = [
    "hourly",
    "daily",
    "weekly",
    "monthly",
  ];
  static const List<String> nextTimeFrameNames = [
    "the next hour",
    "tomorrow",
    "the next week",
    "the next month",
  ];
  static const List<int> maxTrainings = [24, 7, 4];

  static const List<int> trainingDurationInHours = [
    1,
    24,
    24 * 7,
  ];
  static const List<int> periodDurationInHours = [
    24,
    24 * 7,
    24 * 7 * 4,
  ];

  static const bool testing = false;
}
