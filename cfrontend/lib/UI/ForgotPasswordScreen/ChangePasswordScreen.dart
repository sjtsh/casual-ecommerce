import 'package:ezdelivershop/BackEnd/Services/OtpService/OtpService.dart';
import 'package:ezdelivershop/BackEnd/Services/resetPasswordService.dart';
import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/Components/Widgets/Button.dart';
import 'package:ezdelivershop/Components/Widgets/CustomAppBar.dart';
import 'package:ezdelivershop/Components/Widgets/CustomSafeArea.dart';
import 'package:ezdelivershop/Components/snackbar/customsnackbar.dart';
import 'package:ezdelivershop/StateManagement/ResetPasswordManageMent.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Components/CustomTextField2.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
        child: Scaffold(
      body: Column(
        children: [
           CustomAppBar(
            title: "Reset Password",
            leftButton: true,
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                CustomTextField2(
                  errorText: context
                      .watch<ResetPasswordManagement>()
                      .newPasswordErrorText,
                  controller:
                      context.read<ResetPasswordManagement>().newPassword,
                  labelText: "New password",
                  obscureText: context
                      .watch<ResetPasswordManagement>()
                      .newPasswordVisibility,
                  onObscurePressed: () {
                    context
                        .read<ResetPasswordManagement>()
                        .showPassword(newPassword: true);
                  },
                  onChanged: (val) {
                    context
                        .read<ResetPasswordManagement>()
                        .newPasswordValidation();
                    context.read<ResetPasswordManagement>().matchPasswordNew(val);
                  },
                ),
                SpacePalette.spaceMedium,
                CustomTextField2(
                  errorText: context
                      .watch<ResetPasswordManagement>()
                      .confirmPasswordErrorText,
                  labelText: "Confirm password",
                  obscureText: context
                      .watch<ResetPasswordManagement>()
                      .confirmPasswordVisibility,
                  onObscurePressed: () {
                    context
                        .read<ResetPasswordManagement>()
                        .showPassword(newPassword: false);
                  },
                  controller:
                      context.read<ResetPasswordManagement>().confirmPassword,
                  onChanged: (val) {
                    context
                        .read<ResetPasswordManagement>()
                        .confirmPasswordValidation();
                    context.read<ResetPasswordManagement>().matchPasswordConfirm(val);
                  },
                ),
                context.read<ResetPasswordManagement>().passwordMatched
                    ?  Text("Password matched", style: TextStyle(color: ColorPalette.successColor),)
                    : Container(),
                SpacePalette.spaceExtraLarge,
                AppButtonPrimary(
                  isdisable: !context.read<ResetPasswordManagement>().passwordMatched,
                    onPressedFunction: () async {
                      NavigatorState nav = Navigator.of(context);
                      bool isValidated = context
                          .read<ResetPasswordManagement>()
                          .passWordValidationFromForgetPassword();
                      if (isValidated) {
                        bool success = await ResetPasswordService().newPassword(
                            context
                                .read<OtpService>()
                                .phone!.substring(4),
                            context
                                .read<ResetPasswordManagement>()
                                .confirmPassword
                                .text,
                            context
                                .read<OtpService>()
                                .uid!
                                );
                        if(success){

                          CustomSnackBar().success("Password reset successful");
                          context.read<ResetPasswordManagement>().clearData();
                          FirebaseAnalytics.instance
                              .logEvent(name: "ChangePassword", parameters: {
                            "phone": context
                                .read<OtpService>()
                                .phone?.substring(4)});
                          while (nav.canPop()) {
                            nav.pop();
                          }
                        }else{
                          CustomSnackBar().error("Password reset failed");
                        }
                      }

                    },
                    text: "Reset password")
              ],
            ),
          ))
        ],
      ),
    ));
  }
}
