import 'package:ezdelivershop/UI/Skeletons/NoSearchSkeleton.dart';
import 'package:flutter/material.dart';

class LazyLoadingGridView<T> extends StatefulWidget {
  final Future<void> Function({required int loaded, required int appendCount})
      onListEnd;
  final List<T> children;
  final int initialCount;
  final int appendCount;
  final bool isSliverList;
  final Widget Function(BuildContext context, T child) builder;
  final Widget? loading;


  LazyLoadingGridView(
      {required this.onListEnd,
      required this.children,
      required this.builder,
      required this.appendCount,
      required this.isSliverList,
      required this.initialCount,
      this.loading});

  @override
  State<LazyLoadingGridView<T>> createState() => _LazyLoadingGridViewState<T>();
}

class _LazyLoadingGridViewState<T> extends State<LazyLoadingGridView<T>> {
  late int appendCount = widget.initialCount;
  bool disabled = false;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: widget.children.length + 3,
      itemBuilder: (BuildContext context, int index) {

        if (index >= widget.children.length) return progressIndicator();
        int loaded = index + 1;
        if (loaded == appendCount && !disabled) {
          disabled = true;
          widget
              .onListEnd(loaded: loaded, appendCount: widget.appendCount)
              .then((value) => disabled = false);
          appendCount += widget.appendCount;
        }
        return widget.builder(context, widget.children[index]);
      },
    );
  }

  Widget progressIndicator() {
    return
      disabled
          ? widget.loading ?? NoSearchSkeleton(column: true, count: 1)
          : Container();

  }
}
