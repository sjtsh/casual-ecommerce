import 'dart:async';

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/bannerModel.dart';
import 'package:ezdeliver/screen/products/productDetails/components/bottomIndicator.dart';

final selectedBannerPageProvider = StateProvider.autoDispose<int>((ref) {
  return 0;
});

class BannerSlider extends ConsumerWidget {
  BannerSlider({
    super.key,
    required this.banners,
    this.autoScroll = false,
    this.autoScrollWaitDuration = const Duration(milliseconds: 5000),
    this.scrollAnimationDuration = const Duration(milliseconds: 1000),
  });
  final List<BannerModel>? banners;
  final PageController controller = PageController();
  final bool autoScroll;
  final Duration autoScrollWaitDuration;
  final Duration scrollAnimationDuration;
  late final Timer timer = Timer.periodic(autoScrollWaitDuration, (timer) {
    if (banners != null && controller.hasClients) {
      var current = CustomKeys.ref.read(selectedBannerPageProvider);
      if (current == banners!.length - 1) {
        CustomKeys.ref.read(selectedBannerPageProvider.notifier).state = 0;
        controller.animateToPage(0,
            duration: scrollAnimationDuration, curve: Curves.easeIn);
      } else {
        CustomKeys.ref.read(selectedBannerPageProvider.notifier).state =
            current++;
        controller.animateToPage(current++,
            duration: scrollAnimationDuration, curve: Curves.easeIn);
      }
    }
  });
  @override
  Widget build(BuildContext context, ref) {
    if (autoScroll) {
      timer.isActive;
    }
    if (banners == null) return customShimmer();
    if (banners!.isEmpty) return Container();

    return LayoutBuilder(builder: (context, constraints) {
      if (!ResponsiveLayout.isMobile) {
        return Row(
            children: banners!
                .map((e) => Expanded(
                        child: BannerBox(
                      item: e,
                    )))
                .toList());
      }
      return Stack(
        children: [
          //different images
          const SizedBox(
            width: double.infinity,
            height: double.infinity,
          ),

          PageView(
            controller: controller,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (value) {
              ref.read(selectedBannerPageProvider.notifier).state = value;
            },
            children: banners!
                .asMap()
                .entries
                .map((e) => BannerBox(item: e.value))
                .toList(),
          ),
          //Bottom indicator widget

          Positioned(
              left: constraints.maxWidth * .45,
              // right: constraints.maxWidth * .45,
              bottom: 6.sh(),
              child: BottomIndicator(
                controller: controller,
                length: banners!.length,
              )),
          // //SideImage Boxes
          // Positioned(
          //     top: constraints.maxHeight * .10,
          //     bottom: constraints.maxHeight * .10,
          //     right: 14.sw(),
          //     child: SideImageList(
          //       controller: controller,
          //       images: images,
          //     ))
        ],
      );
    });
  }
}

class BannerBox extends ConsumerWidget {
  const BannerBox({super.key, required this.item});
  final BannerModel item;
  @override
  Widget build(BuildContext context, ref) {
    final selectedSubCategory =
        ref.watch(productCategoryServiceProvider).selectedSubCategory;

    final children = [
      if (!item.onlyImage) ...[
        Expanded(
          child: Text(
            item.title.isEmpty ? "" : item.title,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: CustomTheme.whiteColor, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          width: 5.sw(),
        ),
      ],
      Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(4.sr()),
            child: customCachedImage(
                imageUrl: item.img!, alternate: (selectedSubCategory?.image)),
          ))
    ];
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12.sw(),
      ),
      // width: 282,
      child: item.onlyImage
          ? customCachedImage(imageUrl: "${item.img}")
          : Container(
              padding: EdgeInsets.all(12.sr()),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.sr()),
                  gradient: LinearGradient(
                      stops: item.colors.map((e) => e.transparency).toList(),
                      colors: item.colors.map((e) => e.color).toList())),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Row(
                      children: item.orientation
                          ? children
                          : children.reversed.toList(),
                    ),
                  ),
                  if (item.detail.isNotEmpty)
                    Positioned(
                        right: 0,
                        top: 0,
                        child: Tooltip(
                            showDuration: const Duration(milliseconds: 2000),
                            triggerMode: TooltipTriggerMode.tap,
                            message: item.detail,
                            child: const Icon(Icons.info_outline))),
                ],
              ),
            ),
    );
  }
}
