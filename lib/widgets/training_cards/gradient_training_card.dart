/* 
 * Githo – An app that helps you gradually form long-lasting habits.
 * Copyright (C) 2022 Florian Thaler
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

class GradientTrainingCard extends StatelessWidget {
  /// Returns a beautiful training-card that is used
  /// for the current training if it hasn't been started yet.
  const GradientTrainingCard({
    Key? key,
    required this.horizontalMargin,
    required this.cardWidth,
    required this.cardHeight,
    required this.onTap,
    required this.textSize,
  }) : super(key: key);

  final double horizontalMargin;
  final double cardWidth;
  final double cardHeight;
  final double textSize;
  final void Function() onTap;

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
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          elevation: 7,
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Colors.deepOrange.shade200,
                  Colors.pinkAccent.shade400,
                  Colors.purple.shade900,
                ],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadius),
              child: InkWell(
                splashColor: Colors.black,
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Center(
                  child: Text(
                    'Start training',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: textSize * 1.3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
