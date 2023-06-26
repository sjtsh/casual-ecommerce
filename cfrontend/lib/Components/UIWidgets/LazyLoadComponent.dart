import 'package:ezdelivershop/UI/Skeletons/NoSearchSkeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class LazyLoadController {
  late int appendCount;
  late bool disabled;

  LazyLoadController({required int initialCount}) {
    appendCount = initialCount;
    disabled = false;
  }
}

extension ListViewRefresh on LazyLoadComponent {
  Widget refresh(Future<void> Function() onRefresh) =>
      RefreshIndicator(onRefresh: onRefresh, child: this);
}

class LazyLoadComponent<T> extends StatefulWidget {
  final Future<void> Function({required int loaded, required int appendCount})
      onListEnd;
  final Axis? direction;
  final List<T> children;
  final int initialCount;
  final int appendCount;
  final Widget Function(BuildContext context, T child) builder;
  final Widget? loading;
  final ScrollController? scrollController;
  final LazyLoadController? controller;

  LazyLoadComponent(
      {required this.onListEnd,
      required this.children,
      required this.builder,
      required this.appendCount,
      this.direction,
      required this.initialCount,
      this.loading,
      this.scrollController,
       this.controller});

  @override
  State<LazyLoadComponent<T>> createState() => _LazyLoadComponentState<T>();
}

class _LazyLoadComponentState<T> extends State<LazyLoadComponent<T>> {
  ScrollController scrollController = ScrollController();
  late LazyLoadController controller = widget.controller ??
      LazyLoadController(initialCount: widget.initialCount);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController.addListener(onChanged);
  }

  onChanged() {
    if (widget.children.length != controller.appendCount) return;
    if (scrollController.offset >=
        scrollController.position.maxScrollExtent - 100) {
      if (!controller.disabled!) {
        if (mounted) setState(() => controller.disabled = true);
        widget
            .onListEnd(
                loaded: widget.children.length, appendCount: widget.appendCount)
            .then((value) {
          if (mounted) setState(() => controller.disabled = false);
        });
        controller.appendCount += widget.appendCount;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.children.length + 1,
        controller: widget.scrollController ?? scrollController,
        scrollDirection: widget.direction ?? Axis.vertical,
        itemBuilder: (context, index) {
          if (index >= widget.children.length) return progressIndicator();
          return widget.builder(context, widget.children[index]);
        });
    // return ListView(
    //   children: widget.children.asMap().entries.map((e) {}).toList(),
    // );
  }

  Widget progressIndicator() {
    Widget loading = widget.loading ?? NoSearchSkeleton(column: true, count: 1);
    if (widget.direction == Axis.horizontal) {
      return controller.disabled
          ? loading
          : Container(
              width: 100,
            );
    }
    return Column(children: [
      controller.disabled ? loading : Container(),
      // SizedBox(height: context.read<BottomSheetManagement>().headerHeight),
    ]);
  }
}
