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

import 'dart:math';
import 'package:flutter/material.dart';

import 'package:githo/config/data_shortcut.dart';
import 'package:githo/widgets/form_list_item.dart';

/// A class used to structure a [key]-[value]-pair and the corresponding
/// [FocusNode].
class KeyValuePair {
  const KeyValuePair(this.key, this.value, this.focusNode);
  final int key;
  final String value;
  final FocusNode focusNode;
}

class KeyValueList {
  /// Construct a [KeyValueList] from a [List] of values.
  KeyValueList.fromList(this._values)
      : _keys = List<int>.generate(_values.length, (final int i) => i),
        _focusNodes =
            List<FocusNode>.generate(_values.length, (_) => FocusNode());

  /// Inserts a new value. The corresponding key and [FocusNode] are generated
  /// automatically.
  void insertNew(final int index, final String value) {
    _keys.insert(index, getUniqueKey());
    _values.insert(index, value);
    _focusNodes.insert(index, FocusNode());
  }

  /// Inserts a [KeyValuePair].
  void insert(final int index, final KeyValuePair keyValuePair) {
    _keys.insert(index, keyValuePair.key);
    _values.insert(index, keyValuePair.value);
    _focusNodes.insert(index, keyValuePair.focusNode);
  }

  /// Updates the value on the given index.
  void updateValue(final int index, final String value) {
    _values[index] = value;
  }

  /// Removes a value. Returns the removed value as a [KeyValuePair].
  KeyValuePair removeAt(final int index) {
    final int removedKey = _keys.removeAt(index);
    final String removedValue = _values.removeAt(index);
    final FocusNode removedNode = _focusNodes.removeAt(index);
    return KeyValuePair(removedKey, removedValue, removedNode);
  }

  /// Create a new, random key (an [int]) that isn't already present in [_keys].
  int getUniqueKey() {
    // Get a random int that isn't already used as a key.
    int key = Random().nextInt(4294967296);
    while (_keys.contains(key)) {
      key = Random().nextInt(4294967296);
    }
    return key;
  }

  final List<int> _keys;
  final List<String> _values;
  final List<FocusNode> _focusNodes;

  List<int> get keys => _keys;
  List<String> get values => _values;
  List<FocusNode> get focusNodes => _focusNodes;
  int get length {
    assert(_keys.length == _values.length);
    assert(_values.length == _focusNodes.length);
    return _values.length;
  }
}

class FormList extends StatefulWidget {
  /// Creates a [Column] of [TextFormField]s that manipulate a given
  /// [List] of [String]s.
  const FormList({
    Key? key,
    required this.header,
    required this.fieldName,
    required this.canBeEmpty,
    required this.initialValues,
    required this.valuesSetter,
  }) : super(key: key);

  final Widget header;
  final String fieldName;
  final bool canBeEmpty;
  final List<String> initialValues;
  final void Function(List<String>) valuesSetter;

  @override
  _FormListState createState() => _FormListState();
}

class _FormListState extends State<FormList> {
  late KeyValueList keyValueList;

  /// Used to focus on the [FocusNode] within [keyValueList] with the given idx.
  int? toFocus;

  @override
  void initState() {
    super.initState();
    keyValueList = KeyValueList.fromList(widget.initialValues);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Necessary to make dragging items less ugly.
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      child: ReorderableListView.builder(
        header: widget.header,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        onReorder: (final int oldIdx, int newIdx) {
          if (oldIdx < newIdx) {
            newIdx -= 1;
          }
          setState(() {
            // Switch the two elements in [widget.values]
            final KeyValuePair removedPair = keyValueList.removeAt(oldIdx);
            keyValueList.insert(newIdx, removedPair);
            widget.valuesSetter(keyValueList.values);
            toFocus = newIdx;
          });
        },
        buildDefaultDragHandles: false,
        itemCount: keyValueList.length,
        itemBuilder: (BuildContext context, final int index) {
          final int key = keyValueList.keys[index];
          final String value = keyValueList.values[index];
          final FocusNode node = keyValueList.focusNodes[index];
          if (index == toFocus) {
            node.requestFocus();
            toFocus = null;
          }
          return FormListItem(
            key: ValueKey<int>(key),
            canBeEmpty: widget.canBeEmpty,
            value: value,
            itemName: widget.fieldName,
            index: index,
            focusNode: node,
            onChanged: (final int idx, final String value) {
              keyValueList.updateValue(idx, value);
              widget.valuesSetter(keyValueList.values);
            },
            removalCallback: keyValueList.length == 1
                ? null
                : (final int idx) {
                    final bool wasLastElement = idx + 1 == keyValueList.length;
                    final int nextIdxToFocus = wasLastElement ? idx - 1 : idx;
                    setState(() {
                      keyValueList.removeAt(idx);
                      widget.valuesSetter(keyValueList.values);
                      // Turn focus to the appropriate next TextField
                      toFocus = nextIdxToFocus;
                    });
                  },
            addingCallback: keyValueList.length == DataShortcut.maxLevelCount
                ? null
                : (final int idx) {
                    final int newIdx = idx + 1;
                    setState(() {
                      keyValueList.insertNew(newIdx, '');
                      widget.valuesSetter(keyValueList.values);
                      toFocus = newIdx; // Focus the new TextFormField
                    });
                  },
          );
        },
      ),
    );
  }
}
