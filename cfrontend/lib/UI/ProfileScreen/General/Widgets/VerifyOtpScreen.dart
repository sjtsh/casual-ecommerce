import 'package:ezdelivershop/BackEnd/Services/OtpService/OtpService.dart';
import 'package:ezdelivershop/Components/snackbar/customsnackbar.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../../../BackEnd/Services/EditProfileService/EditProfileService.dart';
import '../../../../Components/Constants/ColorPalette.dart';
import '../../../../Components/Constants/SpacePalette.dart';
import '../../../../Components/Widgets/CustomSafeArea.dart';

//69258
class VerifyOtpScreen extends StatelessWidget {
  final String phoneNumber;

  VerifyOtpScreen({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              Image.asset(
                "assets/issue/OTP.png",
                height: 200,
                width: 200,
              ),
              SpacePalette.spaceExtraLarge,
              Text(
                "Verify Phone Number",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 12,
              ),
              // RichText(
              //     textAlign: TextAlign.center,
              //     text: TextSpan(children: [
              //   TextSpan(text: "We have sent verification code at\n",style: kTextStyleInterRegular),
              //   TextSpan(text: "+977 9818544722",style: kTextStyleInterMedium)
              // ])),
              // Column(children: [
              //   Text( "We have sent verification code at",style: TextStylePalette.kTextStyleInterRegular),
              //   SizedBox(height: 4,),
              //   Text( "+977 9818544722",style: TextStylePalette.kTextStyleInterMedium)],),
              Text(
                  textAlign: TextAlign.center,
                  "An OTP has been sent to +977$phoneNumber. Please enter the code to proceed.",
                  style: Theme.of(context).textTheme.headline5),
              const SizedBox(
                height: 61,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: PinCodeTextField(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  length: 6,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                      borderWidth: 1,
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 40,
                      fieldWidth: 40,
                      inactiveColor: ColorPalette.darkGrey,
                      activeColor: Theme.of(context).primaryColor,
                      inactiveFillColor: Theme.of(context).primaryColor,
                      selectedColor: Theme.of(context).primaryColor),
                  keyboardType: TextInputType.number,
                  appContext: context,
                  controller: context.read<OtpService>().pinController,
                  onChanged: (String value) {
                    context.read<OtpService>().notifyListeners();
                  },
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: verifyButton(context),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget verifyButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: MaterialButton(
          disabledColor: Theme.of(context).primaryColor.withOpacity(.5),
          onPressed: (context.read<OtpService>().pinController.text.length != 6)
              ? null
              : () async {
                  NavigatorState nav = Navigator.of(context);
                  OtpService read = context.read<OtpService>();

                  var status = await context.read<OtpService>().verifyCode();
                  if (status) {
                    read.pinController.text = "";
                    bool success = await EditProfileService()
                        .editProfile(phone: phoneNumber);
                    if (success) {
                      CustomSnackBar()
                          .success("Phone number  changed successfully");
                      nav.pop();
                    } else {
                      CustomSnackBar().error("Failed to change phone number");
                    }
                  }
                },
          splashColor: Theme.of(context).splashColor,
          color: Theme.of(context).primaryColor,
          minWidth: MediaQuery.of(context).size.width - 24,
          height: 50,
          child: context.watch<OtpService>().isVerifying
              ? const Center(
                  child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      )),
                )
              : Text(
                  "VERIFY",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      ?.copyWith(color: Colors.white),
                ),
        ),
      ),
    );
  }
}
