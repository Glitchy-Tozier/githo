/* 
 * Githo – An app that helps you gradually form long-lasting habits.
 * Copyright (C) 2021 Florian Thaler
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:githo/models/habit_plan.dart';

/// Defines the habit-plans that will be available when first starting the app.
class DefaultHabitPlans {
  static final List<HabitPlan> habitPlanList = <HabitPlan>[
    HabitPlan(
      isActive: false,
      fullyCompleted: false,
      habit: 'Consistently go jogging',
      requiredReps: 1,
      levels: const <String>[
        '''
Dress up and step outside on the street. 
Then go back and do whatever you want to do.''',
        'Take a walk around your house/building',
        'Take a walk spanning 3-5 buildings',
        'Jog around 3-5 buildings',
        'Go jogging. Well done.'
      ],
      comments: const <String>[
        '''
Dress up in your running-gear for each challenge, even for the first one.''',
        '''
Whatever level you're on, don't overdo it. 
We want to go jogging CONSISTENTLY, not twice and then have a hurting foot for a week.'''
      ],
      trainingTimeIndex: 1,
      requiredTrainings: 6,
      requiredTrainingPeriods: 1,
      lastChanged: DateTime(2019),
    ),
    HabitPlan(
      isActive: false,
      fullyCompleted: false,
      habit: 'Talk to anybody, anytime',
      requiredReps: 2,
      levels: const <String>[
        'Make eye-contact with a stranger (no matter how short)',
        'Greet a passerby',
        'Ask for the time',
        'Ask for directions to a landmark/location',
        'Give a compliment',
        '''
Ask a simple question about the other Person 
(For example: 'Where did you get your headphones?')''',
        '''
Give a compliment, then don't walk on. After they say something, reply. 
(After your reply, you may run away, screaming in terror.)''',
        'Make small-talk about anything'
      ],
      comments: const <String>['Approach one male and one female'],
      trainingTimeIndex: 1,
      requiredTrainings: 5,
      requiredTrainingPeriods: 2,
      lastChanged: DateTime(2015),
    ),
  ];

  /// THIS IS ONLY TO HELP WITH DEBUGGING AND TESTING.
  // ALL NORMAL HABITPLANS GO ABOVE!
  static final List<HabitPlan> testingHabitPlanList = <HabitPlan>[
    HabitPlan(
      isActive: false,
      fullyCompleted: false,
      habit: 'Testing without errors',
      requiredReps: 1,
      levels: const <String>[
        'This is level oneeey',
        'This is level twough',
        'This is level tré',
        'This is level four',
        'This is level faive',
      ],
      comments: const <String>[
        '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit, 
sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.''',
        '''
Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium 
doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo 
inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.''',
      ],
      trainingTimeIndex: 1,
      requiredTrainings: 1,
      requiredTrainingPeriods: 3,
      lastChanged: DateTime(0),
    ),
    HabitPlan(
      isActive: false,
      fullyCompleted: false,
      habit: 'Testing without (t)errors',
      requiredReps: 3,
      levels: const <String>[
        'This is level oneeey',
        'This is level twough',
        'This is level tré',
        'This is level four',
        'This is level faive',
      ],
      comments: const <String>[
        '"t" as in hours',
        'Also, this one needs 3 reps',
      ],
      trainingTimeIndex: 0,
      requiredTrainings: 1,
      requiredTrainingPeriods: 3,
      lastChanged: DateTime(0),
    ),
  ];
}
