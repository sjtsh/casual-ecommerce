import 'package:ezdeliver/screen/OTPScreen/OTPScreen.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/profile/profilesettings.dart';
import 'package:ezdeliver/services/otpService.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/others/validator.dart';

class ChangePhoneNUmber extends ConsumerWidget {
  const ChangePhoneNUmber({super.key, this.log = false});
  final bool log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final obscureTextProvider = StateProvider<bool>((ref) {
    //   return true;
    // });
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    String phone = '', countryCode = "";
    return SafeArea(
        child: Scaffold(
      appBar: simpleAppBar(context,
          title: "Change Mobile Number", search: false, back: () {
        if (!ResponsiveLayout.isMobile) {
          ResponsiveLayout.setProfileWidget(ProfileSetting());
        }
        ref.read(userChangeProvider).changeNumberPasswordController.clear();
        ref.read(userChangeProvider).changeNumberPhoneController.clear();
      }),
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
                  'Changed your mobile number?',
                  style: kTextStyleInterMedium.copyWith(
                      fontSize: 24.ssp(),
                      color: Theme.of(context).primaryColor),
                ),
                SizedBox(
                  height: 9.sh(),
                ),
                Text(
                  'No worries! We got you!',
                  style: kTextStyleInterMedium.copyWith(
                      fontSize: 14.ssp(), color: CustomTheme.getBlackColor()),
                ),
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
                        .changeNumberPhoneController,
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
                        next(
                          context,
                          ref,
                          formKey,
                          phone,
                          countryCode,
                        );
                      },
                      elevatedButtonText: 'Next')
                ],
              ),
            ),
          )
        ],
      )),
    ));
  }

  next(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    String phone,
    String countryCode,
  ) async {
    ref.read(otpServiceProvider).clear();
    final userService = ref.read(userChangeProvider);
    if (formKey.currentState!.validate()) {
      var newUser = await userService.checkUser(phone, countryCode);
      if (newUser != null) {
        if (newUser) {
          ref.read(otpServiceProvider).phone = phone;
          ref.read(otpServiceProvider).countryCode = countryCode;
          ref.read(otpServiceProvider).sendCode(context: context);

          Future.delayed(const Duration(milliseconds: 10), () {
            // FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
            userService.forgotPasswordPhoneController.clear();
            Utilities.pushPage(
                OTPSCreen(
                  changeNUmber: true,
                  countryCode: countryCode,
                  phone: phone,
                  // signUp: false,
                ),
                15);
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => OTPSCreen(
            //               changeNUmber: true,
            //               countryCode: countryCode,
            //               phone: phone,
            //               // signUp: false,
            //             )));
          });
          if (log) {
            await FirebaseAnalytics.instance.logEvent(
              name: "Forgot_password_next",
            );
          }
        } else {
          snack.error("This Phone number is already registered.");
        }
      } else {
        snack.error("Service Unavailable");
      }
    }
  }
}
