import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/others/validator.dart';

class EnterPassword extends ConsumerWidget {
  const EnterPassword({super.key, this.log = false, required this.phone});
  final bool log;
  final String phone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final obscureTextProvider = StateProvider<bool>((ref) {
      return true;
    });
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    String password = "";
    return SafeArea(
        child: Scaffold(
      appBar:
          simpleAppBar(context, title: "Change Phone Number", search: false),
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
                  'Enter Password',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontSize: 24.ssp(),
                      color: Theme.of(context).primaryColor),
                ),
                SizedBox(
                  height: 9.sh(),
                ),
                Text(
                  'Enter your password to Continue.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: CustomTheme.getBlackColor()),
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
                  Consumer(builder: (context, ref, c) {
                    final obscureText =
                        ref.watch(obscureTextProvider.state).state;
                    return InputTextField(
                      controller: ref
                          .read(userChangeProvider)
                          .changeNumberPasswordController,
                      inputAction: TextInputAction.done,
                      // limit: true,
                      // limitNumber: 8,
                      onSubmit: (val) {},
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
                  CustomElevatedButton(
                      width: double.infinity,
                      onPressedElevated: () async {
                        try {
                          final userService = ref.read(userChangeProvider);
                          var status = await userService.changeNUmber(
                              phone: phone, password: password);
                          if (status) {
                            snack.success("Mobile Number changed successfully");
                            // customSocket.connect();

                            ref
                                .read(userChangeProvider)
                                .changeNumberPasswordController
                                .clear();
                            ref
                                .read(userChangeProvider)
                                .changeNumberPhoneController
                                .clear();
                            Future.delayed(const Duration(milliseconds: 50),
                                () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            });
                          }
                          // else {
                          //   snack.error(e.toString());
                          // }
                        } catch (e) {
                          snack.error(e.toString());
                        }
                      },
                      elevatedButtonText: 'Continue')
                ],
              ),
            ),
          )
        ],
      )),
    ));
  }
}
