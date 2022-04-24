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
    required this.focusNode,
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
  final FocusNode focusNode;
  final void Function(int, String) onChanged;
  final void Function(int)? removalCallback;
  final void Function(int)? addingCallback;

  @override
  State<FormListItem> createState() => _FormListItemState();
}

class _FormListItemState extends State<FormListItem> {
  bool showOptions = false;

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
            if (hasFocus) {
              setState(
                () {
                  showOptions = true;
                  // Make sue the TextFormField really was focused
                  // (Necessary when using tab to move around)
                  widget.focusNode.requestFocus();
                },
              );
            } else {
              setState(() {
                showOptions = false;
              });
            }
          },
          child: TextFormField(
            focusNode: widget.focusNode,
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
                    final String? complaint = complainIfEmpty(
                      input: input,
                      toFillIn: fieldName,
                    );
                    if (complaint != null) {
                      // A really hacky solution to scrolling to a bad TextField
                      widget.focusNode.unfocus();
                      Future<void>.delayed(
                        const Duration(seconds: 0),
                        widget.focusNode.requestFocus,
                      );
                    }
                    return complaint;
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      onPressed: widget.removalCallback == null
                          ? null
                          : () {
                              widget.removalCallback!(widget.index);
                              showOptions = false;
                            },
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.addingCallback == null
                          ? null
                          : () {
                              widget.addingCallback!(widget.index);
                              showOptions = false;
                            },
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: TextButton(
                        // This TextButon is used to give its icon-child the
                        // same styling as is used in the two other buttons.
                        onPressed: null,
                        child: Icon(
                          Icons.drag_handle,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
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
