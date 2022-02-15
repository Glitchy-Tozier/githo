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
import 'package:numberpicker/numberpicker.dart';

import 'package:githo/config/custom_widget_themes.dart';
import 'package:githo/widgets/alert_dialogs/base_dialog.dart';

/// An [AlertDialog] that lets you choose the minute of a [TimeOfDay].

class MinutePicker extends StatefulWidget {
  const MinutePicker({
    required this.initialTime,
    required this.resultCallback,
    Key? key,
  }) : super(key: key);

  final TimeOfDay initialTime;

  /// The function that supplies the chosen [TimeOfDay] (with the changed
  /// minute).
  /// Use it to use the AlertDialog's result in the calling program.
  final void Function(TimeOfDay) resultCallback;

  @override
  State<MinutePicker> createState() => _MinutePickerState();
}

class _MinutePickerState extends State<MinutePicker> {
  TimeOfDay changedTime = const TimeOfDay(hour: 0, minute: 0);

  @override
  void initState() {
    super.initState();
    setState(() {
      changedTime = widget.initialTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: const Text('Select Minute'),
      content: NumberPicker(
        minValue: 0,
        maxValue: 59,
        itemCount: 5,
        itemHeight: 30,
        value: changedTime.minute,
        textMapper: (final String text) {
          final bool isSelected = text == changedTime.minute.toString();
          String result = text;
          if (text.length == 1) {
            result = '0$result';
          }
          if (isSelected) {
            result = 'XX : $result';
          } else {
            result = '            $result';
          }
          return result;
        },
        onChanged: (final int value) => setState(
          () => changedTime = TimeOfDay(
            hour: widget.initialTime.hour,
            minute: value,
          ),
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <ElevatedButton>[
            ElevatedButton.icon(
              icon: const Icon(
                Icons.cancel,
              ),
              label: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                    ),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(ThemedColors.orange),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.check_circle,
              ),
              label: Text(
                'Select',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                    ),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(ThemedColors.green),
              ),
              onPressed: () {
                Navigator.pop(context);
                widget.resultCallback(changedTime);
              },
            ),
          ],
        ),
      ],
    );
  }
}
