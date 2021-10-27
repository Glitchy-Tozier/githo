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

import 'package:flutter/material.dart';

import 'package:githo/config/custom_widget_themes.dart';
import 'package:githo/config/style_data.dart';
import 'package:githo/helpers/format_date.dart';
import 'package:githo/models/used_classes/training.dart';
import 'package:githo/models/used_classes/training_period.dart';
import 'package:githo/widgets/alert_dialogs/confirm_training_start.dart';
import 'package:githo/widgets/bottom_sheets/text_sheet.dart';
import 'package:githo/widgets/training_cards/active_training_card.dart';
import 'package:githo/widgets/training_cards/countdown_card.dart';
import 'package:githo/widgets/training_cards/gradient_training_card.dart';
import 'package:githo/widgets/training_cards/training_card.dart';

class PeriodListView extends StatefulWidget {
  /// Creates one of those horizontal training-listViews made out of cards.
  const PeriodListView({
    required this.trainingPeriod,
    required this.levelDescription,
    required this.activeCardKey,
  });

  final TrainingPeriod trainingPeriod;
  final String levelDescription;
  final GlobalKey activeCardKey;

  @override
  _PeriodListViewState createState() => _PeriodListViewState();
}

class _PeriodListViewState extends State<PeriodListView> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> listViewChildren = <Widget>[];
    double cardMarginRL = 6;
    int activeTrainingIndex = 9876543210;

    for (int i = 0; i < widget.trainingPeriod.trainings.length; i++) {
      final Training training = widget.trainingPeriod.trainings[i];

      const double textSize = 25;
      double cardWidth = 100;
      double cardHeight = 70;
      cardMarginRL = 6;

      final Color color;
      Color? shadowColor;
      final Widget child;

      if (widget.trainingPeriod.status == 'completed') {
        if (training.status == 'successful') {
          color = CardColors.successful;
        } else if (training.status == 'unsuccessful') {
          color = CardColors.unsuccessful;
        } else {
          color = CardColors.skipped;
        }
        child = const Icon(Icons.check_rounded);
      } else if (widget.trainingPeriod.status == 'waiting for start') {
        color = CardColors.waiting;
        if (i == 0) {
          cardWidth *= 1.3;
          cardHeight *= 1.3;
          void showWaitingSheet(final String remainingTime) =>
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) => TextSheet(
                  title: 'Waiting for training to start',
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Starting in ',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      TextSpan(
                        text: '$remainingTime\n',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      TextSpan(
                        text: '(On ${formatDate(training.startingDate)})\n\n',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      TextSpan(
                        text: 'To-do: ',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      TextSpan(
                        text: widget.levelDescription,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              );
          listViewChildren.add(
            CountdownCard(
              key: widget.activeCardKey,
              horizontalMargin: cardMarginRL,
              cardWidth: cardWidth,
              cardHeight: cardHeight,
              startingDate: training.startingDate,
              textSize: textSize,
              color: color,
              onTap: showWaitingSheet,
            ),
          );
          continue;
        } else {
          child = const Icon(Icons.lock_clock);
        }
      } else if (widget.trainingPeriod.status == 'active') {
        cardWidth *= 1.3;
        cardHeight *= 1.3;
        cardMarginRL *= 1.3;
        if (training.hasPassed) {
          if (training.status == 'successful') {
            color = CardColors.successful;
            child = Text(
              '${training.doneReps}/${training.requiredReps}',
              style: const TextStyle(
                fontSize: textSize * 1.3,
              ),
            );
          } else if (training.status == 'unsuccessful') {
            color = CardColors.unsuccessful;
            child = Text(
              '${training.doneReps}/${training.requiredReps}',
              style: const TextStyle(
                fontSize: textSize * 1.3,
              ),
            );
          } else {
            color = CardColors.skipped;
            child = const Text(
              'Skipped',
              style: TextStyle(
                fontSize: textSize,
              ),
            );
          }
        } else if (training.isNow) {
          activeTrainingIndex = i;

          cardWidth *= 1.3;
          cardHeight *= 1.3;

          if (training.status == 'ready') {
            void onConfirmation() {
              training.activate();
              setState(() {});
            }

            void onTap() => showDialog(
                  context: context,
                  builder: (BuildContext buildContext) {
                    return ConfirmTrainingStart(
                      title: 'Confirm Activation',
                      toDo: widget.levelDescription,
                      training: training,
                      onConfirmation: onConfirmation,
                    );
                  },
                );

            listViewChildren.add(
              GradientTrainingCard(
                key: widget.activeCardKey,
                horizontalMargin: cardMarginRL,
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                textSize: textSize,
                onTap: onTap,
              ),
            );
            continue;
          } else {
            listViewChildren.add(
              ActiveTrainingCard(
                key: widget.activeCardKey,
                training: training,
                horizontalMargin: cardMarginRL,
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                textSize: textSize,
              ),
            );
            continue;
          }
        } else {
          color = CardColors.waiting;
          if (i == activeTrainingIndex + 1) {
            listViewChildren.add(
              CountdownCard(
                horizontalMargin: cardMarginRL,
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                startingDate: training.startingDate,
                textSize: textSize,
                color: color,
              ),
            );
            continue;
          } else {
            child = const Icon(Icons.lock_clock);
          }
        }
      } else {
        color = CardColors.locked;
        shadowColor = Colors.black.withOpacity(0.5);
        child = const Icon(Icons.lock);
      }

      listViewChildren.add(
        TrainingCard(
          horizontalMargin: cardMarginRL,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          color: color,
          shadowColor: shadowColor,
          child: child,
        ),
      );
    }

    const ScrollPhysics physics = BouncingScrollPhysics();
    const Axis scrollDirection = Axis.horizontal;
    final EdgeInsetsGeometry padding = EdgeInsets.symmetric(
      horizontal: StyleData.screenPaddingValue - cardMarginRL,
    );

    final bool activeOrWaiting = widget.trainingPeriod.status == 'active' ||
        widget.trainingPeriod.status == 'waiting for start';

    if (activeOrWaiting) {
      // If the trainingPeriod is active or will shortly be active,
      // prevent lazyloading (to enable automatic scrolling).
      return SingleChildScrollView(
        physics: physics,
        scrollDirection: scrollDirection,
        padding: padding,
        child: Row(
          children: listViewChildren,
        ),
      );
    } else {
      // If the trainingPeriod is not active, lazyloading should be used.
      // (For performance reasons.)
      final TrainingCard firstCard = listViewChildren.first as TrainingCard;
      return SizedBox(
        height: firstCard.height,
        child: ListView(
          physics: physics,
          scrollDirection: scrollDirection,
          padding: padding,
          children: listViewChildren,
        ),
      );
    }
  }
}
