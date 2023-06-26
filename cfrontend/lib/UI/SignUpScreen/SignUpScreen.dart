// import 'package:ezdelivershop/BackEnd/Services/OtpService/OtpService.dart';
// import 'package:ezdelivershop/BackEnd/Services/resetPasswordService.dart';
// import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
// import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
// import 'package:ezdelivershop/UI/OtpScreen/OtpScreen.dart';
// import 'package:ezdelivershop/UI/SignUpScreen/ClickPhoto.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../BackEnd/Entities/ShopCategory.dart';
// import '../../Components/CustomTextField2.dart';
// import '../../Components/Widgets/Button.dart';
// import '../../Components/Widgets/CustomSafeArea.dart';
// import '../../Components/snackbar/customsnackbar.dart';
// import '../../StateManagement/SignInManagement.dart';
// import '../../StateManagement/SignUpAndCameraManagement.dart';
//
// class SignUpScreen extends StatefulWidget {
//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }
//
// class _SignUpScreenState extends State<SignUpScreen> {
//   List<ShopCategory> categories = [];
//
//   @override
//   void initState() {
//     super.initState();
//     // ShopService()
//     //     .getShopCategory()
//     //     .then((value) => setState(() => categories = value));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     SignUpAndCameraManagement read = context.read<SignUpAndCameraManagement>();
//     SignUpAndCameraManagement watch =
//         context.watch<SignUpAndCameraManagement>();
//     return CustomSafeArea(
//         child: Scaffold(
//             body: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // GestureDetector(
//         //     onTap: () {
//         //       Navigator.pop(context);
//         //     },
//         //     child: Padding(
//         //       padding: SpacePalette.paddingExtraLarge.copyWith(bottom: 0),
//         //       child: const Icon(Icons.arrow_back_ios),
//         //     )),
//         Expanded(
//           child: Padding(
//               padding: SpacePalette.paddingExtraLarge,
//               child: ListView(children: [
//                 SpacePalette.spaceLarge,
//                 Center(
//                     child: Text("Welcome to PASALKO PARTNER",
//                         textAlign: TextAlign.center,
//                         style: Theme.of(context).textTheme.bodyText1?.copyWith(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w500,
//                             color: Theme.of(context).primaryColor))),
//                 SpacePalette.spaceMedium,
//                 Center(
//                     child: Text(
//                   "Create new account",
//                   style: Theme.of(context).textTheme.bodyText1,
//                 )),
//                 SpacePalette.spaceLarge,
//                 CustomTextField2(
//                     node: read.nameNode,
//                     labelText: "Shop Name",
//                     onChanged: (val) => read.nameValidation(),
//                     controller: read.nameController,
//                     errorText: watch.nameErrorText),
//                 CustomTextField2(
//                     node: read.ownerNameNode,
//                     labelText: "Owner Name",
//                     onChanged: (val) => read.ownerNameValidation(),
//                     controller: read.ownerNameController,
//                     errorText: watch.ownerErrorText),
//                 CustomTextField2(
//                     controller: read.passwordController,
//                     node: read.passwordNode,
//                     labelText: "Password",
//                     obscureText:
//                         !context.watch<SignInManagement>().passwordVisible,
//                     errorText: watch.passwordErrorText,
//                     onChanged: (c) => read.passwordValidation(),
//                     onObscurePressed: () =>
//                         context.read<SignInManagement>().passwordVisible =
//                             !context.read<SignInManagement>().passwordVisible),
//                 CustomTextField2(
//                     node: read.panNode,
//                     labelText: "PAN Number(Optional)",
//                     keyboardType: TextInputType.number,
//                     onChanged: (val) => read.panValidation(),
//                     controller: read.panController,
//                     errorText: watch.panErrorText),
//                 // SpacePalette.addPaddingMediumV(ChooseCategories()),
//                 CustomTextField2(
//                     node: read.phoneNode,
//                     labelText: "Mobile Number",
//                     keyboardType: TextInputType.number,
//                     onChanged: (val) => read.phoneValidation(),
//                     controller: read.phoneController,
//                     errorText: watch.phoneNumberErrorText),
//                 watch.position == null
//                     ? Container()
//                     : CustomTextField2(
//                         node: read.addressNode,
//                         labelText: "Address",
//                         onChanged: (val) => read.addressValidation(),
//                         controller: read.addressController,
//                         errorText: watch.addressErrorText),
//                 SpacePalette.addPaddingMediumV(ClickPhoto()),
//                 SpacePalette.addPaddingMediumV(AppButtonPrimary(
//                     onPressedFunction: () async {
//                       FirebaseAnalytics.instance
//                           .logEvent(name: "SignUp Start", parameters: {
//                         "phone": read.ownerNameController.text
//                       });
//                       OtpService optRead = context.read<OtpService>();
//                       context.read<OtpService>().pinController =
//                           TextEditingController();
//                       if (!read.signUpValidation()) {
//                         return print("not validated");
//                       }
//                       if (context
//                               .read<SignUpAndCameraManagement>()
//                               .shopImageUploadedUrl ==
//                           null) {
//                         return CustomSnackBar()
//                             .error("The image is not yet uploaded");
//                       }
//                       bool newUser = await ResetPasswordService()
//                           .checkShopSignUp(
//                               phone: read.phoneController.text.trim(),
//                               pan: read.panController.text.isEmpty
//                                   ? null
//                                   : read.panController.text.trim());
//                       if (newUser) {
//                         optRead.phone =
//                             "+977${read.phoneController.text.trim()}";
//                         bool status = await optRead.sendCode(context: context);
//                         print(status);
//                         if (status) {
//                           StaticService.pushPage(
//                               context: context,
//                               route: OtpScreen(
//                                 backOverride: true,
//                                 isSignUp: true,
//                                 title: "Verify Phone Number",
//                                 subtitle:
//                                     "An OTP has been sent to your ${optRead.phone}.\nPlease enter the code to proceed.",
//                               ));
//                         } else {
//                           CustomSnackBar()
//                               .error("Cannot send otp. Please try again later");
//                         }
//                       }
//                     },
//                     text: "SIGN UP")),
//                 Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                   Text(
//                     "Already have an account?",
//                     style: Theme.of(context).textTheme.bodyText1,
//                   ),
//                   TextButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: Text(
//                         "Sign in here",
//                         style: Theme.of(context)
//                             .textTheme
//                             .bodyText1
//                             ?.copyWith(color: Theme.of(context).primaryColor),
//                       ))
//                 ])
//               ])),
//         ),
//       ],
//     )));
//   }
// }
