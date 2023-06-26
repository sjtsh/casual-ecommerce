import 'package:ezdeliver/screen/cart/components/cartItems.dart';
import 'package:ezdeliver/screen/cart/components/checkoutbox.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';

class Cart extends ConsumerWidget {
  const Cart({super.key, this.newScreen = false, this.notifier});
  final bool newScreen;
  final ChangeNotifierProvider<CartService>? notifier;
  @override
  Widget build(BuildContext context, ref) {
    // final cartService = ref.read(notifier ?? cartServiceProvider);
    final itemCount =
        ref.watch(notifier ?? cartServiceProvider).cartItems.length;
    // print(itemCount);
    return SafeArea(
      child: Scaffold(
        // backgroundColor: Colors.transparent,
        appBar: newScreen
            ? simpleAppBar(context,
                title: "Cart",
                search: false,
                close: false,
                actions: [
                    Padding(
                      padding: EdgeInsets.all(10.sr()),
                      child: const EmptyCartWidget(),
                    )
                  ])
            : simpleAppBar(context,
                title: "Cart",
                close: false,
                search: false,
                // setting: true,
                actions: [
                    Padding(
                      padding: EdgeInsets.all(10.sr()),
                      child: const EmptyCartWidget(),
                    )
                  ]),
        body: Column(
          children: [
            Expanded(
              child: CartItems(
                cart: true,
                notifier: notifier,
              ),
            ),
            if (itemCount > 0)
              Builder(builder: (context) {
                // print("here");
                return CartDetails(
                  checkout: false,
                  promo: false,
                  notifier: notifier,
                );
              })
          ],
        ),
      ),
    );
  }
}
