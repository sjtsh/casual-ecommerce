import 'package:dotted_border/dotted_border.dart';
import 'package:ezdeliver/screen/addressDetails/addresses.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/favourite/favourite.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';

import 'package:ezdeliver/screen/profile/profilesettings.dart';
import 'package:ezdeliver/screen/settingsscreen/components/themeselector.dart';
import 'package:ezdeliver/screen/settingsscreen/models/menuItems.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

final settingsIndexProvider = StateProvider<int>((ref) {
  return 1;
});

class SettingsScreen extends ConsumerWidget {
  SettingsScreen({super.key, this.log = false});
  final bool log;
  final List<MenuItems> menu = [
    MenuItems(
        menuIcon: Icons.person,
        menuName: 'Edit profile',
        id: '1',
        onPressed: (context) async {
          CustomKeys.ref.read(settingsIndexProvider.notifier).state = 1;
          // // if (!CustomKeys.ref.read(CustomSocket.socketStatusProvider)) {
          // CustomKeys.ref
          //     .read(orderHistoryServiceProvider)
          //     .fetchOrders(clear: true);
          // }
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return const OrderHistory();
          // }));
          if (ResponsiveLayout.isMobile) {
            await Utilities.pushPage(ProfileSetting(), 15, context: context);
          } else {
            ResponsiveLayout.setProfileWidget(ProfileSetting());
          }
        }),
    MenuItems(
      menuIcon: GroceliIcon.home_small,
      menuName: 'My Address',
      id: '2',
      onPressed: (context) async {
        CustomKeys.ref.read(settingsIndexProvider.notifier).state = 2;
        if (ResponsiveLayout.isMobile) {
          await Utilities.pushPage(const Addresses(), 15, context: context);
        } else {
          ResponsiveLayout.setProfileWidget(const Addresses());
        }
      },
    ),
    MenuItems(
        menuIcon: GroceliIcon.heart,
        menuName: 'Favorites',
        id: '3',
        onPressed: (context) async {
          CustomKeys.ref.read(settingsIndexProvider.notifier).state = 3;
          if (ResponsiveLayout.isMobile) {
            await Utilities.pushPage(const FavouriteScreen(), 15,
                context: context);
          } else {
            ResponsiveLayout.setProfileWidget(const FavouriteScreen());
          }
        }),
    MenuItems(
        menuIcon: Icons.dark_mode,
        menuName: 'Theme',
        id: '4',
        onPressed: (context) async {
          CustomKeys.ref.read(settingsIndexProvider.notifier).state = 4;
          if (ResponsiveLayout.isMobile) {
            showModalBottomSheet(
                backgroundColor: Theme.of(context).backgroundColor,
                context: context,
                builder: (context) {
                  return const ThemeSelector();
                });
          } else {
            ResponsiveLayout.setProfileWidget(const ThemeSelector());
          }
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
    final user = ref.watch(userChangeProvider).loggedInUser.value;

    return Scaffold(
      appBar: simpleAppBar(context,
          title: "Settings",
          close: ResponsiveLayout.isMobile ? true : false,
          centerTitle: ResponsiveLayout.isMobile ? true : false,
          search: false),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                SizedBox(
                  height: 60.sh(),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    DottedBorder(
                      padding: EdgeInsets.all(8.sr()),
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 1,
                      borderType: BorderType.Circle,
                      dashPattern: const [6, 4],
                      child: GestureDetector(
                        onTap: () async {
                          if (log) {
                            await FirebaseAnalytics.instance
                                .logEvent(name: "Profile_avatar", parameters: {
                              "id": ref
                                  .read(userChangeProvider)
                                  .loggedInUser
                                  .value
                                  ?.id,
                              "name": ref
                                  .read(userChangeProvider)
                                  .loggedInUser
                                  .value
                                  ?.name
                            });
                          }
                        },
                        child: Container(
                          width: 92.sr(),
                          height: 92.sr(),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Center(
                            child: Text(
                              getImage("${user?.name}"),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline1!
                                  .copyWith(color: CustomTheme.whiteColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Positioned(
                    //   bottom: -10.sh(),
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       if (!Api.production) {
                    //         Future.delayed(const Duration(milliseconds: 1), () {
                    //           return Utilities.pushPage(ProfileSetting(), 15);

                    //           // return showDialog(
                    //           //     context: context,
                    //           //     builder: (context) {
                    //           //       return CustomDialog(
                    //           //           textSecond: 'Delete this account?',
                    //           //           elevatedButtonText: 'Confirm',
                    //           //           onPressedElevated: () async {
                    //           //             ref
                    //           //                 .read(userChangeProvider)
                    //           //                 .deleteAccount(context: context);
                    //           //           });
                    //           //     });
                    //         });
                    //       }
                    //     },
                    //     child: Container(
                    //       padding: EdgeInsets.all(2.sr()),
                    //       decoration: BoxDecoration(
                    //           color: Theme.of(context).backgroundColor,
                    //           shape: BoxShape.circle),
                    //       child: Container(
                    //           decoration: BoxDecoration(
                    //               shape: BoxShape.circle,
                    //               color: Theme.of(context).primaryColor),
                    //           child: const Icon(
                    //             GroceliIcon.edit,
                    //             color: CustomTheme.whiteColor,
                    //           )),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),

                SizedBox(
                  height: 14.sh(),
                ),
                // ? this code works
                // CustomRating(
                //     align: MainAxisAlignment.center,
                //     showLabel: false,
                //     allowHalfRating: true,
                //     ignoreGestures: true,
                //     rating:
                //         user.avgRating! > 0.0 ? clapRatinValue(user.avgRating!) : 0,
                //     itemSize: 18.sr()),
                // SizedBox(
                //   height: 10.sh(),
                // ),
                // ?
                Text(
                  "${user?.name}",
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 6.sh(),
                ),
                GestureDetector(
                  child: Text("${user?.phone}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: Theme.of(context).primaryColor)),
                ),

                SizedBox(
                  height: 60.sh(),
                ),

                // ListTile(
                //   leading: Container(
                //     width: 50.sr(),
                //     decoration: const BoxDecoration(
                //       shape: BoxShape.circle,
                //       color: Colors.blue,
                //       image: DecorationImage(
                //           image: NetworkImage(
                //         'https://assets-global.website-files.com/5ec7dad2e6f6295a9e2a23dd/6222481c0ad8761618b18e7e_profile-picture.jpg',
                //       )),
                //     ),
                //   ),
                //   title: Row(
                //     children: [
                //       Text(user != null ? user.name : "",
                //           style: Theme.of(context)
                //               .textTheme
                //               .bodyText2!
                //               .copyWith(color: Colors.black, fontSize: 20.ssp())),
                //       SizedBox(
                //         width: 5.sw(),
                //       ),
                //       Icon(
                //         Icons.mode_edit_outline,
                //         size: 18.ssp(),
                //       )
                //     ],
                //   ),
                //   subtitle: Text(user != null ? user.phone : '',
                //       style: Theme.of(context)
                //           .textTheme
                //           .bodyText2!
                //           .copyWith(fontSize: 16.ssp())),
                // ),
                // const Divider(),
                Expanded(
                  child: ListView.separated(
                      itemBuilder: ((context, index) {
                        return MenuItemWidget(item: menu[index]);
                      }),
                      separatorBuilder: ((context, index) {
                        return Divider(
                          color: CustomTheme.getBlackColor().withOpacity(0.1),
                          thickness: 1,
                          height: 0.3,
                        );
                      }),
                      itemCount: menu.length),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 22.sw(), vertical: 12.sh()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // spacing: 8.sr(),
                    children: [
                      showFromWebsite(
                          Uri.https("faasto.co", "/terms-of-service"),
                          "Terms & Conditions"),
                      showFromWebsite(
                          Uri.https("faasto.co", "/shipping-policy"),
                          "Shipping Policy"),
                      showFromWebsite(
                          Uri.https("faasto.co", "/return-refund-policy"),
                          "Return & Refund",
                          showDot: false)
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!ResponsiveLayout.isMobile)
            Expanded(
              flex: 5,
              child: LayoutBuilder(builder: (context, constraint) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: constraint.maxWidth * .1),
                  child: ref.watch(ResponsiveLayout.settingsWidgetProvider),
                );
              }),
            )
        ],
      ),
    );
  }

  InkWell showFromWebsite(Uri uri, String label, {bool showDot = true}) {
    return InkWell(
        onTap: () {
          showModalBottomSheet(
              context: CustomKeys.context,
              isScrollControlled: true,
              enableDrag: false,
              builder: (context) {
                return CustomInAppWebView(
                  uri: uri,
                );
              });

          // HeadlessInAppWebView(
          //         initialUrlRequest: URLRequest(
          //             url: Uri.https("faasto.co", "/terms-of-service")))
          //     .run();
        },
        child: Row(
          children: [
            Text(label,
                style:
                    Theme.of(CustomKeys.context).textTheme.bodySmall!.copyWith(
                          color: CustomTheme.primaryColor,
                        )),
            if (showDot)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5.sr()),
                decoration: const BoxDecoration(
                    color: Colors.grey, shape: BoxShape.circle),
                width: 5.sr(),
                height: 5.sr(),
              )
          ],
        ));
  }
}

class CustomInAppWebView extends StatefulWidget {
  const CustomInAppWebView({super.key, required this.uri});
  final Uri uri;
  @override
  State<CustomInAppWebView> createState() => _CustomInAppWebViewState();
}

class _CustomInAppWebViewState extends State<CustomInAppWebView> {
  int progress = 0;
  bool error = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Stack(
          children: [
            if (!error)
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: widget.uri,
                ),
                onProgressChanged: (controller, p) {
                  setState(() {
                    progress = p;
                  });
                },
                onLoadError: (controller, url, code, message) {
                  setState(() {
                    error = true;
                  });
                },
              )
            else
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: InfoMessage.skeleton(
                    title: "",
                    label: "Please try again later",
                    boldTitle: "Oops! Some Error occured"),
              ),
            if (progress < 100 && !error)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: progress / 100,
                ),
              ),
            const Positioned(
              right: 0,
              top: 0,
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: CloseButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItemWidget extends ConsumerWidget {
  const MenuItemWidget({super.key, required this.item});
  final MenuItems item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding:
            EdgeInsets.symmetric(horizontal: 30.sw(), vertical: 5.sh()),
        onTap: () {
          item.onPressed(context);
        },
        leading: Icon(
          item.menuIcon,
          size: 20.ssp(),
          color: ref.watch(settingsIndexProvider) == int.parse(item.id)
              ? CustomTheme.primaryColor
              : CustomTheme.getBlackColor(),
        ),
        title: Text(item.menuName,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontWeight:
                    ref.watch(settingsIndexProvider) == int.parse(item.id)
                        ? FontWeight.bold
                        : null,
                color: ref.watch(settingsIndexProvider) == int.parse(item.id)
                    ? CustomTheme.primaryColor
                    : null)),
      ),
    );
  }
}
