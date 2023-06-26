import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/holder/holder.dart';
import 'package:ezdeliver/screen/others/breakpoint.dart';
import 'package:ezdeliver/screen/settingsscreen/models/menuItems.dart';
import 'package:ezdeliver/screen/search/searchService.dart';
import 'package:ezdeliver/screen/settingsscreen/settingsscreen.dart';


class UpperSection extends ConsumerWidget {
  UpperSection({required this.scrollController, super.key});

  final ScrollController? scrollController;
  final List<MenuItems> menu = [
    MenuItems(
        menuIcon: Icons.person,
        menuName: 'Settings',
        id: '22',
        onPressed: (context) async {
          Utilities.checkIfLoggedIn(
              context: context,
              doIfLoggedIN: () {
                if (!ResponsiveLayout.isMobile) {
                  CustomKeys.ref.read(statelistProvider).holderwidget =
                      SettingsScreen();
                  Navigator.pop(context);
                  return;
                }
                // Utilities.pushPage(SettingsScreen(), 15);
              });
        }),
    MenuItems(
        menuIcon: GroceliIcon.logout,
        menuName: 'Logout',
        onPressed: (context) {
          Future.delayed(const Duration(milliseconds: 15), () {
            return showDialog(
                context: context,
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveLayout.margin(0.25)),
                    child: CustomDialog(
                        textSecond: 'logout?',
                        elevatedButtonText: 'Confirm',
                        onPressedElevated: () async {
                          logout(context);
                        }),
                  );
                });
          });
        },
        id: '5')
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subCategoryItems = CustomKeys.ref
        .read(productCategoryServiceProvider)
        .dropDownCategoryItems;
    // print(subCategoryItems.length);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // if (ResponsiveLayout.isDesktop)
              //   SizedBox(
              //     width: 50.sw(),
              //   ),
              Text(
                ResponsiveLayout.isTablet ? "F" : "Faasto",
                style: Theme.of(context).textTheme.headline1!.copyWith(
                    color: CustomTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 26.ssp()),
              ),
              SizedBox(
                width: 11.sw(),
              ),
              Container(
                color: CustomTheme.blackColor,
                height: 25.ssp(),
                width: 2.sw(),
              ),
              SizedBox(
                width: 10.sw(),
              ),
              const Expanded(child: AddressInfoBox()),
              SizedBox(
                width: ResponsiveLayout.isDesktop ? 26.sw() : 10.sw(),
              ),
              Expanded(
                flex: ResponsiveLayout.isTablet ? 3 : 5,
                child: Stack(
                  children: [
                    TextField(
                      controller: ref.read(ref
                          .read(searchServiceProvider)
                          .searchWebFieldProvider),
                      onSubmitted: (query) {
                        if (query.isNotEmpty) {
                          ref
                              .read(searchServiceProvider)
                              .searchProductsForWeb(query);
                        }
                      },
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: () {
                          String query = ref
                              .read(ref
                                  .read(searchServiceProvider)
                                  .searchWebFieldProvider)
                              .text;
                          if (query.isNotEmpty) {
                            ref
                                .read(searchServiceProvider)
                                .searchProductsForWeb(query);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(5),
                                bottomRight: Radius.circular(5)),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12.sw()),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.search,
                                color: CustomTheme.whiteColor,
                              ),
                              if (ResponsiveLayout.isDesktop) ...[
                                SizedBox(
                                  width: 5.sw(),
                                ),
                                Text(
                                  "Search",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(color: Colors.white),
                                )
                              ]
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                // Row(
                //   children: [
                //     Expanded(
                //         flex: 7,
                //         child: TextField(
                //           decoration: InputDecoration(
                //             focusedBorder: OutlineInputBorder(
                //               borderSide: BorderSide(
                //                   width: 1.5,
                //                   color: CustomTheme.getFilledPrimaryColor()
                //                       .withOpacity(0.25)),
                //               borderRadius: BorderRadius.only(
                //                 topLeft: Radius.circular(
                //                   6.sr(),
                //                 ),
                //                 bottomLeft: Radius.circular(
                //                   6.sr(),
                //                 ),
                //               ),
                //             ),
                //             enabledBorder: OutlineInputBorder(
                //               borderSide: BorderSide(
                //                   width: 1.5,
                //                   color: CustomTheme.getFilledPrimaryColor()
                //                       .withOpacity(0.25)),
                //               borderRadius: BorderRadius.only(
                //                 topLeft: Radius.circular(
                //                   6.sr(),
                //                 ),
                //                 bottomLeft: Radius.circular(
                //                   6.sr(),
                //                 ),
                //               ),
                //             ),
                //             // border: OutlineInputBorder(
                //             //   borderRadius: BorderRadius.only(
                //             //     topLeft: Radius.circular(
                //             //       6.sr(),
                //             //     ),
                //             //     bottomLeft: Radius.circular(
                //             //       6.sr(),
                //             //     ),
                //             //   ),
                //             // ),
                //           ),
                //         )),
                //     Expanded(
                //       child: InkWell(
                //         onTap: () {},
                //         child: const CupertinoTextField(),
                //       ),
                //     ),
                //   ],
                // ),
              ),
              SizedBox(
                width: 22.sw(),
              ),
              InkWell(
                onTap: () {
                  ResponsiveLayout.openCommonCart(true);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: CustomTheme.getFilledPrimaryColor(),
                    border: Border.all(
                      color: CustomTheme.getFilledPrimaryColor(),
                    ),
                    borderRadius: BorderRadius.circular(
                      4.sr(),
                    ),
                  ),
                  padding: EdgeInsets.all(10.sr()),
                  child: const CartBottomNav(up: false),
                ),
              ),
              SizedBox(
                width: 17.sw(),
              ),
              Expanded(
                child: Builder(builder: (context) {
                  final user = ref.watch(userChangeProvider).loggedInUser.value;
                  return PopupMenuButton(
                      color: CustomTheme.getBlackColor(opposite: true),
                      offset: Offset(0, 50.sh()),
                      // elevation: 200,
                      tooltip: "",
                      child: Stack(
                        children: [
                          const TextField(),
                          Positioned.fill(
                            top: 0,
                            bottom: 0,
                            child: user == null
                                ? CustomElevatedButton(
                                    // suffixIcon: Icons.expand_more,
                                    onPressedElevated: () {
                                      Utilities.checkIfLoggedIn(
                                          context: context,
                                          doIfLoggedIN: () {
                                            // if (!ResponsiveLayout.isMobile) {
                                            //   ref
                                            //       .read(ResponsiveLayout
                                            //           .holderWidgetProvider
                                            //           .notifier)
                                            //       .state = SettingsScreen();
                                            //   return;
                                            // }
                                            // Utilities.pushPage(SettingsScreen(), 15);
                                          });
                                    },
                                    elevatedButtonText: "Log In")
                                : Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.sw(), vertical: 12.sr()),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(5.sr())),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            user.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .copyWith(
                                                  fontSize: 14.sr(),
                                                  color: CustomTheme.whiteColor,
                                                  fontWeight: FontWeight.w600,
                                                  // fontSize: 15.ssp(),
                                                ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.expand_more,
                                          color: CustomTheme.whiteColor,
                                        )
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(child: MenuItemWidget(item: menu[0])),
                          PopupMenuItem(child: MenuItemWidget(item: menu[1]))
                        ];
                      });
                }),
              ),
              // Builder(builder: (context) {
              //   final user = ref.watch(userChangeProvider).loggedInUser.value;
              //   return CustomElevatedButton(
              //       suffixIcon: Icons.expand_more,
              //       onPressedElevated: () {
              //         Utilities.checkIfLoggedIn(
              //             context: context,
              //             doIfLoggedIN: () {
              //               if (!ResponsiveLayout.isMobile) {
              //                 ref
              //                     .read(ResponsiveLayout
              //                         .holderWidgetProvider.notifier)
              //                     .state = SettingsScreen();
              //                 return;
              //               }
              //               // Utilities.pushPage(SettingsScreen(), 15);
              //             });
              //       },
              //       elevatedButtonText: user == null ? "Log In" : user.name);
              // }),
              // if (ResponsiveLayout.isDesktop)
              //   SizedBox(
              //     width: 50.sw(),
              //   ),
            ],
          ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // if (subCategoryItems.isNotEmpty)
            //   CustomMenuDropDown(
            //     hint: "Sub Category",
            //     value: subCategoryItems.first,
            //     onChanged: (val) {},
            //     values: subCategoryItems,
            //   ),
            pressText(context, "Home", selected: ref.watch(indexProvider) == 0,
                function: () {
              handleNavigationClick(context, 0, scrollController);
            }),
            pressText(context, "Categories",
                selected: ref.watch(indexProvider) == 1, function: () {
              handleNavigationClick(context, 1, scrollController);
            }),
            pressText(context, "Orders",
                selected: ref.watch(indexProvider) == 2, function: () {
              Utilities.checkIfLoggedIn(
                  context: context,
                  doIfLoggedIN: () {
                    handleNavigationClick(context, 2, scrollController);
                  });
            }),
            // Placeholder(
            //   fallbackHeight: 100,
            // )
          ],
        ),
        Divider(),
      ],
    );
  }

  Widget pressText(BuildContext context, String text,
      {Function? function, required bool selected}) {
    return InkWell(
      onTap: () {
        if (function != null) {
          function();
        }
      },
      child: Container(
        // color: CustomTheme.greyColor.withOpacity(0.1),
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color:
                  selected ? CustomTheme.primaryColor : CustomTheme.greyColor),
        ),
      ),
    );
  }
}
