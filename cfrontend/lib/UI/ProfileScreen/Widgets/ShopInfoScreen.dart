import 'package:expandable/expandable.dart';
import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
import 'package:ezdelivershop/Components/Constants/CardStylePalette.dart';
import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
import 'package:ezdelivershop/Components/Widgets/CustomAppBar.dart';
import 'package:ezdelivershop/Components/Widgets/CustomSafeArea.dart';
import 'package:ezdelivershop/StateManagement/SignInManagement.dart';
import 'package:ezdelivershop/UI/ProfileScreen/Widgets/SettingsInfo.dart';
import 'package:ezdelivershop/UI/ProfileScreen/Widgets/ShopImage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../BackEnd/Entities/Shop.dart';
import '../../../Components/CustomTheme.dart';

class ShopInfoList extends StatefulWidget {
  const ShopInfoList({Key? key}) : super(key: key);

  @override
  State<ShopInfoList> createState() => _ShopInfoListState();
}

class _ShopInfoListState extends State<ShopInfoList> {
  late List<Shop>? s;

  final Map<String, ExpandableController> _expControllers = {};

  @override
  void initState() {
    s = context.read<SignInManagement>().loginData?.staff.shop;
    s?.forEach((element) {
      _expControllers[element.id] = ExpandableController();
    });
    _expControllers[s!.first.id]?.toggle();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
        child: Scaffold(
      body: Column(
        children: [
          const CustomAppBar(
            title: "Shop Info",
            leftButton: true,
          ),
          if (s != null)
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: s?.length,
                  itemBuilder: (BuildContext context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              color: context.watch<CustomTheme>().isDarkMode
                                  ? ColorPalette.darkContainerColor
                                  : Colors.white,
                              boxShadow: [CardStylePalette.kBoxShadowDark]),
                          child: ExpandablePanel(
                              controller: _expControllers[s?[index]?.id],
                              theme: ExpandableThemeData(
                                useInkWell: false,
                                headerAlignment:
                                    ExpandablePanelHeaderAlignment.center,
                                iconColor:
                                    context.watch<CustomTheme>().isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                tapBodyToCollapse: true,
                                tapBodyToExpand: true,
                              ),
                              header: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 20),
                                child: Container(
                                  child: Text(
                                    s?[index].name ?? "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              collapsed: const SizedBox(),
                              expanded: ExpandableButton(
                                  child: ShopInfoScreen(s![index]))),
                        ),
                      ),
                    );
                  }),
            )),
        ],
      ),
    ));
  }
}

class ShopInfoScreen extends StatelessWidget {
  final Shop shop;

  ShopInfoScreen(this.shop, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 2,
                child: ShopImage(
                  shop: shop,
                )),
          ],
        ),
        SettingsInfo(
          text: shop.name,
          darkModeIcon: const Icon(
            Icons.store,
            color: Colors.white,
          ),
          icon: const Icon(
            Icons.store,
            color: Colors.grey,
          ),
        ),
        SettingsInfo(
          text: shop.address.capitalize(),
          darkModeIcon: const Icon(
            Icons.location_on_outlined,
            color: Colors.white,
          ),
          icon: const Icon(
            Icons.location_on_outlined,
            color: Colors.grey,
          ),
        ),
        SettingsInfo(
          text: shop.phone,
          darkModeIcon: const Icon(
            Icons.call_outlined,
            color: Colors.white,
          ),
          icon: const Icon(
            Icons.call_outlined,
            color: Colors.grey,
          ),
        )
      ],
    );
  }
}
