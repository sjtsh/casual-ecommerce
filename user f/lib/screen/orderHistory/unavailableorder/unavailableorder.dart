import 'package:ezdeliver/screen/cart/components/cartItems.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';

class UnavailableOrder extends ConsumerWidget {
  const UnavailableOrder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartService = ref.watch(cartServiceProvider);
    final item = cartService.reOrderItems;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Unavailable Items"),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.separated(
                  padding: EdgeInsets.all(15.sr()),
                  itemBuilder: (context, index) {
                    return ProductItems(cart: false, item: item[index]);
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 12.sh(),
                    );
                  },
                  itemCount: item.length),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              color: Theme.of(context).primaryColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total: ",
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontSize: 14.ssp(), color: CustomTheme.whiteColor),
                  ),
                  Text(
                    "Rs. ${cartService.total(items: item).toStringAsFixed(0)}",
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontSize: 16.ssp(), color: CustomTheme.whiteColor),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.sh(),
            ),
            CustomElevatedButton(
                color: CustomTheme.whiteColor,
                width: 250.sw(min: 200),
                onPressedElevated: () {},
                elevatedButtonText: "Re-Order"),
            SizedBox(
              height: 10.sh(),
            ),
          ],
        ),
      ),
    );
  }
}
