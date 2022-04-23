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

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:githo/config/data_shortcut.dart';
import 'package:githo/helpers/text_form_field_validation.dart';
import 'package:githo/helpers/type_extentions.dart';

class FormListItem extends StatefulWidget {
  /// A [TextFormField] with some added functionality.
  const FormListItem({
    Key? key,
    required this.canBeEmpty,
    required this.value,
    required this.itemName,
    required this.index,
    required this.onChanged,
    required this.removalCallback,
    required this.addingCallback,
  })  : number = index + 1,
        super(key: key);

  final bool canBeEmpty;
  final String value;
  final String itemName;
  final int index;
  final int number;
  final void Function(int, String) onChanged;
  final void Function(int)? removalCallback;
  final void Function(int)? addingCallback;

  @override
  State<FormListItem> createState() => _FormListItemState();
}

class _FormListItemState extends State<FormListItem> {
  final FocusNode textFieldFocusNode = FocusNode();
  bool showOptions = false;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create a pretty name such as "Level 4"
    final String fieldName = widget.number < DataShortcut.maxLevelCount
        ? '${widget.itemName.capitalize()} ${widget.number}'
        : 'Final ${widget.itemName}';

    return Column(
      children: <Widget>[
        Focus(
          onFocusChange: (final bool hasFocus) {
            timer?.cancel();
            if (hasFocus) {
              setState(
                () {
                  showOptions = true;
                  // Make sue the TextFormField really was focused
                  textFieldFocusNode.requestFocus();
                },
              );
            } else {
              // Delay switch to create time To press a button without the
              // button disappearing from under your finger.
              timer = Timer(
                const Duration(seconds: 1),
                () => setState(
                  () => showOptions = false,
                ),
              );
            }
          },
          child: TextFormField(
            focusNode: textFieldFocusNode,
            initialValue: widget.value,
            decoration: InputDecoration(labelText: fieldName),
            maxLength: DataShortcut.maxLevelCharacters,
            onChanged: (final String newValue) {
              widget.onChanged(
                widget.index,
                newValue.trim(),
              );
            },
            validator: widget.canBeEmpty
                ? null
                : (final String? input) {
                    return complainIfEmpty(
                      input: input,
                      toFillIn: fieldName,
                    );
                  },
            textInputAction: TextInputAction.next,
          ),
        ),
        ExcludeFocus(
          child: Column(
            children: <Widget>[
              Visibility(
                // Only show if the TextField is focused.
                visible: showOptions,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: widget.removalCallback == null
                          ? null
                          : () {
                              widget.removalCallback!(widget.index);
                              showOptions = false;
                            },
                      icon: const Icon(Icons.delete),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: widget.addingCallback == null
                          ? null
                          : () {
                              widget.addingCallback!(widget.index);
                              showOptions = false;
                            },
                      icon: const Icon(Icons.add),
                    ),
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: const Icon(Icons.drag_handle),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
