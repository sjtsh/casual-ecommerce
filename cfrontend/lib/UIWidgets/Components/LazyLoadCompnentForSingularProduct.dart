import 'package:ezdelivershop/UI/Skeletons/NoSearchSkeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

extension ListViewRefresh on LazyLoadComponentForProduct {
  Widget refresh(Future<void> Function() onRefresh) =>
      RefreshIndicator(onRefresh: onRefresh, child: this);
}

class LazyLoadComponentForProduct<T> extends StatefulWidget {
  final Future<void> Function({required int loaded, required int appendCount})
  onListEnd;
  final Axis? direction;
  final List<T> children;
  final int initialCount;
  final int appendCount;
  final bool isSliverList;
  final Widget Function(BuildContext context, T child) builder;
  final Widget? loading;
  final ScrollController? controller;

  LazyLoadComponentForProduct(
      {required this.onListEnd,
        required this.children,
        required this.builder,
        required this.appendCount,
        this.direction,
        this.isSliverList = false,
        required this.initialCount,
        this.loading,
        this.controller});

  @override
  State<LazyLoadComponentForProduct<T>> createState() => _LazyLoadComponentForProductState<T>();
}

class _LazyLoadComponentForProductState<T> extends State<LazyLoadComponentForProduct<T>> {
  late int appendCount = widget.initialCount;
  bool disabled = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isSliverList) {
      return SliverList(
          delegate: SliverChildBuilderDelegate(
              childCount: widget.children.length + 1, (context, index) {
            int loaded = index + 1;
            if (loaded == appendCount && !disabled) {
              disabled = true;
              widget
                  .onListEnd(loaded: loaded, appendCount: widget.appendCount)
                  .then((value) => disabled = false);
              appendCount += widget.appendCount;
            }
            if (index == widget.children.length) return progressIndicator();
            return widget.builder(context, widget.children[index]);
          }));
    } else {
      return ListView(
        controller: widget.controller,
        scrollDirection: widget.direction ?? Axis.vertical,
        children: widget.children.asMap().entries.map((e) {
          if (e.key >= widget.children.length) return progressIndicator();
          int loaded = e.key + 1;
          if (loaded == appendCount && !disabled) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if (mounted) setState(() => disabled = true);
            });
            widget
                .onListEnd(loaded: loaded, appendCount: widget.appendCount)
                .then((value) {
              if (mounted) setState(() => disabled = false);
            });
            appendCount += widget.appendCount;
          }
          return widget.builder(context, e.value);
        }).toList(),
      );
    }
  }

  Widget progressIndicator() {
    Widget loading = widget.loading ?? NoSearchSkeleton(column: true, count: 1);
    if (widget.direction == Axis.horizontal) {
      return disabled
          ? loading
          : Container(
        width: 100,
      );
    }
    return Column(children: [
      disabled ? loading : Container(),
      // SizedBox(height: context.read<BottomSheetManagement>().headerHeight),
    ]);
  }
}
