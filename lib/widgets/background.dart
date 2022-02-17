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

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:githo/config/custom_widget_themes.dart';
import 'package:githo/config/style_data.dart';

class Background extends StatelessWidget {
  /// Returns a background and places the child in the foreground.
  const Background({
    this.child = const SizedBox(),
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Background
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/cropped_background.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: StyleData.screenPaddingValue / 2,
                color: getBackgroundPaddingColor(context),
              ),
              Container(
                width: StyleData.screenPaddingValue / 2,
                color: getBackgroundPaddingColor(context),
              ),
            ],
          ),
        ),
        Padding(
          padding: StyleData.screenPadding * 0.5,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5,
                sigmaY: 5,
              ),
              child: Container(
                color: Theme.of(context).backgroundColor.withOpacity(0.6),
              ),
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}
