import 'package:ezdeliver/screen/OTPScreen/OTPScreen.dart';
import 'package:ezdeliver/screen/auth/login/login.dart';
import 'package:ezdeliver/screen/component/snackbar/snackbarcontents.dart';

import 'package:ezdeliver/services/otpService.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/others/validator.dart';

final GlobalKey<ScaffoldMessengerState> dialogKey =
    GlobalKey<ScaffoldMessengerState>();

class RegisterScreen extends ConsumerWidget {
  final obscureTextProvider = StateProvider<bool>((ref) {
    return true;
  });
  final bool dialog;
  RegisterScreen({super.key, this.dialog = false});
  String name = '', phone = '', password = '', countryCode = "";
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final userService = ref.read(userChangeProvider);
    return SafeArea(
      child: ScaffoldMessenger(
        key: dialogKey,
        child: Scaffold(
          // appBar: AppBar(
          //   title: const Text("Register"),
          //   centerTitle: true,
          // ),
          body: SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.all(15),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: 98.sh(),
                  ),
                  Text(
                    'Welcome to FAASTO',
                    style: kTextStyleInterMedium.copyWith(
                        fontSize: 24.ssp(),
                        color: Theme.of(context).primaryColor),
                  ),
                  SizedBox(
                    height: 9.sh(),
                  ),
                  Text(
                    'Create new account',
                    style: kTextStyleInterMedium.copyWith(
                        fontSize: 14.ssp(), color: CustomTheme.getBlackColor()),
                  ),
                  SizedBox(
                    height: 55.sh(),
                  ),
                  InputTextField(
                    controller: userService.signUpNameController,
                    title: 'Name',
                    isVisible: true,
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontSize: 16.ssp(), color: CustomTheme.getBlackColor()),
                    validator: (val) => validateName(val!),
                    onChanged: (val) {
                      name = val;
                    },
                  ),
                  SizedBox(
                    height: 24.sh(),
                  ),
                  InputTextField(
                    controller: userService.signUpPhoneController,
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
                    countrySelected: (country) {
                      countryCode = country;
                    },
                  ),
                  SizedBox(
                    height: 24.sh(),
                  ),
                  Consumer(builder: (context, ref, c) {
                    final obscureText =
                        ref.watch(obscureTextProvider.state).state;

                    return InputTextField(
                      inputAction: TextInputAction.done,
                      // limit: true,
                      // limitNumber: 8,
                      controller: userService.signUpPasswordController,
                      value: password,
                      isVisible: true,
                      title: 'Password',
                      suffixIcon: GestureDetector(
                        onTap: () {
                          ref.read(obscureTextProvider.state).state =
                              !obscureText;
                        },
                        child: obscureText
                            ? const Icon(GroceliIcon.password)
                            : const Icon(Icons.visibility),
                      ),
                      obscureText: obscureText,
                      validator: (val) => validatePassword(val!),
                      onChanged: (val) {
                        password = val;
                      },
                    );
                  }),
                  SizedBox(
                    height: 24.5.sh(),
                  ),
                  CustomElevatedButton(
                      onPressedElevated: () async {
                        ref.read(otpServiceProvider).clear();
                        final userService = ref.read(userChangeProvider);

                        if (formKey.currentState!.validate()) {
                          var newUser =
                              await userService.checkUser(phone, countryCode);
                          // print(newUser);
                          if (newUser != null) {
                            if (!newUser) {
                              ref.read(otpServiceProvider).phone = phone;
                              ref.read(otpServiceProvider).countryCode =
                                  countryCode;
                              await ref
                                  .read(otpServiceProvider)
                                  .sendCode(context: context);

                              Future.delayed(const Duration(milliseconds: 10),
                                  () async {
                                userService.clearControllerSignup();
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OTPSCreen(
                                      countryCode: countryCode,
                                      name: name,
                                      phone: phone,
                                      password: password,
                                    ),
                                  ),
                                );
                                Future.delayed(const Duration(milliseconds: 10),
                                    () {
                                  userService.clearControllerSignup();
                                  // Navigator.pop(context);
                                });
                              });
                            } else {
                              snack.state("User Already Exists", dialogKey, context);
                            }
                          } else {
                            snack.state("Service Unavailable", dialogKey, context);
                          }
                        }
                      },
                      elevatedButtonText: "Register"),
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
                          ref.read(shouldSignUp.notifier).state = false;
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
          )),
        ),
      ),
    );
  }

}
