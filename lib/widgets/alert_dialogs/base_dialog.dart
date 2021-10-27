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

import 'dart:ui';
import 'package:flutter/material.dart';

/// An [AlertDialog] that serves as the base for all used Dialogues.
/// This makes styling all of them at once very easy.

class BaseDialog extends StatelessWidget {
  const BaseDialog({
    this.title,
    this.content,
    this.actions,
    Key? key,
  }) : super(key: key);

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 5,
        sigmaY: 5,
      ),
      child: AlertDialog(
        backgroundColor: Theme.of(context).backgroundColor.withOpacity(0.6),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7)),
          side: BorderSide(
            color: Colors.white,
            width: 3,
          ),
        ),
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }
}
