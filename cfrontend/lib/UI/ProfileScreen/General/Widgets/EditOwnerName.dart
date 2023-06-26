import 'package:ezdelivershop/BackEnd/Services/EditProfileService/EditProfileService.dart';
import 'package:ezdelivershop/StateManagement/SignInManagement.dart';
import 'package:ezdelivershop/UI/ProfileScreen/General/CheckAvailabilityToEdit.dart';
import 'package:ezdelivershop/UI/ProfileScreen/General/Widgets/Warning.dart';
import 'package:flutter/material.dart';

import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/Components/CustomTextField2.dart';
import 'package:ezdelivershop/Components/Widgets/Button.dart';
import 'package:ezdelivershop/Components/Widgets/CustomAppBar.dart';
import 'package:ezdelivershop/Components/Widgets/CustomSafeArea.dart';
import 'package:ezdelivershop/Components/snackbar/customsnackbar.dart';
import 'package:provider/provider.dart';



class EditOwnerName extends StatefulWidget {
  @override
  State<EditOwnerName> createState() => _EditOwnerNameState();
}

class _EditOwnerNameState extends State<EditOwnerName> {
  TextEditingController nameController = TextEditingController();
  String? errorText;

  int? remTime;

  @override
  void initState() {
    super.initState();
    nameController.text = context
        .read<SignInManagement>()
        .loginData!
        .user
        .name;

    checkFunction();
  }

  checkFunction() async {
    if (context
        .read<SignInManagement>()
        .loginData != null) {
      remTime = await EditProfileService().checkEditValidity("owner");
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
                        labelText: "Owner Name",
                        errorText: errorText,
                        controller: nameController,
                        onChanged: (val) {
                          if (val.isEmpty || val == "") {
                            setState(() {
                              errorText = "Please type your shop name";
                            });
                          } else {
                            setState(() {
                              errorText = null;
                            });
                          }
                        },
                      ),
                      SpacePalette.spaceTiny,
                      Warning(
                          infoText: remTime == null
                              ? "You will be able to update owner name only once a day."
                              : "You cannot change owner name for next ${(remTime! /
                              (3600000)).round()} hours."),
                      SpacePalette.spaceExtraLarge,
                      Row(
                        children: [
                          Expanded(
                              child: AppButtonPrimary(
                                  onPressedFunction: () async {
                                    NavigatorState nav = Navigator.of(context);
                                    SignInManagement read =
                                    context.read<SignInManagement>();
                                    if (nameController.text.isEmpty ||
                                        nameController.text.trim() == "") {
                                      setState(() {
                                        errorText =
                                        "Please type your shop name";
                                      });
                                    } else {
                                      setState(() {
                                        errorText = null;
                                      });
                                      if (nameController.text.trim() ==
                                          context
                                              .read<SignInManagement>()
                                              .loginData!.user
                                              .name) {
                                        setState(() {
                                          errorText =
                                          "Please provide different name";
                                        });
                                      } else {
                                        CheckAvailabilityToEdit.checkValidity(
                                            context, "owner",
                                            "owner name", () async {
                                          bool success = await EditProfileService()
                                              .editProfile(
                                              owner:
                                              nameController.text.trim());
                                          if (success) {
                                            read.loginData?.user.name =
                                                nameController.text.trim();
                                            read.notifyListeners();
                                            CustomSnackBar().success(
                                                "Owner name changed successfully");
                                            nav.pop();
                                          } else {
                                            CustomSnackBar().error(
                                                "Failed to change owner name");
                                          }
                                        });
                                      }
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
}
