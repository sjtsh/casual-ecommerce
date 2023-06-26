
import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../BackEnd/ApiService.dart';
import '../../BackEnd/Entities/Detail.dart';
import '../../BackEnd/Services/AuthService.dart';
import '../../BackEnd/StaticService/StaticService.dart';
import '../../Components/Constants/groceli_icon_icons.dart';
import '../../Components/CountryCode/FLCountryCodePicker.dart';
import '../../Components/ExceptionHandling/ExceptionHandling.dart';
import '../../Components/Widgets/Button.dart';
import '../../Components/Widgets/CustomSafeArea.dart';
import '../../StateManagement/SignInManagement.dart';
import '../../UI/DeveloperModeUrlEdit.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isEditingLocalhost = false;

  @override
  void initState() {
    super.initState();
    // deviceInfo = Stream.fromFuture(StaticService.getDeviceInfo());
    SignInManagement read = context.read<SignInManagement>();
    SharedPreferences.getInstance().then((value) => read.phoneController.text =
        value.getString("phone") ?? read.phoneController.text);
  }

  String  ? selectedCountry = null;
  String ? countryCode = "+977";

  @override
  Widget build(BuildContext context) {
    // List<Widget> body = getBody(context);
    return CustomSafeArea(
      child: LayoutBuilder(builder: (context, BoxConstraints constraints) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            body: LayoutBuilder(builder: (context, BoxConstraints constraints) {
              double Function(int i) getByPercentage = (int i) {
                return (i / 844) * MediaQuery.of(context).size.height;
              };

              return getBody(context, getByPercentage, constraints.maxHeight);
            }),
          ),
        );
      }),
    );
  }

  getBody(BuildContext context, double Function(int i) getByPercentage,
      double maxHeight) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: maxHeight,
      child: SingleChildScrollView(
        child: Padding(
          padding: SpacePalette.paddingExtraLargeH,
          child: Column(
            children: [
              Column(
                children: [
                  SizedBox(height: getByPercentage(118)),
                  Image.asset(
                    "assets/splash.png",
                    height: 70,
                  ),
                  SpacePalette.spaceTiny,
                  SizedBox(
                      // height: getByPercentage(5),
                      ),
                  Text(
                    "Sign in to your account",
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
              SizedBox(height: getByPercentage(55)),
              AutofillGroup(
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    context.read<SignInManagement>().phoneValidation();
                  },
                  controller:
                  context.read<SignInManagement>().phoneController,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  decoration: InputDecoration(
                    prefix:  Theme(
                      data: ThemeData(),
                      child: GestureDetector(
                        onTap: () async {

                          FlCountryCode countryPickerWithParams =  const FlCountryCode(
                            favorites: ["NP"],
                            // filteredCountries: _yourFilters,
                            showDialCode: true,
                            showSearchBar: true,
                          );
                          CountryCode? code = await countryPickerWithParams.showPicker(
                              context: context);
                          if (code != null) {
                            setState(() {
                              countryCode = code.dialCode;
                            });
                            // widget.countrySelected!(code.dialCode);
                          }else{
                            countryCode = "+977";
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: Text(
                            countryCode??"+977",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    labelText: "Phone Number",
                    errorText:
                    context.watch<SignInManagement>().mobileErrorText,
                    hintText: "Please enter your phone number",
                  ),
                ),
              ),
              SizedBox(height: getByPercentage(26)),
              AutofillGroup(
                child: TextField(
                  onChanged: (val) {
                    context.read<SignInManagement>().passwordValidation();
                  },
                  controller:
                  context.read<SignInManagement>().passwordController,
                  autofillHints: const [AutofillHints.password],
                  obscureText:
                  !context.watch<SignInManagement>().passwordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      splashColor: Colors.transparent,
                      color: Colors.transparent,
                      hoverColor: Colors.transparent,
                      icon: Icon(
                        context.watch<SignInManagement>().passwordVisible
                            ? Icons.visibility
                            : GroceliIcon.password,
                        color:
                        context.watch<SignInManagement>().passwordVisible
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      onPressed: () {
                        context.read<SignInManagement>().passwordVisible =
                        !context.read<SignInManagement>().passwordVisible;
                      },
                    ),
                    errorText:
                    context.watch<SignInManagement>().passwordErrorText,
                    hintText: "Please type your password",
                  ),
                ),
              ),
              SizedBox(height: getByPercentage(26)),

              // const SizedBox(
              //   height: 32,
              //   width: 12,
              // ),
              SizedBox(height: getByPercentage(50)),
              getButton(context),
              SizedBox(height: getByPercentage(30)),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SpacePalette.spaceTiny,
                  SizedBox(
                    height: 12,
                    width: 12,
                    child: Checkbox(
                      fillColor: MaterialStateColor.resolveWith(
                          (states) => Theme.of(context).primaryColor),
                      onChanged: (bool? a) {
                        context.read<SignInManagement>().rememberMe =
                            a ?? context.read<SignInManagement>().rememberMe;
                      },
                      value: context.read<SignInManagement>().rememberMe,
                    ),
                  ),
                  SpacePalette.spaceMedium,
                  Text("Stay logged in?",
                      style: Theme.of(context).textTheme.bodyText1),
                  // const Spacer(),
                  // SizedBox(
                  //   child: TextButton(
                  //     onPressed: () async {
                  //       await StaticService.pushPage(
                  //           context: context,
                  //           route: const ForgotPasswordScreen());
                  //       context
                  //           .read<ResetPasswordManagement>()
                  //           .phoneNumberController
                  //           .text = "";
                  //     },
                  //     child: Text(
                  //       "Forgot Password?",
                  //       style: Theme.of(context)
                  //           .textTheme
                  //           .bodyText1
                  //           ?.copyWith(color: Theme.of(context).primaryColor),
                  //     ),
                  //   ),
                  // )
                ],
              ),
              SizedBox(
                height: getByPercentage(130),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       "Don't have an account?",
              //       style: Theme.of(context).textTheme.bodyText1,
              //     ),
              //     TextButton(
              //         onPressed: () async {
              //           PermissionGrant? success =
              //               await PermissionGrant.initializePermisssion(
              //                   context);
              //           await StaticService.pushPage(
              //               context: context,
              //               route: ConfirmPermissionThen(
              //                   permitted: success == null,
              //                   child: SignUpScreen()));
              //           // await Navigator.of(context).push(MaterialPageRoute(
              //           //     builder: (_) => const SignUpScreen2()));
              //           context.read<SignUpAndCameraManagement>().clearData();
              //         },
              //         child: Text(
              //           "Sign up here",
              //           style: Theme.of(context)
              //               .textTheme
              //               .bodyText1
              //               ?.copyWith(color: Theme.of(context).primaryColor),
              //         )),
              //   ],
              // ),
              if (ApiService.serverService.isProduction)
                Column(
                  children: [
                    GestureDetector(
                        onTap: () => setState(
                            () => isEditingLocalhost = !isEditingLocalhost),
                        child: SizedBox(
                          height: 40,
                          width: double.infinity,
                          child: Center(
                            child: Text("v${ApiService.showVersion}"),
                          ),
                        )),
                    isEditingLocalhost ? DeveloperModeUrlEdit() : Container(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButtonPrimary(
              onPressedFunction: () async {
                // FirebaseAnalytics.instance.logEvent(name: "Login", parameters: {
                //   "phone": context.read<SignInManagement>().phoneController.text
                // });
                await ExceptionHandling.catchExceptions(function: () async {
                  bool isValidated =
                      context.read<SignInManagement>().signInValidation();
                  if (isValidated) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    SignInManagement read = context.read<SignInManagement>();
                    var thisDevice = await StaticService.getDeviceInfo();
                    LoginData? loginData = await AuthService().auth(
                        read.phoneController.text,
                        read.passwordController.text, // await (deviceInfo.first),
                        thisDevice,
                      countryCode!,);
                    read.loginData = loginData;
                    if (loginData == null) return;
                    SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    await preferences.setString("loginTime", DateTime.now().toString());
                    read.authToken = loginData.accessToken;
                    read.refreshToken = loginData.refreshToken;
                    if (read.rememberMe) {
                      await read.setPrefs(loginData.accessToken ?? "",
                          loginData.refreshToken ?? "", preferences);
                    }
                  }
                });
              },
              text: "LOGIN"),
        ),
      ],
    );
  }
}
