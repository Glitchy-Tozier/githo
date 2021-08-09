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
import 'package:githo/extracted_data/styleData.dart';

class FatDivider extends StatelessWidget {
  final Color color;

  /// Creates a thick divider.
  const FatDivider({this.color = Colors.black54});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 30,
      thickness: 10,
      color: this.color,
      indent: StyleData.screenPaddingValue * 0.5,
      endIndent: StyleData.screenPaddingValue * 0.5,
    );
  }
}
