import 'package:ezdeliver/screen/auth/login/forgetpassword.dart';
import 'package:ezdeliver/screen/auth/login/login.dart';
import 'package:ezdeliver/screen/auth/login/resetpassword.dart';
import 'package:ezdeliver/screen/auth/register/register.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/yourLocation/yourLocation.dart';

final shouldSignUp = StateProvider<bool>((ref) {
  return false;
});

final authProvider = StateProvider<Auth>((ref) {
  return Auth.login;
});

class Utilities {
  Utilities._();
  // static BuildContext context = CustomKeys.navigatorkey.currentContext!;
  static futureDelayed(int milliseconds, Function funcation) async {
    await Future.delayed(Duration(milliseconds: milliseconds), () {
      funcation();
    });
  }

  static checkIfLoggedIn(
      {Function? doIfLoggedIN, required BuildContext context}) {
    var user = CustomKeys.ref.read(userChangeProvider).loggedInUser.value;

    if (user == null) {
      showAuthScreenInDialog(context);
    } else {
      if (doIfLoggedIN != null) {
        doIfLoggedIN();
      }
    }
  }

  static changePageNotMobile(Function function) {
    if (!ResponsiveLayout.isMobile) {
      function();
    }
  }

  static showAuthScreenInDialog(context) async {
    CustomKeys.ref.read(shouldSignUp.notifier).state = true;
    return;
    await showDialog(
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width < 600
                    ? 10
                    : MediaQuery.sizeOf(context).width / 3,
                vertical: MediaQuery.sizeOf(context).height / 11),
            child: Material(child: Consumer(builder: (context, ref, c) {
              final auth = ref.watch(authProvider);

              return Stack(
                children: [
                  Container(
                    child: auth == Auth.login
                        ? Login(
                            dialog: true,
                          )
                        : auth == Auth.signup
                            ? RegisterScreen(
                                dialog: true,
                              )
                            : const ForgotPassword(dialog: true),
                  ),
                  Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ))
                ],
              );
            })),
          );
        });
    CustomKeys.ref.read(authProvider.notifier).state = Auth.login;
  }

  static loadall({BuildContext? context}) async {
    // BuildContext? c = context;
    CustomKeys.ref.read(userChangeProvider).loadingallFuncation();
    // if (context != null) {
    //   CustomDialogBox.loading(true, c: c);
    // }

    Utilities.futureDelayed(10, () async {
      CustomKeys.ref.read(orderHistoryServiceProvider).checkOrderStatus();
      await CustomKeys.ref
          .read(productCategoryServiceProvider)
          .fetchCategories();
      print("here");
      await CustomKeys.ref
          .read(productCategoryServiceProvider)
          .fetchTrendingProducts();
      await CustomKeys.ref
          .read(productCategoryServiceProvider)
          .fetchAllSubCategoriesWithProducts(clear: true);
      await CustomKeys.ref
          .read(productCategoryServiceProvider)
          .fetchHomeBanners();
      await CustomKeys.ref.read(orderHistoryServiceProvider).fetchOrders();

      // if (context != null) CustomDialogBox.loading(false, c: c);
      CustomKeys.ref.read(userChangeProvider).loadingallFuncation();
      // CustomKeys.ref.read(cartServiceProvider).condi =
      //     ConditionsForNotAvail.someNotAvail;
    });
  }

  static pushPage(Widget widget, int milliseconds,
      {BuildContext? context, Function? function, String? id}) async {
    await futureDelayed(milliseconds, () async {
      if (!ResponsiveLayout.isMobile && widget.toString() == "YourLocation") {
        CustomDialogBox.dailog(
            CustomKeys.context,
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveLayout.margin(0.22), vertical: 30.sh()),
              child: widget,
            ),
            barrier: true);
        return;
      }
      if (!ResponsiveLayout.isMobile) {
        CustomDialogBox.dailog(
            CustomKeys.context,
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveLayout.margin(0.22), vertical: 30.sh()),
              child: widget,
            ),
            barrier: true);
        return;
      }
      if (function != null) {
        function();
      }

      var finalContext =
          context ?? CustomKeys.navigatorkey.currentState!.context;
      var currentRoute = ModalRoute.of(finalContext);
      if (currentRoute != null) {
        if (currentRoute.settings.name == widget.toString()) {
          print("old route");
        } else {
          print("new route");
        }
      }
      await Navigator.push(
        finalContext,
        MaterialPageRoute(
          settings: RouteSettings(
              name: "$widget/${id ?? ""}",
              arguments: id != null ? {"id": id} : null),
          builder: (context) {
            return widget;
          },
        ),
      );
      // var theme = CustomKeys.ref.read(customThemeServiceProvider);
      // theme.switchThemeMode(theme.themeMode);
      // var cr = ModalRoute.of(context);
      // if (cr != null) {
      //   cr.settings.name;
      //   print(cr.settings.name);
      // }
    });
  }

  static pushPageRReplacement(Widget widget, int milliseconds,
      {BuildContext? context}) async {
    await futureDelayed(
      milliseconds,
      await Navigator.pushReplacement(
        context ?? CustomKeys.navigatorkey.currentContext!,
        MaterialPageRoute(
          builder: (context) {
            return widget;
          },
        ),
      ),
    );
  }

  static showCustomDialog(
      {required BuildContext context,
      required Function onpressedElevated,
      required String textSecond}) {
    showDialog(
        context: context,
        builder: (context) {
          return Padding(
            padding:
                EdgeInsets.symmetric(horizontal: ResponsiveLayout.margin(0.25)),
            child: CustomDialog(
                textSecond: textSecond,
                elevatedButtonText: 'Confirm',
                onPressedElevated: () async {
                  onpressedElevated();
                }),
          );
        });
  }
}
