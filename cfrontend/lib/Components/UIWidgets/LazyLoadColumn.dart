import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../CustomTheme.dart';

class LazyLoadColumn<T> extends StatefulWidget {
  final Future<void> Function({required int loaded, required int appendCount})
      onListEnd;
  final List<T> children;
  final int initialCount;
  final int appendCount;
  final int totalLength;
  final Widget Function(BuildContext context, T child) builder;

  LazyLoadColumn(
      {required this.onListEnd,
      required this.children,
      required this.builder,
      required this.appendCount,
      required this.totalLength,
      required this.initialCount});

  @override
  State<LazyLoadColumn<T>> createState() => _LazyLoadColumnState<T>();
}

class _LazyLoadColumnState<T> extends State<LazyLoadColumn<T>> {
  late int appendCount = widget.initialCount;
  bool disabled = false;

  onSeeMore() {
    disabled = true;
    widget
        .onListEnd(
            loaded: widget.children.length, appendCount: widget.appendCount)
        .then((value) => disabled = false);
    appendCount += widget.appendCount;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...widget.children.map((T index) => widget.builder(context, index)),
        disabled ? CircularProgressIndicator() : progressIndicator()
      ],
    );
  }

  Widget progressIndicator() {
    if (widget.totalLength <= widget.children.length) return Container();
    return GestureDetector(
      onTap: onSeeMore,
      child: Container(
          color: context.watch<CustomTheme>().isDarkMode
          ? ColorPalette.darkContainerColor
          : Colors.white,
          height: 36,
          width: double.infinity,
          child: Center(child: Text("See More"))),
    );
  }
}
