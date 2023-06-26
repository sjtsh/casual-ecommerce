import 'package:ezdeliver/screen/cart/components/cartItems.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/models/orderModel.dart';

class NoProductPrice extends ConsumerWidget {
  const NoProductPrice(
      {super.key, this.notAvailable = const [], this.priceChanged = const []});
  final List<OrderItem> notAvailable, priceChanged;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: simpleAppBar(context, title: "Product Details", search: false),
      body: Column(
        children: [
          if (notAvailable.isNotEmpty)
            Expanded(
              child: itemList(context, notAvailable),
            ),
          if (priceChanged.isNotEmpty)
            Expanded(
              child: itemList(context, priceChanged, notavailable: false),
            ),
        ],
      ),
    );
  }

  Widget itemList(context, List<OrderItem> data, {bool notavailable = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.sw(), vertical: 20.sh()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${notavailable ? "Not Available" : "Price/Qty Changed"} (${data.length})",
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: CustomTheme.getBlackColor(),
                    fontWeight: FontWeight.w600),
              ),
              if (notavailable)
                GestureDetector(
                  onTap: () {
                    CustomKeys.ref
                        .read(orderHistoryServiceProvider)
                        .reorder(notAvailable);
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Text(
                      "Reorder",
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: CustomTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 22.sw()),
              itemBuilder: (context, index) {
                return ProductItems(
                  isOrderDetail: true,
                  item: data[index],
                  cart: false,
                  notAvailable: notavailable,
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 20.sh(),
                );
              },
              itemCount: data.length),
        ),
      ],
    );
  }
}
