/* 
 * Githo – An app that helps you form long-lasting habits, one step at a time.
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

class TrainingCard extends StatelessWidget {
  /// Returns the default training-card.
  const TrainingCard({
    required this.horizontalMargin,
    required this.cardWidth,
    required this.cardHeight,
    required this.color,
    required this.onTap,
    required this.child,
    Key? key,
  }) : super(key: key);

  final double horizontalMargin;
  final double cardWidth;
  final double cardHeight;
  final Widget child;
  final Function? onTap;
  final Color color;

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
          child: Material(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
            elevation: 5,
            child: InkWell(
              splashColor: Colors.black,
              onTap: (onTap == null) ? null : () => onTap!(),
              borderRadius: BorderRadius.circular(borderRadius),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
