import 'package:ezdeliver/screen/OTPScreen/OTPScreen.dart';
import 'package:ezdeliver/services/otpService.dart';

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/others/validator.dart';

class ForgotPassword extends ConsumerWidget {
  const ForgotPassword({super.key, this.log = false, this.dialog = false});
  final bool log, dialog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    String phone = '', countryCode = "";
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(
                  height: 98.sh(),
                ),
                Text(
                  'Forgot Password?',
                  style: kTextStyleInterMedium.copyWith(
                      fontSize: 24.ssp(),
                      color: Theme.of(context).primaryColor),
                ),
                SizedBox(
                  height: 9.sh(),
                ),
                Text(
                  'No worries!',
                  style: kTextStyleInterMedium.copyWith(
                      fontSize: 14.ssp(), color: CustomTheme.getBlackColor()),
                ).animate().fadeIn(duration: 1.seconds).swap(
                    builder: (context, child) {
                  var a = child as Text;

                  return Text(
                    "${a.data} We got you.",
                    style: a.style,
                  ).animate().fadeIn();
                }),
              ],
            ),
          ),
          SizedBox(
            height: 55.sh(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.sw(),
            ),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  InputTextField(
                    controller: ref
                        .read(userChangeProvider)
                        .forgotPasswordPhoneController,
                    limit: true,
                    limitNumber: 10,
                    isdigits: true,
                    value: phone,
                    isVisible: true,
                    title: 'Mobile Number',
                    validator: (val) => validatePhone(val!),
                    onChanged: (val) {
                      phone = val;
                    },
                    countrySelected: (code) {
                      countryCode = code;
                    },
                    onSubmit: (val) {
                      next(context, ref, formKey, phone, countryCode);
                    },
                    inputAction: TextInputAction.done,
                  ),
                  SizedBox(
                    height: 50.sh(),
                  ),
                  CustomElevatedButton(
                      width: double.infinity,
                      onPressedElevated: () async {
                        next(context, ref, formKey, phone, countryCode);
                      },
                      elevatedButtonText: 'Next'),
                  SizedBox(
                    height: 50.sh(),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: (() {
                        if (dialog) {
                          ref.read(authProvider.notifier).state = Auth.login;
                        } else {
                          Navigator.pop(context);
                        }
                      }),
                      child: RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: "Already have an account.",
                            style: Theme.of(context).textTheme.headlineSmall),
                        TextSpan(
                          text: " Sign In here",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ])),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    ));
  }

  next(BuildContext context, WidgetRef ref, GlobalKey<FormState> formKey,
      String phone, String countryCode) async {
    ref.read(otpServiceProvider).clear();
    final userService = ref.read(userChangeProvider);
    if (formKey.currentState!.validate()) {
      var newUser = await userService.checkUser(phone, countryCode);
      if (newUser != null) {
        if (!newUser) {
          ref.read(otpServiceProvider).phone = phone;
          ref.read(otpServiceProvider).countryCode = countryCode;
          ref.read(otpServiceProvider).sendCode(context: context);

          Future.delayed(const Duration(milliseconds: 10), () {
            // FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
            userService.forgotPasswordPhoneController.clear();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OTPSCreen(
                          phone: phone,
                          countryCode: countryCode,
                          signUp: false,
                        )));
          });
          if (log) {
            await FirebaseAnalytics.instance.logEvent(
              name: "Forgot_password_next",
            );
          }
        } else {
          snack.error("User not found");
        }
      } else {
        snack.error("Service Unavailable");
      }
    }
  }
}
