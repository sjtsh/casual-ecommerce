import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
import 'package:ezdelivershop/Components/AppDivider/Appdivider.dart';
import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/Components/CustomTheme.dart';
import 'package:ezdelivershop/Components/snackbar/customsnackbar.dart';
import 'package:ezdelivershop/UI/DialogBox/customdialogbox.dart';
import 'package:ezdelivershop/UI/ProfileScreen/Widgets/ShopInfoScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Components/Constants/Icon.dart';
import '../../Components/Widgets/CustomAppBar.dart';
import '../../Components/Widgets/CustomSafeArea.dart';
import '../../StateManagement/SignInManagement.dart';
import '../DeveloperModeUrlEdit.dart';
import '../Skeletons/ProfileScreenSkeleton.dart';
import 'TermsAndPrivacy/PrivacyPolicy.dart';
import 'Widgets/SettingsInfo.dart';
import 'Widgets/UserImage.dart';
import 'Widgets/ThemeScreen.dart';
import 'Widgets/shopInfo.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  // takePhoto(BuildContext context) async {
  //   XFile? a = (await StaticService.pushPage(
  //       context: context,
  //       route: ConfirmPermissionThen(
  //           permitted: false,
  //           child: PersonalCameraPreview(isToChangeImage: true))) as XFile?);
  //   if (a != null) {
  //     bool? success = await StaticService.showDialogBox(
  //         context: context, child: UploadingImageDialog(a), canDismiss: true);
  //     if (success == null) {
  //       return;
  //     }
  //     if (!success) {
  //       takePhoto(context);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        body: Column(
          children: [
            CustomAppBar(
              title: "Profile",
              // color: ColorPalette.primaryColor,
              leftButton: true,
              leftButtonFunction: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                children: [
                  context.watch<SignInManagement>().loginData == null
                      ? const ProfileSkeleton()
                      : Column(
                          children: [
                            const SizedBox(
                              height: 12,
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: const [
                                UserImage(),

                                // Positioned(
                                //   bottom: 0,
                                //   right: 0,
                                //   left: 0,
                                //   child: GestureDetector(
                                //     onTap: () => takePhoto(context),
                                //     child: CircleAvatar(
                                //       radius: 20,
                                //       backgroundColor:
                                //           ColorPalette.whiteColor,
                                //       child: Container(
                                //         height: 32,
                                //         width: 32,
                                //         decoration: BoxDecoration(
                                //           color:
                                //               Theme.of(context).primaryColor,
                                //           shape: BoxShape.circle,
                                //         ),
                                //         child: Center(
                                //           child: Icon(
                                //             Icons.edit,
                                //             color: ColorPalette.whiteColor,
                                //             size: 15,
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                            ShopInfo(
                                size: 16,
                                textColor:
                                    context.watch<CustomTheme>().isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                text: context
                                        .watch<SignInManagement>()
                                        .loginData
                                        ?.user
                                        .displayId
                                        .toString() ??
                                    ""),
                            ShopInfo(
                                size: 16,
                                textColor:
                                    context.read<CustomTheme>().isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                text: context
                                        .read<SignInManagement>()
                                        .loginData
                                        ?.user
                                        .name ??
                                    ""),
                            ShopInfo(
                                size: 14,
                                text: context
                                        .read<SignInManagement>()
                                        .loginData
                                        ?.user
                                        .phone ??
                                    "",
                                textColor: Colors.grey),
                            SpacePalette.spaceTiny,
                            // if (Roles.cont(DeliveryRoles.deliveryRolesDelivery))
                            //   const ShopRatingStatus(),
                            const SizedBox(
                              height: 24,
                            ),
                          ],
                        ),
                  // SettingsInfo(
                  //   onTap: () {
                  //     StaticService.pushPage(
                  //         context: context, route: const GeneralInfoEdit());
                  //   },
                  //   text: "General",
                  //   icon: AppIcon.lightProfile.widget,
                  //   darkModeIcon: AppIcon.darkProfile.widget,
                  // ),
                  // const AppDivider(),
                  // SettingsInfo(
                  //   onTap: () async {
                  //     await StaticService.pushPage(
                  //         context: context,
                  //         route: const ChangeProfilePassword());
                  //     context.read<ResetPasswordManagement>().clearData();
                  //   },
                  //   text: "Password",
                  //   icon: AppIcon.lightKey.widget,
                  //   darkModeIcon: AppIcon.darkKey.widget,
                  // ),
                  // const AppDivider(),
                  // SettingsInfo(
                  //   darkModeIcon: AppIcon.darkCategory.widget,
                  //   icon: AppIcon.category.widget,
                  //   text: "Categories",
                  //   onTap: () async {
                  //     StaticService.pushPage(
                  //         context: context,
                  //         route: CategoriesScreenBuilder(
                  //             context.read<SignInManagement>().shop!.categories,
                  //             isFromSignup: false));
                  //     // await checkValidity(
                  //     //      context,
                  //     //      "categories",
                  //     //      "category",
                  //     //      CategoriesScreenBuilder(
                  //     //          context.read<SignInManagement>().shop!.categories,
                  //     //          isFromSignup: false));
                  //   },
                  // ),
                  // const AppDivider(),
                  // SettingsInfo(
                  //   text: "Delivery Radius",
                  //   darkModeIcon: AppIcon.darkShop.widget,
                  //   icon: AppIcon.shop.widget,
                  //   onTap: () {
                  //     Navigator.push(context, MaterialPageRoute(builder: (_) {
                  //       return DeliveryRadiusScreen();
                  //     }));
                  //   },
                  //   details:
                  //       "${(context.watch<SignInManagement>().shop?.deliveryRadius ?? 0).toStringAsFixed(0)} m",
                  // ),
                  // const AppDivider(),
                  // SettingsInfo(
                  //   text: "Suggest a product",
                  //   darkModeIcon:  const Icon(Icons.lightbulb_outline, color: Colors.white,),
                  //   icon: const Icon(Icons.lightbulb_outline),
                  //   onTap: () {
                  //     showModalBottomSheet(
                  //         backgroundColor: Theme.of(context).backgroundColor,
                  //         isScrollControlled: true,
                  //         context: context,
                  //         builder: (context) {
                  //           return SuggestProductForm();
                  //         });
                  //   },
                  // ),
                  // const AppDivider(),
                  // SettingsInfo(
                  //   text: "Setting",
                  //   icon: AppIcon.lightSetting.widget,
                  //   darkModeIcon: AppIcon.darkSetting.widget,
                  //   onTap: () {
                  //     Navigator.push(context, MaterialPageRoute(builder: (_) {
                  //       return const SettingScreen();
                  //     }));
                  //   },
                  // ),
                  // const AppDivider(),
                  if (context.read<SignInManagement>().loginData?.staff.shop !=
                      null)
                    SettingsInfo(
                      text: "Partner Info",
                      darkModeIcon: const Icon(
                        Icons.store,
                        color: Colors.white,
                      ),
                      icon: const Icon(
                        Icons.store,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        StaticService.pushPage(
                            context: context, route: ShopInfoList());
                      },
                    ),
                  const AppDivider(),
                  SettingsInfo(
                    text: "Theme",
                    darkModeIcon: AppIcon.darkTheme.widget,
                    icon: AppIcon.lightTheme.widget,
                    onTap: () {
                      StaticService.pushPage(
                          context: context, route: const ThemeScreen());
                    },
                  ),
                  const AppDivider(),
                  SettingsInfo(
                    text: "Call Support",
                    darkModeIcon: const Icon(Icons.call, color: Colors.white,size: 20,),
                    icon:const Icon(Icons.call, color: Colors.grey,size: 20),
                    onTap: () async {
                      int? supp = context
                          .read<SignInManagement>()
                          .loginData
                          ?.staff
                          .support;
                      print(supp);
                      if (supp == null) {
                        return CustomSnackBar()
                            .info("Support currently unavailable");
                      }
                      showDialog(
                          context: context,
                          builder: (_) => CustomDialog(
                                elevatedButtonText: "Call",
                                textFirst:
                                    "Are you sure you want to call support?",
                                textSecond: supp.toString(),
                                onPressedElevated: () async {
                                  try {
                                    await launchUrl(Uri(
                                      scheme: 'tel',
                                      path: supp.toString(),
                                    ));
                                  } catch (e) {}
                                },
                              ));
                    },
                  ),
                  const AppDivider(),
                  SettingsInfo(
                    text: "Logout",
                    darkModeIcon: AppIcon.darkLogOut.widget,
                    icon: AppIcon.logOut.widget,
                    onTap: () {
                      StaticService.showDialogBox(
                          context: context,
                          child: CustomDialog(
                            textFirst: "Log Out !",
                            textSecond: "Are you sure to log out?",
                            elevatedButtonText: "Ok",
                            onPressedElevated: () {
                              context.read<SignInManagement>().logout(context);
                            },
                            outlinedButtonText: "Cancel",
                          ));
                    },
                  ),
                  const AppDivider(),
                  // SpacePalette.spaceMedium,
                  Opacity(
                      opacity: kDebugMode ? 1 : 0,
                      child: DeveloperModeUrlEdit()),
                  SpacePalette.spaceMedium,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () {
                            StaticService.pushPage(
                                context: context,
                                route: CustomInAppWebView(
                                  uri: Uri.parse(
                                  "https://www.faasto.co/partner-terms-of-service",),

                                ));
                          },
                          child: Text(
                            "Terms and conditions",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                ?.copyWith(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor),
                          )),
                      const CircleAvatar(
                        radius: 2,
                        backgroundColor: Colors.grey,
                      ),
                      TextButton(
                          onPressed: () {
                            StaticService.pushPage(
                                context: context,
                                route: CustomInAppWebView(
                                  uri:
                                  Uri.parse(
                                    "https://www.faasto.co/partner-terms-of-service",),
                                ));
                          },
                          child: Text("Privacy policy",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  ?.copyWith(
                                      fontSize: 12,
                                      color: Theme.of(context).primaryColor))),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
