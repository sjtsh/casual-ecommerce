import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
import 'package:ezdelivershop/Components/AppDivider/Appdivider.dart';
import 'package:ezdelivershop/Components/Widgets/CustomAppBar.dart';
import 'package:ezdelivershop/Components/Widgets/CustomSafeArea.dart';
import 'package:ezdelivershop/Components/snackbar/customsnackbar.dart';
import 'package:ezdelivershop/UI/ProfileScreen/General/Widgets/EditOwnerName.dart';
import 'package:ezdelivershop/UI/ProfileScreen/General/Widgets/EditPhoneNumber.dart';
import 'package:ezdelivershop/UI/ProfileScreen/Widgets/SettingsInfo.dart';
import 'package:flutter/material.dart';

class GeneralInfoEdit extends StatelessWidget {
  const GeneralInfoEdit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
        child: Scaffold(
      body: Column(
        children: [
         const CustomAppBar(
            title: "General",
            leftButton: true,
          ),
          Expanded(
              child: ListView(
            children: [
              SettingsInfo(
                text: "Owner Name",
                icon: const Icon(Icons.person_outline, color: Colors.grey),
                darkModeIcon: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                ),
                onTap: () async {
                  StaticService.pushPage(context: context, route: EditOwnerName());
                },
              ),
             const AppDivider(),
              SettingsInfo(
                text: "Change Phone Number",
                icon: const Icon(Icons.phone_outlined, color: Colors.grey),
                darkModeIcon: const Icon(
                  Icons.phone_outlined,
                  color: Colors.white,
                ),
                onTap: () async {
                  StaticService.pushPage(context: context, route: EditPhoneNumber());
                  // checkValidity(context, "phone", "phone number",EditPhoneNumber() );
                },
              ),
              const AppDivider(),
              SettingsInfo(
                text: "Delete Account",
                icon: const Icon(Icons.person_remove_alt_1_outlined, color: Colors.grey),
                darkModeIcon: const Icon(
                  Icons.person_remove_alt_1_outlined,
                  color: Colors.white,
                ),
                onTap: () async {
                  // StaticService.pushPage(context: context, route: DeleteAccount());
                  CustomSnackBar().info("Service currently unavailable");
                },
              ),
            ],
          ))
        ],
      ),
    ));
  }

  // checkValidity(BuildContext context, String key, String message, Widget route)async {
  //
  //   if (context.read<SignInManagement>().shop != null) {
  //     int? validate =
  //         await EditProfileService().checkEditValidity(key);
  //     if (validate == null) {
  //       StaticService.pushPage(
  //           context: context, route: route);
  //     } else {
  //       StaticService.showDialogBox(
  //           context: context,
  //           child: ConfirmationDialogBox(
  //               title: "Info",
  //               subTitle:
  //               "You cannot change $message for next ${(validate / (3600000)).round()} hours.",
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               }));
  //     }
  //   } else {
  //     CustomSnackBar().info("Service Unavailable right now.");
  //   }
  // }
}
