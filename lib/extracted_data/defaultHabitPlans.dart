import 'package:githo/models/habitPlan_model.dart';

class DefaultHabitPlans {
  static final List<HabitPlan> habitPlanList = [
    HabitPlan(
      isActive: false,
      goal: "Talk strangers whenever you want",
      reps: 2,
      challenges: [
        "Make eye-contact while passing (no matter how long)",
        "Greet a passerby",
        "Ask for the time",
        "Ask for directions to a landmark/location",
        "Give a compliment",
        "Ask a simple question about the other Person (For example: \"Where did you get your headphones?\")",
        "Give a compliment, then don't walk on. After they say something, reply. (After your reply, you may run away, screaming in terror.)",
        "Make small-talk about anything"
      ],
      rules: ["Approach one male and one female"],
      timeIndex: 1,
      activity: 5,
      requiredRepeats: 2,
    ),
    HabitPlan(
      isActive: false,
      goal: "Consistently go jogging",
      reps: 1,
      challenges: [
        "Dress up and step outside on the street. Then go back and do whatever you want to do.",
        "Take a walk around your house/building",
        "Take a walk spanning a 3-5 buildings",
        "Jog around 3-5 buildings",
        "Go jogging. Well done."
      ],
      rules: [
        "Dress up in your running-gear for each challenge, even for the first one.",
        "Whatever step you're on, don't overdo it. We want to go jogging CONSISTENTLY, not twice and then have a hurting foot for a week."
      ],
      timeIndex: 1,
      activity: 6,
      requiredRepeats: 1,
    )
  ];
}
