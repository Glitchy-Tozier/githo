import 'package:githo/models/habitPlanModel.dart';

class DefaultHabitPlans {
  static final List<HabitPlan> habitPlanList = [
    HabitPlan(
      isActive: false,
      goal: "Consistently go jogging",
      requiredReps: 1,
      steps: [
        "Dress up and step outside on the street. Then go back and do whatever you want to do.",
        "Take a walk around your house/building",
        "Take a walk spanning a 3-5 buildings",
        "Jog around 3-5 buildings",
        "Go jogging. Well done."
      ],
      comments: [
        "Dress up in your running-gear for each challenge, even for the first one.",
        "Whatever step you're on, don't overdo it. We want to go jogging CONSISTENTLY, not twice and then have a hurting foot for a week."
      ],
      trainingTimeIndex: 1,
      requiredTrainings: 6,
      requiredTrainingPeriods: 1,
      lastChanged: DateTime.now(),
    ),
    HabitPlan(
      isActive: false,
      goal: "Talk to anybody, anytime",
      requiredReps: 2,
      steps: [
        "Make eye-contact with a stranger (no matter how long)",
        "Greet a passerby",
        "Ask for the time",
        "Ask for directions to a landmark/location",
        "Give a compliment",
        "Ask a simple question about the other Person (For example: \"Where did you get your headphones?\")",
        "Give a compliment, then don't walk on. After they say something, reply. (After your reply, you may run away, screaming in terror.)",
        "Make small-talk about anything"
      ],
      comments: ["Approach one male and one female"],
      trainingTimeIndex: 1,
      requiredTrainings: 5,
      requiredTrainingPeriods: 2,
      lastChanged: DateTime.now(),
    ),
  ];
}
