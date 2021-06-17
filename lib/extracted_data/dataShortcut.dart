class DataShortcut {
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

  static const List<int> repDurationInHours = [
    1,
    24,
    24 * 7,
  ];
  static const List<int> stepDurationInHours = [
    24,
    24 * 7,
    24 * 7 * 4,
  ];

  static const testing = true;
}
