import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/products/productDetails/components/productImageSlider.dart';

class SideImageList extends ConsumerWidget {
  const SideImageList(
      {super.key, required this.images, required this.controller});
  final List<String> images;
  final PageController controller;
  @override
  Widget build(BuildContext context, ref) {
    return SizedBox(
      width: 60.sw(),
      height: 60.sh(),
      child: ListView.separated(
          itemBuilder: (context, index) {
            final selectedPage = ref.watch(selectedPageProvider);
            return GestureDetector(
                onTap: () {
                  ref.read(selectedPageProvider.state).state = index;
                  controller.animateToPage(index,
                      duration: animationDuration, curve: Curves.easeIn);
                },
                child: sideImage(images[index], selectedPage == index));
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 11.sh(),
            );
          },
          itemCount: images.length),
    );
  }

  Widget sideImage(String image, bool isSelected) {
    return AnimatedContainer(
      duration: animationDuration,
      decoration: BoxDecoration(
          color: CustomTheme.whiteColor.withOpacity(0.9),
          border: Border.all(
            color: isSelected ? CustomTheme.primaryColor : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(6.sr())),
      padding: EdgeInsets.symmetric(vertical: 3.sh(), horizontal: 2.sw()),
      child: AspectRatio(
          aspectRatio: 0.95, child: CachedNetworkImage(imageUrl: image)),
    );
  }
}
