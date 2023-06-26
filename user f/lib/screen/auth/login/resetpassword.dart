// ignore_for_file: must_be_immutable

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/others/validator.dart';
import 'package:ezdeliver/screen/profile/profilesettings.dart';

class ResetPassword extends StatelessWidget {
  final String phone;
  final String? uid;
  bool reset;
  ResetPassword({super.key, required this.phone, this.uid, this.reset = true});

  @override
  Widget build(BuildContext context) {
    final obscureTextProviderOld = StateProvider<bool>((ref) {
      return true;
    });
    final obscureTextProviderNew = StateProvider<bool>((ref) {
      return true;
    });
    final obscureTextProviderConfirm = StateProvider<bool>((ref) {
      return true;
    });
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    String password = "", confirmPassword = "", oldPassword = "";
    return Scaffold(
      appBar: reset
          ? null
          : simpleAppBar(context, title: "Change Password", search: false,
              back: () {
              if (!ResponsiveLayout.isMobile) {
                ResponsiveLayout.setProfileWidget(ProfileSetting());
              }
            }),
      body: Column(children: [
        if (reset) ...[
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(
                  height: 98.sh(),
                ),
                Text(
                  'Reset Password',
                  style: kTextStyleInterMedium.copyWith(
                      fontSize: 24.ssp(),
                      color: Theme.of(context).primaryColor),
                ),
                SizedBox(
                  height: 9.sh(),
                ),
                Text(
                  "Reset password for",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  phone,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 55.sh(),
          ),
        ],
        Padding(
          padding: reset
              ? EdgeInsets.symmetric(
                  horizontal: 12.sw(),
                )
              : const EdgeInsets.all(15),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Consumer(
                  builder: (context, ref, c) {
                    return Column(
                      children: [
                        if (!reset)
                          Consumer(builder: (context, ref, c) {
                            final obscureText =
                                ref.watch(obscureTextProviderOld.state).state;
                            return InputTextField(
                              inputAction: TextInputAction.done,
                              // limit: true,
                              // limitNumber: 8,
                              value: password,
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  ref.read(obscureTextProviderOld.state).state =
                                      !obscureText;
                                },
                                child: obscureText
                                    ? const Icon(GroceliIcon.password)
                                    : const Icon(Icons.visibility),
                              ),
                              obscureText: obscureText,
                              isVisible: true,
                              title: 'Old Password',
                              validator: (val) => validatePassword(val!),
                              onChanged: (val) {
                                oldPassword = val;
                              },
                            );
                          }),
                        SizedBox(
                          height: 25.5.sh(),
                        ),
                        Consumer(builder: (context, ref, c) {
                          final obscureText =
                              ref.watch(obscureTextProviderNew.state).state;
                          return InputTextField(
                            inputAction: TextInputAction.done,
                            // limit: true,
                            // limitNumber: 8,
                            value: password,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                ref.read(obscureTextProviderNew.state).state =
                                    !obscureText;
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
                          height: 25.5.sh(),
                        ),
                        Consumer(builder: (context, ref, c) {
                          final obscureText =
                              ref.watch(obscureTextProviderConfirm.state).state;
                          return InputTextField(
                            inputAction: TextInputAction.done,
                            // limit: true,
                            // limitNumber: 8,
                            value: confirmPassword,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                ref
                                    .read(obscureTextProviderConfirm.state)
                                    .state = !obscureText;
                              },
                              child: obscureText
                                  ? const Icon(GroceliIcon.password)
                                  : const Icon(Icons.visibility),
                            ),
                            obscureText: obscureText,
                            isVisible: true,
                            title: 'Confirm Password',
                            validator: (val) =>
                                validateConfirmPassword(val!, password),
                            onChanged: (val) {
                              confirmPassword = val;
                            },
                          );
                        }),
                      ],
                    );
                  },
                ),
                SizedBox(
                  height: 50.sh(),
                ),
                Consumer(builder: (context, ref, c) {
                  final userService = ref.read(userChangeProvider);
                  return CustomElevatedButton(
                      onPressedElevated: () async {
                        if (formKey.currentState!.validate()) {
                          if (reset) {
                            bool success = await userService.resetPassword(
                                phone: phone, password: password, uid: uid!);
                            if (success) {
                              snack.success("Password reset sucessfully");

                              Future.delayed(const Duration(milliseconds: 20),
                                  () {
                                Navigator.pop(context);
                              });
                              Future.delayed(const Duration(milliseconds: 20),
                                  () {
                                Navigator.pop(context);
                              });
                              Future.delayed(
                                  const Duration(milliseconds: 20), () {});
                            } else {
                              snack.error("Password reset failed");
                            }
                          }
                          // TODO :here to change passsword
                          else {
                            bool success = await userService.resetPassword(
                                oldPassword: oldPassword,
                                password: password,
                                reset: false);
                            if (success) {
                              snack.success("Password changed sucessfully");
                              if (ResponsiveLayout.isMobile) {
                                Future.delayed(const Duration(milliseconds: 20),
                                    () {
                                  Navigator.pop(context);
                                });
                                Future.delayed(const Duration(milliseconds: 20),
                                    () {
                                  Navigator.pop(context);
                                });
                                Future.delayed(
                                    const Duration(milliseconds: 20), () {});
                              } else {
                                ResponsiveLayout.setProfileWidget(
                                    ProfileSetting());
                              }
                            } else {
                              snack.error("Password reset failed");
                            }
                          }
                        }
                      },
                      elevatedButtonText:
                          reset ? "Reset Password" : "Change Password");
                }),
              ],
            ),
          ),
        ),
        // if (!reset) ...[
        //   const Spacer(),
        //   Text(
        //     "*This feature is on progress",
        //     style: Theme.of(context)
        //         .textTheme
        //         .bodyText1!
        //         .copyWith(color: Theme.of(context).errorColor),
        //   ),
        //   const SizedBox(
        //     height: 15,
        //   )
        // ],
      ]),
    );
  }
}
