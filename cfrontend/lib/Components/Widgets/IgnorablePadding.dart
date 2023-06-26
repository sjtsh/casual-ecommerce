import 'package:flutter/material.dart';

Widget ColumnWithPadding({required List<Widget> children, EdgeInsets? padding, List<Type> types = const [ Divider]}) {
  return padding == null
      ? returnColumn(children: children, padding: padding)
      : Padding(
          padding: padding.copyWith(right: 0, left: 0),
          child: returnColumn(children: children, padding: padding, types:types));
}

returnColumn({required List<Widget> children, EdgeInsets? padding, List<Type> types = const [ Divider]}) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map((e) => padding == null || types.contains(e.runtimeType)
              ? e
              : Padding(
                  padding: padding.copyWith(top: 0, bottom: 0),
                  child: e,
                ))
          .toList());
}