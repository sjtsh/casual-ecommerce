import 'package:auto_size_text/auto_size_text.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/subCategoryModel.dart';

class SubCategoryBox extends StatelessWidget {
  const SubCategoryBox(
      {super.key,
      required this.subCategory,
      this.loading = false,
      this.isSelected = false,
      required this.onTap});
  final bool loading, isSelected;

  final SubCategory? subCategory;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    const animationTime = 300;
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Column(
        // crossAxisAlignment: ResponsiveLayout.isMobile
        //     ? CrossAxisAlignment.center
        //     : CrossAxisAlignment.start,
        children: [
          Divider(),
          if (ResponsiveLayout.isMobile)
            Expanded(
              flex: isSelected ? 4 : 3,
              child: !loading
                  ? AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              // ? CustomTheme.getFilledPrimaryColor().withAlpha(30)
                              ? Colors.pink.withAlpha(30)
                              : null,
                          border: Border.all(
                              width: 1.5,
                              color: isSelected
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5)
                                  : CustomTheme.greyColor),
                          borderRadius: BorderRadius.circular(12.sr()),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: AnimatedScale(
                            duration:
                                const Duration(milliseconds: animationTime),
                            scale: isSelected ? 1 : 0.8,
                            child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: animationTime),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(12.sr()),
                                    child: customCachedImage(
                                        imageUrl: subCategory!.image),
                                  ),
                                )),
                          ),
                        ),
                      ),
                    )
                  // LayoutBuilder(builder: (context, constraints) {
                  //     const animationTime = 300;
                  //     return Stack(
                  //       children: [
                  //         AnimatedPositioned(
                  //           duration: Duration(milliseconds: animationTime),
                  //           left: isSelected
                  //               ? -constraints.maxWidth * .12
                  //               : -constraints.maxWidth,
                  //           top: 0,
                  //           child: Container(
                  //             width: constraints.maxWidth,
                  //             height: constraints.maxHeight,
                  //             decoration: isSelected
                  //                 ? BoxDecoration(
                  //                     borderRadius: BorderRadius.only(
                  //                         topRight:
                  //                             Radius.elliptical(40.sr(), 45.sr()),
                  //                         bottomRight: Radius.elliptical(
                  //                             40.sr(), 45.sr())),
                  //                     gradient: const LinearGradient(colors: [
                  //                       Color(0xfff0ccfd),
                  //                       Color(0xfff7e5ff)
                  //                     ]))
                  //                 : const BoxDecoration(),
                  //           ),
                  //         ),
                  //         Align(
                  //           alignment: Alignment.center,
                  //           child: AnimatedScale(
                  //             duration: Duration(milliseconds: animationTime),
                  //             scale: isSelected ? 0.82 : 0.8,
                  //             child: AnimatedContainer(
                  //                 duration: Duration(milliseconds: animationTime),
                  //                 decoration: BoxDecoration(
                  //                     boxShadow: [
                  //                       BoxShadow(
                  //                           color: Colors.black.withOpacity(0.15),
                  //                           spreadRadius: 0.5,
                  //                           blurRadius: 5,
                  //                           offset: Offset(0, 5.sh()))
                  //                     ],
                  //                     color: isSelected
                  //                         ? const Color(0xfff6f0f9)
                  //                         : const Color(0xfff6f0f9),
                  //                     shape: BoxShape.circle),

                  //                 child: Padding(
                  //                   padding: const EdgeInsets.all(3.0),
                  //                   child: CachedNetworkImage(
                  //                       imageUrl: subCategory!.image),
                  //                 )),
                  //           ),
                  //         ),
                  //       ],
                  //     );
                  //   })
                  : customShimmer(shape: BoxShape.circle),
            ),
          if (!loading) ...[
            SizedBox(
              height: 5.sh(),
            ),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.sw()),
                  child: AutoSizeText(
                    subCategory!.name,
                    textAlign: TextAlign.center,
                    minFontSize: 8,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : CustomTheme.getBlackColor(),
                        fontSize: UniversalPlatform.isAndroid
                            ? 10.ssp()
                            : 18.ssp(min: 15.ssp()),
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600),
                  ),
                )),
            // Divider()
          ] else
            customShimmer(height: 13.sh())
        ],
      ),
    );
  }
}
