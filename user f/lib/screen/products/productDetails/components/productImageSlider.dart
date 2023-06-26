import 'package:ezdeliver/screen/component/helper/exporter.dart';

final selectedPageProvider = StateProvider.autoDispose<int>((ref) {
  return 0;
});
const animationDuration = Duration(milliseconds: 250);

class ProductImageSlider extends ConsumerWidget {
  ProductImageSlider({super.key, required this.images});
  final List<String> images;
  final PageController controller = PageController();
  @override
  Widget build(BuildContext context, ref) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          //different images
          const SizedBox(
            width: double.infinity,
            height: double.infinity,
          ),

          PageView(
            controller: controller,
            onPageChanged: (value) {
              ref.read(selectedPageProvider.notifier).state = value;
            },
            children: images
                .asMap()
                .entries
                .map((e) => customCachedImage(imageUrl: e.value))
                .toList(),
          ),
          //Bottom indicator widget
          // Positioned(
          //     left: constraints.maxWidth * .45,
          //     // right: constraints.maxWidth * .45,
          //     bottom: 6.sh(),
          //     child: BottomIndicator(
          //       controller: controller,
          //       length: images.length,
          //     )),
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
