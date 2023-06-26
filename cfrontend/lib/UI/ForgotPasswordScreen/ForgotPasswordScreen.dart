import 'package:ezdelivershop/BackEnd/Services/OtpService/OtpService.dart';
import 'package:ezdelivershop/BackEnd/Services/resetPasswordService.dart';
import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
import 'package:ezdelivershop/Components/Widgets/Button.dart';
import 'package:ezdelivershop/Components/Widgets/CustomAppBar.dart';
import 'package:ezdelivershop/Components/Widgets/CustomSafeArea.dart';
import 'package:ezdelivershop/Components/snackbar/customsnackbar.dart';
import 'package:ezdelivershop/StateManagement/ResetPasswordManageMent.dart';
import 'package:ezdelivershop/UI/OtpScreen/OtpScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Components/Constants/ColorPalette.dart';
import '../../Components/Constants/SpacePalette.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    OtpService read = context.read<OtpService>();
    ResetPasswordManagement read1 = context.read<ResetPasswordManagement>();
    return CustomSafeArea(
      child: Scaffold(
        body: Column(
          children: [
            CustomAppBar(
              leftButton: true,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Forgot Password",
                    style: Theme.of(context).textTheme.headline2?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500),
                  ),
                  SpacePalette.spaceTiny,
                  Text(
                    "No worries, We got you.",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SpacePalette.spaceExtraLarge,
                  TextField(
                    controller: context
                        .read<ResetPasswordManagement>()
                        .phoneNumberController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      context.read<ResetPasswordManagement>().phoneValidation();
                    },
                    autofillHints: const [AutofillHints.telephoneNumber],
                    decoration: InputDecoration(
                      errorText: context
                          .watch<ResetPasswordManagement>()
                          .phoneErrorText,
                      labelText: "Phone Number",
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorPalette.primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  SpacePalette.spaceExtraLarge,
                  SpacePalette.spaceExtraLarge,
                  AppButtonPrimary(
                      width: double.infinity,
                      onPressedFunction: () async {
                        context.read<OtpService>().pinController =
                            TextEditingController();
                        bool validation = context
                            .read<ResetPasswordManagement>()
                            .phoneValidation();
                        if (validation) {
                          var newUser = await ResetPasswordService()
                              .checkShopForgotPassword(
                                  phone: context
                                      .read<ResetPasswordManagement>()
                                      .phoneNumberController
                                      .text);
                          if (!newUser) {
                            read.phone =
                                "+977${read1.phoneNumberController.text}";
                            read.sendCode(context: context);
                            Future.delayed(const Duration(milliseconds: 10),
                                () async {
                              // await StaticService.pushPage(
                              //     context: context,
                              //     route: OtpScreen(
                              //       backOverride: true,
                              //       isSignUp: false,
                              //       title: "Verify Phone Number",
                              //       subtitle:
                              //           "An OTP has been sent to ${read.phone}.\nPlease enter the code to proceed.",
                              //     ));
                              context.read<ResetPasswordManagement>().newPassword.clear();
                              context.read<ResetPasswordManagement>().confirmPassword.clear();
                            });
                          } else {
                            CustomSnackBar().error("User not found");
                            return;
                          }
                        }
                        return;
                      },
                      text: "Next")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
