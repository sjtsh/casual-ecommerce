import 'package:ezdelivershop/Components/DropDown/AppDropDown.dart';
import 'package:ezdelivershop/UI/Product/SubproductScreen/NoSearchResults/NoSearchResults.dart';
import 'package:ezdelivershop/UI/Product/SubproductScreen/SearchResults/SearchResults.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../BackEnd/Entities/SearchProduct.dart';
import '../../../BackEnd/Entities/Shop.dart';
import '../../../Components/Constants/SpacePalette.dart';
import '../../../Components/Widgets/CustomAppBar.dart';
import '../../../Components/Widgets/CustomSafeArea.dart';
import '../../../StateManagement/NotSearchingProductManagement.dart';
import '../../../StateManagement/SearchingProductManagement.dart';
import '../../../StateManagement/SignInManagement.dart';
import '../../../Components/Widgets/MyCircleAvatar.dart';
import 'ProductSearchTextField.dart';

class SubProductScreen extends StatefulWidget {
  final bool onlyProduct;

  const SubProductScreen({required this.onlyProduct, Key? key})
      : super(key: key);

  @override
  State<SubProductScreen> createState() => _SubProductScreenState();
}

class _SubProductScreenState extends State<SubProductScreen> {
  Shop? selectedShop;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        selectedShop =
            context.read<SignInManagement>().loginData?.staff?.shop?.first;
      });
      changeShop(
          context.read<SignInManagement>().loginData?.staff?.shop?[0]?.id);
    });
  }

  changeShop(String? shopId) {
    context.read<NotSearchingProductManagement>().shopId = shopId;
    context.read<NotSearchingProductManagement>().reset(0, 6, shopId: shopId);
    context.read<TabProduct>().page = 0;
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
        child: GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: Column(children: [
          SpacePalette.spaceMedium,
          CustomAppBar(
            titleWidget: AppDropDown(
              buttonColor: Colors.transparent,
              selectedItemBuilder:
                  context.read<SignInManagement>().loginData?.staff.shop,
              value: selectedShop,
              onchanged: (shop) {
                setState(() {
                  selectedShop = shop;
                });
                changeShop(shop.id);
              },
            ),
            leftButton: !widget.onlyProduct,
            leftButtonWidget: widget.onlyProduct
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: MyCircleAvatar(),
                  )
                : IconButton(
                    splashRadius: 26,
                    icon: const Icon(Icons.arrow_back_ios_outlined),
                    onPressed: () {
                      context
                          .read<SearchingProductManagement>()
                          .controller
                          .clear();
                      Navigator.of(context).pop();
                    },
                  ),
            rightButton: true,
            rightButtonWidget: GestureDetector(
                onTap: () => context
                    .read<NotSearchingProductManagement>()
                    .reset(0, 6,
                        shopId: context
                            .read<NotSearchingProductManagement>()
                            .shopId),
                child: const Padding(
                  padding: EdgeInsets.only(right: 6, left: 6),
                  child: Icon(Icons.refresh),
                )),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: ProductSearchTextField(),
          ),
          Expanded(
            child: Builder(builder: (context) {
              SearchingProductManagement watch =
                  context.watch<SearchingProductManagement>();
              List<SearchProduct>? res = watch.results;
              SearchingProductManagement read =
                  context.read<SearchingProductManagement>();
              return Stack(
                children: [
                  NoSearchResults(
                      context.watch<NotSearchingProductManagement>().shopId!),
                  Builder(builder: (context) {
                    if (read.controller.text.isEmpty) return Container();
                    return Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.white,
                      child: Builder(builder: (context) {
                        if (res == null) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return SearchResults(res);
                      }),
                    );
                  })
                ],
              );
            }),
          )
        ]),
      ),
    ));
  }
}
