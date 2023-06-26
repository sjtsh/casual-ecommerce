import 'package:ezdelivershop/BackEnd/Services/OtpService/OtpService.dart';
import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/Components/snackbar/customsnackbar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../BackEnd/StaticService/StaticService.dart';
import '../../Components/Constants/ColorPalette.dart';
import '../../Components/Widgets/CustomSafeArea.dart';
import '../../StateManagement/SignUpAndCameraManagement.dart';
import '../DialogBox/ConfirmationDialogBox.dart';
import '../ForgotPasswordScreen/ChangePasswordScreen.dart';

//69258
class OtpScreen extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool? isSignUp;
  final bool backOverride;

  OtpScreen(
      {this.title, this.subtitle, this.isSignUp, required this.backOverride});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
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
                title ?? 'Verification Code',
                textAlign: TextAlign.center,
                style: Theme
                    .of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                    color: Theme
                        .of(context)
                        .primaryColor,
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
                  subtitle ??
                      " An OTP has been sent to your mobile phone. Please enter the code to proceed.",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline5),

              const SizedBox(
                height: 61,
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 32),
              //   child: PinCodeTextField(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     length: order != null ? 5 : 6,
              //     obscureText: false,
              //     animationType: AnimationType.fade,
              //     pinTheme: PinTheme(
              //         borderWidth: 1,
              //         shape: PinCodeFieldShape.box,
              //         borderRadius: BorderRadius.circular(5),
              //         fieldHeight: order != null ? 50 : 40,
              //         fieldWidth: order != null ? 50 : 40,
              //         inactiveColor: ColorPalette.darkGrey,
              //         activeColor: Theme
              //             .of(context)
              //             .primaryColor,
              //         inactiveFillColor: Theme
              //             .of(context)
              //             .primaryColor,
              //         selectedColor: Theme
              //             .of(context)
              //             .primaryColor),
              //     keyboardType: TextInputType.number,
              //     appContext: context,
              //     controller: context
              //         .read<OtpService>()
              //         .pinController,
              //     onChanged: (String value) {
              //       context.read<OtpService>().notifyListeners();
              //     },
              //   ),
              // ),
              const SizedBox(
                height: 24,
              ), Builder(
                  builder: (context) {
                    final lastOtpSentAt =
                        context
                            .watch<OtpService>()
                            .lastOtpSentAt;
                    final smsSent = context
                        .watch<OtpService>()
                        .smsSent;
                    final waitTime = context
                        .watch<OtpService>()
                        .waitTIme;
                    if (lastOtpSentAt != null && smsSent) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Resend in ",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          TimerCountdown(
                            endTime: lastOtpSentAt.add(waitTime),
                            format: CountDownTimerFormat.minutesSeconds,
                            spacerWidth: 0,
                            secondsDescription: "",
                            minutesDescription: "",
                            timeTextStyle: Theme.of(context).textTheme.bodyText1,
                            onEnd: () {
                              context.read<OtpService>().resetResend();
                            },
                          ),
                        ],
                      );
                    } else if (lastOtpSentAt == null && smsSent) {
                      return GestureDetector(
                        onTap: () {
                          context.read<OtpService>().resend();
                        },
                        child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.all(4),
                          child: Text("Resend Code",
                              textAlign: TextAlign.center,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(color: Theme
                                  .of(context)
                                  .primaryColor)),
                        ),
                      );
                    }
                    return Container();
                  }
              ),
              verifyButton(context, isSignUp),
            ],
          ),
        ),
      ),
    );
  }

  Widget verifyButton(BuildContext context, bool? isSignUP) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: MaterialButton(
          disabledColor: Theme
              .of(context)
              .primaryColor
              .withOpacity(.5),
          onPressed:  (context
              .read<OtpService>()
              .pinController
              .text
              .length != 6)
              ? null
              : () => verifyPhoneOtp(isSignUP: isSignUP!, context),
          splashColor: Theme
              .of(context)
              .splashColor,
          color: Theme
              .of(context)
              .primaryColor,
          minWidth: MediaQuery
              .of(context)
              .size
              .width - 24,
          height: 50,
          child: context
              .watch<OtpService>()
              .isVerifying
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
            style: Theme
                .of(context)
                .textTheme
                .bodyText2
                ?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget verificationDialog(BuildContext context) {
    return ConfirmationDialogBox(
        title: "OTP verified",
        subTitle: "OTP verification successful",
        onPressed: () async {
          while (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        });
  }

  verifyOrderOtp(BuildContext context) async {
    OtpService read = context.read<OtpService>();
    context.read<OtpService>().pressVerify();
    if (int.tryParse(context
        .read<OtpService>()
        .pinController
        .text) == null) {
      context.read<OtpService>().pressVerify();
      return CustomSnackBar().error("Please enter recognized integer");
    }
  }
}

/// forget password and sign up
verifyPhoneOtp(BuildContext context, {required bool isSignUP}) async {
  SignUpAndCameraManagement readSignUP =
  context.read<SignUpAndCameraManagement>();
  NavigatorState nav = Navigator.of(context);
  OtpService read = context.read<OtpService>();
  context.read<OtpService>().pressVerify();
  try {
    if (int.tryParse(context
        .read<OtpService>()
        .pinController
        .text
        .trim()) ==
        null) {
      context.read<OtpService>().pressVerify();
      return CustomSnackBar().error("Please enter valid number");
    }
    if (context
        .read<OtpService>()
        .verificationId
        .isEmpty) {
      CustomSnackBar().error("Could not initialize captcha");
    } else {
      bool status = await context.read<OtpService>().verifyCode();
      if (status) {
        read.pinController.text = "";
        if (!isSignUP) {
          await StaticService.pushReplacement(
              context: context, route: const ChangePasswordScreen());
        } else {
          if (!await readSignUP.signUp()) {
            FirebaseAnalytics.instance
                .logEvent(name: "SignUFailed", parameters: {
              "phone": context
                  .read<SignUpAndCameraManagement>()
                  .ownerNameController
                  .text});
            CustomSnackBar().error("Failed to sign up");
          } else {
            FirebaseAnalytics.instance
                .logEvent(name: "SignUpComplete", parameters: {
              "phone": context
                  .read<SignUpAndCameraManagement>()
                  .ownerNameController
                  .text});
            CustomSnackBar().success("Please login to proceed");
            while (nav.canPop()) {
              read.pressVerify();
              nav.pop();
            }
          }
        }
      }
    }
  } catch (E, __) {
    print(E.toString() + __.toString());
  }
  read.pressVerify();
}
