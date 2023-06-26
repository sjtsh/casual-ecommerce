import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
import 'package:ezdelivershop/StateManagement/SignInManagement.dart';
import 'package:ezdelivershop/UI/ProfileScreen/General/CheckAvailabilityToEdit.dart';
import 'package:ezdelivershop/UI/ProfileScreen/General/Widgets/VerifyOtpScreen.dart';
import 'package:flutter/material.dart';

import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/Components/CustomTextField2.dart';
import 'package:ezdelivershop/Components/Widgets/Button.dart';
import 'package:ezdelivershop/Components/Widgets/CustomAppBar.dart';
import 'package:ezdelivershop/Components/Widgets/CustomSafeArea.dart';
import 'package:ezdelivershop/Components/snackbar/customsnackbar.dart';
import 'package:provider/provider.dart';

import '../../../../BackEnd/Services/EditProfileService/EditProfileService.dart';
import '../../../../BackEnd/Services/OtpService/OtpService.dart';
import '../../../../BackEnd/Services/resetPasswordService.dart';
import 'Warning.dart';

class EditPhoneNumber extends StatefulWidget {
  const EditPhoneNumber({super.key});

  @override
  State<EditPhoneNumber> createState() => _EditPhoneNumberState();
}

class _EditPhoneNumberState extends State<EditPhoneNumber> {
  TextEditingController phoneController = TextEditingController();
  String? errorText;
  int? remTime;
  RegExp intValid = RegExp(r'^([0-9]{10})+$');

  @override
  void initState() {
    super.initState();
    phoneController.text = context.read<SignInManagement>().loginData!.user.phone;
    checkFunction();
  }

  checkFunction() async {
    if (context.read<SignInManagement>().loginData != null) {
      remTime = await EditProfileService().checkEditValidity("phone");
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
        child: Scaffold(
      body: Column(
        children: [
          const CustomAppBar(
            title: "Edit",
            leftButton: true,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  SpacePalette.spaceMedium,
                  CustomTextField2(
                    labelText: "Phone Number",
                    errorText: errorText,
                    controller: phoneController,
                    onChanged: (val) {
                      if (phoneController.text.trim() == "") {
                        setState(() {
                          errorText = "Please type your phone number";
                        });
                      } else if (intValid
                          .hasMatch(phoneController.text.trim())) {
                        setState(() {
                          errorText = null;
                        });
                      } else {
                        setState(() {
                          errorText =
                          "Phone number must contain 10 digits";
                        });
                      }
                    },
                  ),
                  SpacePalette.spaceTiny,
                  Warning(
                      infoText: remTime == null
                          ? "You will be able to update your phone number only once a day."
                          : "You cannot change phone number for next ${(remTime! / (3600000)).round()} hours."),
                  SpacePalette.spaceExtraLarge,
                  Row(
                    children: [
                      Expanded(
                          child: AppButtonPrimary(
                              onPressedFunction: () async {
                                OtpService read = context.read<OtpService>();
                                NavigatorState nav = Navigator.of(context);
                                if (phoneController.text.trim() == "") {
                                  setState(() {
                                    errorText = "Please type your phone number";
                                  });
                                } else if (intValid
                                    .hasMatch(phoneController.text.trim())) {
                                  setState(() {
                                    errorText = null;
                                  });
                                } else {
                                  setState(() {
                                    errorText =
                                        "Phone number must contain 10 digits";
                                  });
                                }
                                if (phoneController.text.trim() ==
                                    context
                                        .read<SignInManagement>()
                                        .loginData!.user
                                        .phone) {
                                  setState(() {
                                    errorText =
                                        "Please provide different phone number";
                                  });
                                } else {
                                  CheckAvailabilityToEdit.checkValidity(
                                      context, "phone", "phone number",
                                      () async {
                                    bool newNumber =
                                        await ResetPasswordService()
                                            .checkShopForgotPassword(
                                                phone: phoneController.text);
                                    if (newNumber) {
                                      bool status = await read.sendCode(
                                          context: context,
                                          newPhone:
                                              "+977${phoneController.text.trim()}");
                                      if (status) {
                                        read.pinController =
                                            TextEditingController();
                                        StaticService.pushPage(
                                            context: context,
                                            route: VerifyOtpScreen(
                                              phoneNumber:
                                                  phoneController.text.trim(),
                                            ));
                                      } else {
                                        CustomSnackBar()
                                            .error("Verification failed.");
                                      }
                                    } else {
                                      CustomSnackBar()
                                          .error("Number already used");
                                    }
                                  });
                                }
                              },
                              text: "Update")),
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

  phoneValidation() {
    bool myPersonalValidation = false;
    RegExp intValid = RegExp(r'^([0-9]{10})+$');
    if (phoneController.text.trim() == "") {
      errorText = "Please enter Number";
    } else if (intValid.hasMatch(phoneController.text.trim())) {
      errorText = null;
      myPersonalValidation = true;
    } else {
      errorText = "Phone number must contain 10 digits";
    }
    return myPersonalValidation;
  }
}
