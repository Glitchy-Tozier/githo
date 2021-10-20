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

class ListButton extends StatelessWidget {
  /// The default list-item used in this application.
  const ListButton({
    this.color,
    required this.text,
    required this.onPressed,
  });

  final Color? color;
  final String text;
  final Function onPressed;

  /// The distance the button keeps to other widgets.
  static const EdgeInsets margin = EdgeInsets.symmetric(
    vertical: 5,
  );

  /// The minimum size the button can have.
  static const Size minSize = Size(
    double.infinity,
    60,
  );

  /// The distance the button's border stays away from its child-widget.
  static const EdgeInsets padding = EdgeInsets.symmetric(
    vertical: 20,
    horizontal: 20,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color?>(
            color ?? ThemedColors.grey,
          ),
          minimumSize: MaterialStateProperty.all<Size>(
            minSize,
          ),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(padding),
          alignment: Alignment.centerLeft,
        ),
        onPressed: () => onPressed(),
        child: Text(
          text,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ),
    );
  }
}
