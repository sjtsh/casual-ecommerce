import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../BackEnd/Services/EditProfileService/EditProfileService.dart';
import '../../../BackEnd/StaticService/StaticService.dart';
import '../../../Components/snackbar/customsnackbar.dart';
import '../../../StateManagement/SignInManagement.dart';
import '../../DialogBox/ConfirmationDialogBox.dart';

class CheckAvailabilityToEdit {

 static checkValidity(BuildContext context, String key, String message, Function updateFunction)async {

    if (context.read<SignInManagement>().loginData != null) {
      int? validate =
      await EditProfileService().checkEditValidity(key);
      if (validate == null) {
        updateFunction();
      } else {
        StaticService.showDialogBox(
            context: context,
            child: ConfirmationDialogBox(
                title: "Info",
                subTitle:
                "You cannot change $message for next ${(validate / (3600000)).round()} hours.",
                onPressed: () {
                  Navigator.of(context).pop();
                }));
      }
    } else {
      CustomSnackBar().info("Service Unavailable right now.");
    }
  }
}