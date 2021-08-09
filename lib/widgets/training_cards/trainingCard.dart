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
  final double horizontalMargin;
  final double cardWidth;
  final double cardHeight;
  final Widget child;
  final Function? onTap;
  final Color color;

  final double topMargin = 5;
  final double bottomMargin = 15;
  final double borderRadius = 7;

  /// Returns the default training-card.
  const TrainingCard({
    required this.horizontalMargin,
    required this.cardWidth,
    required this.cardHeight,
    required this.child,
    required this.onTap,
    required this.color,
    Key? key,
  }) : super(key: key);

  double get height {
    final double height = this.cardHeight + this.topMargin + this.bottomMargin;
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
        child: Container(
          width: this.cardWidth,
          height: this.cardHeight,
          child: Material(
            color: this.color,
            child: InkWell(
              child: Center(child: this.child),
              splashColor: Colors.black,
              onTap: (onTap == null) ? null : () => onTap!(),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            elevation: 5,
          ),
        ),
      ),
    );
  }
}
