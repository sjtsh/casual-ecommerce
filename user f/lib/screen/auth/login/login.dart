import 'package:ezdeliver/screen/auth/login/forgetpassword.dart';
import 'package:ezdeliver/screen/auth/register/register.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/holder.dart';

import 'package:ezdeliver/screen/others/validator.dart';

final checkBoxStateProvider = StateProvider<bool>((ref) {
  return true;
});
final showIPProvider = StateProvider<bool>((ref) {
  return false;
});

// ignore: must_be_immutable
class Login extends ConsumerWidget {
  final obscureTextProvider = StateProvider<bool>((ref) {
    return true;
  });
  Login({Key? key, this.dialog = false, this.log = false}) : super(key: key);
  final bool log, dialog;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String phone = '', password = '', countryCode = '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userService = ref.read(userChangeProvider);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
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
                  'Please Sign In to your account',
                  style: kTextStyleInterMedium.copyWith(
                      fontSize: 14.ssp(), color: CustomTheme.getBlackColor()),
                ),
              ].animate().fadeIn().slideY(curve: Curves.easeIn, begin: -1),
            ),
          ),
          SizedBox(
            height: 55.sh(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.sw()),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  InputTextField(
                    controller: userService.signInPhoneController,
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
                    countrySelected: (value) {
                      countryCode = value;
                    },
                  ),
                  SizedBox(
                    height: 25.5.sh(),
                  ),
                  Consumer(builder: (context, ref, c) {
                    final obscureText =
                        ref.watch(obscureTextProvider.state).state;
                    return InputTextField(
                      controller: userService.signInPasswordController,
                      inputAction: TextInputAction.done,
                      // limit: true,
                      // limitNumber: 8,
                      value: password,
                      suffixIcon: GestureDetector(
                        onTap: () async {
                          ref.read(obscureTextProvider.state).state =
                              !obscureText;
                          if (log) {
                            await FirebaseAnalytics.instance.logEvent(
                              name: "password_obscure",
                            );
                          }
                        },
                        child: obscureText
                            ? const Icon(GroceliIcon.password)
                            : const Icon(Icons.visibility),
                      ),
                      obscureText: obscureText,
                      isVisible: true,
                      title: 'Password',
                      validator: (val) => validatePassword(val!),
                      onChanged: (val) {
                        password = val;
                      },
                    );
                  }),
                  SizedBox(
                    height: 50.sh(),
                  ),
                  // if (ResponsiveLayout.isMobile)
                  ...[
                    GestureDetector(
                      onTap: () async {
                        if (dialog) {
                          ref.read(authProvider.notifier).state = Auth.signup;
                        } else {
                          await Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            userService.clearControllerLogin();
                            return RegisterScreen();
                          }));
                        }

                        userService.clearControllerSignup();
                        if (log) {
                          await FirebaseAnalytics.instance.logEvent(
                            name: "Signup_here",
                          );
                        }
                      },
                      child: RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: "Don't have an account? ",
                            style: Theme.of(context).textTheme.headlineSmall),
                        TextSpan(
                          text: " Sign Up here",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ])),
                    ),
                    SizedBox(
                      height: 25.sh(),
                    ),
                  ],

                  CustomElevatedButton(
                      width: double.infinity,
                      onPressedElevated: () async {
                        final userService = ref.read(userChangeProvider);

                        if (phone == "") {
                          phone = userService.signInPhoneController.text;
                        }

                        if (formKey.currentState!.validate()) {
                          // showDialog(
                          //     barrierDismissible: false,
                          //     context: context,
                          //     builder: (context) {
                          //       return const Center(
                          //         child: SizedBox(
                          //           // color: Colors.teal,
                          //           height: 50,
                          //           width: 50,
                          //           child: Center(
                          //               child: CircularProgressIndicator()),
                          //         ),
                          //       );
                          //     });
                          var deviceInfo =
                              await CustomDeviceInfo.getDeviceInfo();

                          if (deviceInfo != null) {
                            try {
                              var login = await userService.login(
                                  remember: ref.read(checkBoxStateProvider),
                                  phone: phone,
                                  countryCode: countryCode,
                                  password: password,
                                  device: deviceInfo.toJson());
                              if (login) {
                                SharedPreferences.getInstance().then((prefs) {
                                  prefs.setString("phone", phone);
                                });
                                snack.success("Login Sucessfull!");

                                ref.read(customSocketProvider).connect();

                                Future.delayed(const Duration(milliseconds: 50),
                                    () {
                                  userService.clearControllerLogin();
                                  if (dialog) {
                                    Utilities.loadall();
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          settings: const RouteSettings(
                                              name: "Holder"),
                                          builder: (context) => const Holder()),
                                    );
                                  }
                                });
                                if (log) {
                                  await FirebaseAnalytics.instance
                                      .logEvent(name: "Login", parameters: {
                                    "id": ref
                                        .read(userChangeProvider)
                                        .loggedInUser
                                        .value
                                        ?.id,
                                    "name": ref
                                        .read(userChangeProvider)
                                        .loggedInUser
                                        .value
                                        ?.name
                                  });
                                }
                                // await Utilities.pushPageRReplacement(
                                //     const Holder(), 50);
                              }
                            } catch (e, s) {
                              // print("$e, $s");
                              Utilities.futureDelayed(1, () {
                                snack.error(e.toString(), c: context);
                              });
                            }
                          } else {
                            snack.error("Cannot get device info");
                          }
                        }
                      },
                      elevatedButtonText: 'Login'),
                  SizedBox(
                    height: 30.sh(),
                  ),
                  OverflowBar(
                    // runAlignment: WrapAlignment.spaceBetween,
                    alignment: MainAxisAlignment.spaceBetween,
                    overflowAlignment: OverflowBarAlignment.center,
                    overflowSpacing: 10.sh(),
                    children: [
                      Consumer(builder: (context, ref, c) {
                        final checked =
                            ref.watch(checkBoxStateProvider.state).state;
                        return Wrap(
                          // runAlignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Checkbox(
                                value: checked,
                                onChanged: (value) async {
                                  ref.read(checkBoxStateProvider.state).state =
                                      value!;
                                  if (log) {
                                    await FirebaseAnalytics.instance.logEvent(
                                      name: "Stay_logged_in",
                                    );
                                  }
                                }).animate(target: checked ? 1 : 0).shake(),
                            SizedBox(
                              width: 6.sw(),
                            ),
                            GestureDetector(
                              onTap: () => ref
                                  .read(checkBoxStateProvider.state)
                                  .state = !checked,
                              child: Text(
                                'Stay logged in?',
                                style: Theme.of(context).textTheme.bodyText1!,
                              ),
                            ),
                          ],
                        );
                      }),
                      // if (ResponsiveLayout.isMobile)
                      GestureDetector(
                        onTap: () async {
                          userService.clearControllerLogin();
                          if (dialog) {
                            ref.read(authProvider.notifier).state =
                                Auth.password;
                          } else {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPassword()));
                          }

                          userService.forgotPasswordPhoneController.clear();
                          if (log) {
                            await FirebaseAnalytics.instance.logEvent(
                              name: "Forgot_password",
                            );
                          }
                        },
                        child: Text('Forgot Password?',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(
                                    color: Theme.of(context).primaryColor)),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 100.sh(),
                  ),

                  // GestureDetector(
                  //   onTap: () async {
                  //     if (dialog) {
                  //       ref.read(authProvider.notifier).state = Auth.signup;
                  //     } else {
                  //       await Navigator.push(context,
                  //           MaterialPageRoute(builder: (context) {
                  //         userService.clearControllerLogin();
                  //         return RegisterScreen();
                  //       }));
                  //     }

                  //     userService.clearControllerSignup();
                  //     if (log) {
                  //       await FirebaseAnalytics.instance.logEvent(
                  //         name: "Signup_here",
                  //       );
                  //     }
                  //   },
                  //   child: RichText(
                  //       text: TextSpan(children: [
                  //     TextSpan(
                  //         text: "Don't have an account? ",
                  //         style: Theme.of(context).textTheme.headlineSmall),
                  //     TextSpan(
                  //       text: " Sign Up here",
                  //       style:
                  //           Theme.of(context).textTheme.headlineSmall!.copyWith(
                  //                 color: Theme.of(context).primaryColor,
                  //               ),
                  //     ),
                  //   ])),
                  // ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Consumer(builder: (context, ref, c) {
                  //   final showIP = ref.watch(showIPProvider.state).state;
                  //   return GestureDetector(
                  //     onTap: (() async {
                  //       // ref.read(showIPProvider.state).state = !showIP;
                  //       await FirebaseAnalytics.instance.logEvent(
                  //         name: "click here",
                  //       );
                  //     }),
                  //     child: const Text("click here"),
                  //   );
                  // }),

                  // custom ip code
                  // if (ref.watch(showIPProvider.state).state &&
                  //     !Api.production) ...[
                  //   InputTextField(
                  //     title: "Ip",
                  //     isVisible: true,
                  //     onChanged: (val) {
                  //       Api.localUrl = val;
                  //     },
                  //     validator: (val) => validateName(val!),
                  //     value: Api.localUrl,
                  //   ),
                  //   InputTextField(
                  //     title: "APi",
                  //     isVisible: true,
                  //     onChanged: (val) {
                  //       Api.apiPort = int.parse(val);
                  //     },
                  //     validator: (val) => validateName(val!),
                  //     value: Api.apiPort.toString(),
                  //   ),
                  //   InputTextField(
                  //     title: "Socket",
                  //     isVisible: true,
                  //     onChanged: (val) {
                  //       Api.socketPort = int.parse(val);
                  //     },
                  //     validator: (val) => validateName(val!),
                  //     value: Api.socketPort.toString(),
                  //   ),
                  // ],
                  SizedBox(
                    height: 10.sh(),
                  )
                ].animate()
                  ..fadeIn().slideX(curve: Curves.easeIn),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
