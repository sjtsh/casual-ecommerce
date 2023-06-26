import 'package:ezdeliver/screen/component/helper/exporter.dart';

import 'package:ezdeliver/screen/auth/login/login.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      ref.read(userChangeProvider).signInPhoneController.text =
          prefs.getString("phone") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Login(),
            ),
          ],
        ),
      ),
    );
  }
}
