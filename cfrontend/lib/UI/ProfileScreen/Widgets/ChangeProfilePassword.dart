import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/Components/CustomTextField2.dart';
import 'package:ezdelivershop/Components/Widgets/Button.dart';
import 'package:ezdelivershop/Components/Widgets/CustomAppBar.dart';
import 'package:ezdelivershop/Components/Widgets/CustomSafeArea.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../StateManagement/ResetPasswordManageMent.dart';

class ChangeProfilePassword  extends StatelessWidget {
  const ChangeProfilePassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(child: Scaffold(
      body: Column(
        children:  [
         CustomAppBar(
            title: "Change Password",
            leftButton: true,
          ),
          Expanded(
            child: Padding(
              padding: SpacePalette.paddingExtraLarge,
              child: ListView(
                children: [
                  SpacePalette.spaceMedium,
                  CustomTextField2(labelText: "Current password",
                    errorText: context
                        .watch<ResetPasswordManagement>()
                        .currentPasswordErrorText,
                    controller:
                    context.read<ResetPasswordManagement>().currentPassword,
                    obscureText: context
                        .watch<ResetPasswordManagement>()
                        .currentPasswordVisibility,
                    onObscurePressed: () {
                      context
                          .read<ResetPasswordManagement>()
                          .showPasswordProfile();
                    },),
                  SpacePalette.spaceMedium,
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
                  SpacePalette.spaceExtraLarge,
                  Row(
                    children: [
                      Expanded(child: AppButtonPrimary(
                        isdisable: !context.watch<ResetPasswordManagement>().passwordMatched ,
                          onPressedFunction: ()async{
                          context
                                .read<ResetPasswordManagement>()
                                .changePasswordFromProfile(context);
                      }, text: "Change Password")),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }
}
