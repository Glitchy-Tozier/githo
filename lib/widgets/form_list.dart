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
import 'package:githo/widgets/form_list_item.dart';

class FormList extends StatefulWidget {
  /// Creates a [Column] of [TextFormField]s that manipulate a given
  /// [List] of [String]s.
  const FormList({
    required this.header,
    required this.fieldName,
    required this.canBeEmpty,
    required List<String> initialValues,
    required this.valuesSetter,
    Key? key,
  })  : values = initialValues,
        super(key: key);

  final Widget header;
  final String fieldName;
  final bool canBeEmpty;
  final List<String> values;
  final void Function(List<String>) valuesSetter;

  @override
  _FormListState createState() => _FormListState();
}

class _FormListState extends State<FormList> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      // Necessary to make dragging items less ugly.
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      child: ReorderableListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        header: widget.header,
        shrinkWrap: true,
        onReorder: (final int oldIdx, int newIdx) {
          if (oldIdx < newIdx) {
            newIdx -= 1;
          }
          setState(() {
            // Switch the two elements in [widget.values]
            final String value = widget.values.removeAt(oldIdx);
            widget.values.insert(newIdx, value);
            widget.valuesSetter(widget.values);
          });
        },
        buildDefaultDragHandles: false,
        itemCount: widget.values.length,
        itemBuilder: (BuildContext context, final int index) {
          final String value = widget.values[index];
          return FormListItem(
            key: Key('$index$value'),
            canBeEmpty: widget.canBeEmpty,
            value: value,
            itemName: widget.fieldName,
            index: index,
            onChanged: (final int idx, final String value) {
              widget.values[idx] = value;
              widget.valuesSetter(widget.values);
            },
            removalCallback: widget.values.length == 1
                ? null
                : (final int idx) => setState(() {
                      widget.values.removeAt(idx);
                      widget.valuesSetter(widget.values);
                    }),
            addingCallback: widget.values.length == DataShortcut.maxLevelCount
                ? null
                : (final int idx) => setState(() {
                      widget.values.insert(idx + 1, '');
                      widget.valuesSetter(widget.values);
                    }),
          );
        },
      ),
    );
  }
}
