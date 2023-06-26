import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/products/components/bannerSlider.dart';
import 'package:ezdeliver/screen/products/productDetails/components/productImageSlider.dart';

class BottomIndicator extends ConsumerWidget {
  const BottomIndicator(
      {super.key, required this.length, required this.controller});
  final int length;
  final PageController controller;
  @override
  Widget build(BuildContext context, ref) {
    final selectedPage = ref.watch(selectedBannerPageProvider);

    if (length <= 1) return Container();
    return Row(
        children: List.generate(
            length,
            (index) => GestureDetector(
                onTap: () {
                  ref.read(selectedBannerPageProvider.notifier).state = index;
                  controller.animateToPage(index,
                      duration: animationDuration, curve: Curves.easeIn);
                },
                child:
                    animatedBottomContainer(context, selectedPage == index))));
  }

  Widget animatedBottomContainer(context, bool isSelected) {
    return AnimatedContainer(
      duration: animationDuration,
      margin: EdgeInsets.only(right: 4.sw()),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.sr()),
          color: isSelected
              ? CustomTheme.whiteColor
              : CustomTheme.whiteColor.withOpacity(0.19)),
      height: 8.sh(),
      width: isSelected ? 12.sw() : 8.sw(),
    );
  }
}
