import 'dart:async';

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/orderModel.dart';

class ItemQuantity extends StatelessWidget {
  const ItemQuantity({
    Key? key,
    required this.index,
    required this.cartService,
    required this.item,
    this.custom = false,
    this.cart = false,
  }) : super(key: key);

  final CartService cartService;
  final OrderItem item;
  final int index;
  final bool custom, cart;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: !custom ? 5.sw() : 10.sw()),
      child: Container(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        decoration: BoxDecoration(
          // color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(8.sr()),
        ),
        child: Row(
          // mainAxisSize: MainAxisSize.min,
          children: [
            ItemAddRemove(
              onLongPressStart: (detail) {
                // print("cart $cart");
                cartService.timer = Timer.periodic(
                    //milliseconds: 500 = increase speed
                    const Duration(milliseconds: 100),
                    (Timer t) => cartService.changeQuantityOfItem(item.product,
                        cart: cart));
              },
              onLongPressEnd: (detail) {
                cartService.timer.cancel();
              },
              item: item,
              onPressed: () {
                // print("cart $cart");
                cartService.changeQuantityOfItem(item.product, cart: cart);
              },
              icon: Icons.remove,
            ),
            SizedBox(
              width: 5.sw(),
            ),
            Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: Builder(builder: (context) {
                    // final itemCount=ref.watch(cartServiceProvider).cartItems[]
                    return Text(
                      item.itemCount.toString(),
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontSize: 13.ssp(), fontWeight: FontWeight.w600),
                    ).animate().scaleXY();
                  })),
            ),
            SizedBox(
              width: 5.sw(),
            ),
            ItemAddRemove(
              item: item,
              onLongPressStart: (detail) {
                cartService.timer = Timer.periodic(
                    //milliseconds: 500 = increase speed
                    const Duration(milliseconds: 100),
                    (Timer t) => cartService.changeQuantityOfItem(item.product,
                        add: true));
              },
              onLongPressEnd: (detail) {
                cartService.timer.cancel();
              },
              onPressed: () {
                cartService.changeQuantityOfItem(item.product, add: true);
              },
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}

class ItemAddRemove extends ConsumerWidget {
  const ItemAddRemove({
    Key? key,
    required this.item,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  final OrderItem item;
  final IconData icon;
  final Function onPressed, onLongPressStart, onLongPressEnd;

  @override
  Widget build(BuildContext context, ref) {
    return GestureDetector(
      onLongPressStart: (details) {
        onLongPressStart(details);
      },
      onLongPressEnd: (details) {
        onLongPressEnd(details);
      },
      onTap: () {
        onPressed();
      },
      child: Container(
        // color: Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 10.sr()),
        child: Container(
          margin: EdgeInsets.all(1.sr()),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.sr()),
            color: Theme.of(context).primaryColor,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
