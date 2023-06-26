import 'package:ezdeliver/screen/component/helper/exporter.dart';

class PageViewHeader extends ConsumerWidget {
  const PageViewHeader({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final orderRequestService = ref.watch(orderHistoryServiceProvider);
    final currentPage = ref.watch(orderHistoryServiceProvider).selectedIndex;
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(4.sr())),
      margin: EdgeInsets.only(
          left: 22.sw(), right: 22.sw(), bottom: 0.sh(), top: 18.sh()),
      child: Row(
          children: orderRequestService.tabs
              .asMap()
              .entries
              .map((e) => Expanded(
                    child: headerItem(context, ref,
                        map: e, selectedPage: currentPage),
                  ))
              .toList()),
    );
  }

  Widget headerItem(BuildContext context, WidgetRef ref,
      {required MapEntry map, required int selectedPage}) {
    return Builder(builder: (context) {
      final isSelected = map.key == selectedPage;
      return GestureDetector(
        onTap: () {
          ref.read(orderHistoryServiceProvider).pageController.animateToPage(
              map.key,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeIn);
          ref.read(orderHistoryServiceProvider).selectedIndex = map.key;
        },
        child: Container(
          margin: EdgeInsets.all(3.sr()),
          decoration: BoxDecoration(
              border:
                  isSelected ? null : Border.all(color: CustomTheme.greyColor),
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(4.sr())),
          child: Center(
              child: Padding(
            padding: EdgeInsets.all(14.0.sr()),
            child: Text(
              map.value,
              style: Theme.of(context).textTheme.headline6!.copyWith(
                  color:
                      isSelected ? Colors.white : CustomTheme.getBlackColor()),
            ),
          )),
        ),
      );
    });
  }
}
