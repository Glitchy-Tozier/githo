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

class TrainingCard extends StatelessWidget {
  /// Returns the default training-card.
  const TrainingCard({
    required this.horizontalMargin,
    required this.cardWidth,
    required this.cardHeight,
    required this.color,
    required this.child,
    Key? key,
  }) : super(key: key);

  final double horizontalMargin;
  final double cardWidth;
  final double cardHeight;
  final Color color;
  final Widget child;

  static const double topMargin = 5;
  static const double bottomMargin = 15;
  static const double borderRadius = 7;

  double get height {
    final double height = cardHeight + topMargin + bottomMargin;
    return height;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: topMargin,
          right: horizontalMargin,
          bottom: bottomMargin,
          left: horizontalMargin,
        ),
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: TrainingCardThemes.getThemedCard(
            color: color,
            elevation: 5,
            cardHeight: cardHeight,
            child: child,
          ),
        ),
      ),
    );
  }
}
