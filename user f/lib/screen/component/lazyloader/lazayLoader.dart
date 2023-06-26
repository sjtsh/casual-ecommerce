import 'package:ezdeliver/screen/component/helper/exporter.dart';

final pageCountProvider = StateProvider<int>((ref) {
  return 0;
});

class LazyLoadingSliverList extends SliverList {
  LazyLoadingSliverList({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
  }) : super(
            delegate: SliverChildBuilderDelegate(
          itemBuilder,
        ));
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
}

class LazyLoadingList extends ConsumerWidget {
  LazyLoadingList(
      {super.key,
      required this.itemBuilder,
      required this.itemCount,
      this.separatedBuilder});

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget Function(BuildContext, int)? separatedBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: separatedBuilder ??
          (context, index) {
            return SizedBox(
              height: 10.sh(),
            );
          },
      itemBuilder: itemBuilder,
    );
  }
}
