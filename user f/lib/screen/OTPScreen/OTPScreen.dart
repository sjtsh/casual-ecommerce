// ignore_for_file: must_be_immutable

import 'package:ezdeliver/screen/holder/holder.dart';
import 'package:ezdeliver/screen/profile/enterpassword.dart';
import 'package:ezdeliver/services/otpService.dart';
import 'package:ezdeliver/screen/auth/login/resetpassword.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';

import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:pinput/pinput.dart';

class OTPSCreen extends ConsumerWidget {
  OTPSCreen(
      {this.name = "",
      this.password = "",
      required this.countryCode,
      super.key,
      required this.phone,
      this.signUp = true,
      this.changeNUmber = false});
  final String phone;
  String name, password, countryCode;
  final bool signUp, changeNUmber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final otpService = ref.watch(otpServiceProvider);
    // otpService.calculateTime();
    return SafeArea(
      child: Scaffold(
        // resizeToAvoidBottomInset: true,
        body: ListView(
          // reverse: true,
          // shrinkWrap: true,
          padding:
              EdgeInsets.only(left: 22.sw(), right: 22.sw(), bottom: 20.sh()),
          // mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 120.sh(),
            ),
            Image.asset(
              Assets.imagesOtp,
              height: 180.sh(),
              width: 180.sh(),
            ),
            SizedBox(
              height: 30.sh(),
            ),
            Text(
              "Verification Code",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline2!.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: 24.ssp(),
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 14.sh(),
            ),
            Consumer(
              builder: (context, ref, child) {
                final otpService = ref.watch(otpServiceProvider);
                if (!otpService.smsSent) {
                  return Text(
                    "Please wait while we send you OTP...",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1,
                  );
                } else {
                  return Column(
                    children: [
                      Text(
                        "We have sent verification code at ",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      SizedBox(
                        height: 5.sh(),
                      ),
                      Text(
                        otpService.getPhone,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(
              height: 50.sh(),
            ),
            Consumer(
              builder: (context, ref, child) {
                final lastOtpSentAt =
                    ref.watch(otpServiceProvider).lastOtpSentAt;
                final smsSent = ref.watch(otpServiceProvider).smsSent;
                final waitTime = ref.watch(otpServiceProvider).waitTIme;

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
                          ref.read(otpServiceProvider).resetResend();
                        },
                      ),
                    ],
                  );
                } else if (lastOtpSentAt == null && smsSent) {
                  return GestureDetector(
                    onTap: () {
                      ref.read(otpServiceProvider).resend();
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.all(4.sr()),
                      child: Text("Resend Code",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: Theme.of(context).primaryColor)),
                    ),
                  );
                }
                return Container();
              },
            ),
            SizedBox(
              height: 14.sh(),
            ),
            Consumer(builder: (context, ref, c) {
              final otpService = ref.watch(otpServiceProvider);
              return AbsorbPointer(
                absorbing: !otpService.smsSent,
                child: Pinput(
                  length: 6,
                  controller: otpService.pinController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  defaultPinTheme: PinTheme(
                    width: 52.sr(),
                    height: 52.sr(),
                    textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: CustomTheme.getBlackColor(),
                        ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(8.sr()),
                    ),
                  ),
                  onCompleted: (pin) => otpService.setSmsCOde(pin),
                ),
              );
            }),
            SizedBox(
              height: 50.sh(),
            ),
            Consumer(builder: (context, ref, child) {
              final otpService = ref.watch(otpServiceProvider);
              return CustomElevatedButton(
                onPressedElevated: otpService.smsSent &&
                        otpService.smsCode.length > 5
                    ? () async {
                        final userService = ref.read(userChangeProvider);
                        var status = await otpService.verifyCode();
                        if (status) {
                          if (changeNUmber) {
                            Utilities.pushPage(
                                EnterPassword(
                                  phone: phone,
                                ),
                                15);
                          } else if (signUp) {
                            otpService.clear();
                            var deviceInfo =
                                await CustomDeviceInfo.getDeviceInfo();
                            if (deviceInfo != null) {
                              try {
                                var register = await userService.register(
                                  name: name,
                                  phone: phone,
                                  countryCode: countryCode,
                                  password: password,
                                  device: deviceInfo.toJson(),
                                );

                                if (register) {
                                  snack.success("Registration Sucessfull!");

                                  ref.read(customSocketProvider).connect();

                                  Future.delayed(
                                      const Duration(milliseconds: 50),
                                      () async {
                                    userService.clearControllerLogin();
                                    Navigator.pop(context);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          settings: const RouteSettings(
                                              name: "Holder"),
                                          builder: (context) => const Holder()),
                                    );
                                  });
                                }
                              } catch (e) {
                                Navigator.pop(context);
                                Utilities.futureDelayed(1, () {
                                  snack.error(e, c: context);
                                });
                              }
                            } else {
                              snack.error("Cannot get device info!");
                            }
                          } else {
                            await Future.delayed(
                              const Duration(milliseconds: 10),
                              () {
                                var uid = ref.read(otpServiceProvider).uid;

                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ResetPassword(
                                              phone: phone,
                                              uid: uid!,
                                            )));
                              },
                            );
                            otpService.clear();
                          }
                        }
                        // ref.read(otpServiceProvider).clear();
                      }
                    : null,
                elevatedButtonText: "Verify",
                width: double.infinity,
              );
            })
          ],
        ),
      ),
    );
  }

  // calculateTime(DateTime? lastSent, Duration waitTime) {
  //   if (lastSent != null) {
  //     Duration elapsed =
  //         (waitTime - (DateTime.now().difference(lastSent))).abs();

  //     if (elapsed > waitTime) return Duration.zero;
  //     return waitTime;
  //   }
  // }
}
