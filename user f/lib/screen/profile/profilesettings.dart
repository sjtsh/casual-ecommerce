import 'package:ezdeliver/screen/auth/login/resetpassword.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/profile/changenumber.dart';

import 'package:ezdeliver/screen/settingsscreen/models/menuItems.dart';
import 'package:ezdeliver/screen/settingsscreen/settingsscreen.dart';

class ProfileSetting extends StatelessWidget {
  ProfileSetting({super.key});
  final List<MenuItems> menu = [
    MenuItems(
        menuIcon: Icons.person,
        menuName: 'Change Phone Number',
        id: '22',
        onPressed: (context) async {
          if (!ResponsiveLayout.isMobile) {
            ResponsiveLayout.setProfileWidget(const ChangePhoneNUmber());
          } else {
            Utilities.pushPage(const ChangePhoneNUmber(), 15);
          }
        }),
    MenuItems(
        menuIcon: Icons.key,
        menuName: 'Reset Password',
        id: '44',
        onPressed: (context) async {
          final thisUser =
              CustomKeys.ref.read(userChangeProvider).loggedInUser.value!;
          if (!ResponsiveLayout.isMobile) {
            ResponsiveLayout.setProfileWidget(
              ResetPassword(
                phone: thisUser.phone,
                reset: false,
              ),
            );
          } else {
            Utilities.pushPage(
                ResetPassword(
                  phone: thisUser.phone,
                  reset: false,
                ),
                15);
          }
        }),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(
        context,
        title: "Profile Setings",
        search: false,
        close: ResponsiveLayout.isMobile ? true : false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemBuilder: ((context, index) {
                  return MenuItemWidget(item: menu[index]);
                }),
                // separatorBuilder: ((context, index) {
                //   return Divider(
                //     color: CustomTheme.getBlackColor(),
                //     thickness: 0.2,
                //   );
                // }),
                itemCount: menu.length),
          ),
        ],
      ),
    );
  }
}
