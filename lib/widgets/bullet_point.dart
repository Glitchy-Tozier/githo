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

/// Returns a bullet-point
/// Used on the habitDetails.dart-screen

class BulletPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      '•  ',
      style: Theme.of(context).textTheme.bodyText1,
    );
  }
}
