import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/categoryModel.dart';
import 'package:ezdeliver/screen/order/subcategoryproductbox.dart';
import 'package:ezdeliver/services/favouriteAnimation.dart';

class CategoryBox extends HookConsumerWidget {
  CategoryBox(
      {super.key,
      required this.item,
      required this.isLoading,
      this.small = false,
      this.log = false});
  final Category item;
  final bool isLoading;
  final bool small;
  final bool log;
  final hoverProvider = StateProvider<bool>((ref) {
    return false;
  });
  @override
  Widget build(BuildContext context, ref) {
    final animation =
        useAnimationController(duration: widgetSwitchAnimationDuration);
    final isHoverd = ref.watch(hoverProvider);
    return LayoutBuilder(builder: (context, constraint) {
      return MouseRegion(
        // onHover: (hover) {
        //   ref.read(hoverProvider.state).state = true;
        // },
        onExit: (event) {
          ref.read(hoverProvider.state).state = false;
        },
        onEnter: (event) {
          ref.read(hoverProvider.state).state = true;
        },
        child: GestureDetector(
          onDoubleTap: () {
            var favourite = item.favourite;
            ref
                .read(productCategoryServiceProvider)
                .categoryToFavourite(item, context);
            AnimationCollection.animateFavourite(favourite,
                animation: animation);
          },
          onTap: () async {
            // if (log) {
            //   await FirebaseAnalytics.instance
            //       .logEvent(name: "Category_${item.id}", parameters: {
            //     "id": ref.read(userChangeProvider).loggedInUser.value?.id,
            //     "name": ref.read(userChangeProvider).loggedInUser.value?.name
            //   });
            // }
            var categories = ref.read(productCategoryServiceProvider).category;
            if (!isLoading) {
              if (categories!.isNotEmpty) {
                if (categories.indexWhere((element) => element.id == item.id) !=
                    -1) {
                  ref.read(productCategoryServiceProvider).clear();

                  // Future.delayed(const Duration(milliseconds: 200), () {
                  // ref.read(productCategoryServiceProvider).fetchSubCategories(item.id);
                  //   Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //     return SubCategoryProductScreen(
                  //       item: item,
                  //     );
                  //   }));
                  // });

                  var subCategories = ref
                      .read(productCategoryServiceProvider)
                      .getSubCategoryFromCategory(item);
                  if (!ResponsiveLayout.isMobile) {
                    ref.read(statelistProvider).holderwidget =
                        SubCategoryProductScreen(
                      item: item,
                      subCategories: subCategories,
                    );
                    return;
                  }
                  Utilities.pushPage(
                      SubCategoryProductScreen(
                        item: item,
                        subCategories: subCategories,
                      ),
                      1, function: () {
                    if (subCategories.isNotEmpty) {
                      ref
                          .read(productCategoryServiceProvider)
                          .selectSubCategory(subCategories.first);
                    }
                  });
                }
              }
            }
          },
          child: AnimatedContainer(
            duration: widgetSwitchAnimationDuration,
            decoration: BoxDecoration(
                color: CustomTheme.primaryColor.withAlpha(35),
                borderRadius: BorderRadius.circular(15.sr()),
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(4, 4),
                      blurRadius: 15,
                      color: CustomTheme.getBlackColor()
                          .withOpacity(isHoverd ? 0.1 : 0.04))
                ]),
            child: Stack(
              children: [
                Column(
                  children: [
                    isLoading
                        ? Expanded(
                            flex: 3,
                            child: customShimmer(shape: BoxShape.circle),
                          )
                        : Expanded(
                            flex: small
                                ? 3
                                : ResponsiveLayout.isMobile
                                    ? 4
                                    : 6,
                            child: Container(
                              margin: EdgeInsets.only(top: 5.sh()),
                              child: FavouriteAnimator(
                                animation: animation,
                                child: Center(
                                    child: AnimatedScale(
                                        duration: widgetSwitchAnimationDuration,
                                        scale: isHoverd ? 1.1 : 0.9,
                                        child: customCachedImage(
                                            imageUrl: item.image))),
                              ),
                            ),
                          ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 2.sw(),
                            bottom: 2.sh(),
                            right: 2.sw(),
                            top: 2.sh()),
                        child: Align(
                            alignment: Alignment.center,
                            child: isLoading
                                ? customShimmer()
                                : Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.sr(), vertical: 2.sr()),
                                    color: Colors.transparent,
                                    child: Text(
                                      item.name,
                                      textAlign: TextAlign.center,
                                      style: kTextStyleInterMedium.copyWith(
                                          fontSize: small
                                              ? UniversalPlatform.isAndroid
                                                  ? 12.ssp()
                                                  : 15.ssp(min: 15.ssp())
                                              : UniversalPlatform.isAndroid
                                                  ? 15.ssp()
                                                  : 15.ssp(min: 15.ssp()),
                                          fontWeight: FontWeight.w600,
                                          color: isHoverd
                                              ? CustomTheme.primaryColor
                                              : CustomTheme.getBlackColor()),
                                    ),
                                  )),
                      ),
                    )
                  ],
                ),
                Positioned(
                  right: 6.sw(),
                  top: 6.sh(),
                  child: AnimatedOpacity(
                    duration: widgetSwitchAnimationDuration,
                    opacity: !isLoading && item.favourite ? 1 : 0,
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(productCategoryServiceProvider)
                            .categoryToFavourite(item, context);
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Icon(
                          item.favourite
                              ? Icons.favorite
                              : Icons.favorite_border_outlined,
                          size: 18.sr(),
                          color: CustomTheme.primaryColor.withOpacity(0.65),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
