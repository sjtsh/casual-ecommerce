import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/orderHistory/components/orderList.dart';
import 'package:ezdeliver/screen/orderHistory/components/orderdetail.dart';
import 'package:ezdeliver/screen/orderHistory/components/pageHeader.dart';
import 'package:ezdeliver/screen/orderHistory/orderfilter/orderfilter.dart';

class OrderHistory extends ConsumerWidget {
  const OrderHistory({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final orderHistoryService = ref.watch(orderHistoryServiceProvider);
    // final orders = orderHistoryService.orders.toList();

    return Scaffold(
      appBar: ResponsiveLayout.isMobile
          ? simpleAppBar(context, title: "Orders", close: false, setting: true)
          : null,
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!ResponsiveLayout.isMobile) ...[
            if (ResponsiveLayout.isMobile) const CustomAppBar(),
            Row(
              children: [
                Text("Your Orders"),

                Expanded(
                  child: SizedBox(height: 24.sh(), child: const OrderFilter()),
                )

                // SizedBox(height: 24.sh(), child: const OrderFilter()
                // ),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        const PageViewHeader(),
                        // SizedBox(
                        //   height: 21.sh(),
                        // ),
                        Expanded(
                          child: PageView(
                              controller: orderHistoryService.pageController,
                              onPageChanged: (value) {
                                orderHistoryService.selectedIndex = value;
                              },
                              children: orderHistoryService.tabs
                                  .asMap()
                                  .entries
                                  .map((e) => OrderList(
                                        // orders: orders,
                                        today: e.key == 0,
                                      ))
                                  .toList()),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: OrderDetail(),
                  )
                ],
              ),
            )
          ] else ...[
            const PageViewHeader(),
            SizedBox(
              height: 21.sh(),
            ),
            Expanded(
              child: PageView(
                  controller: orderHistoryService.pageController,
                  onPageChanged: (value) {
                    orderHistoryService.selectedIndex = value;
                  },
                  children: orderHistoryService.tabs
                      .asMap()
                      .entries
                      .map((e) => OrderList(
                            // orders: orders,
                            today: e.key == 0,
                          ))
                      .toList()),
            ),
          ]
        ],
      ),
    );
  }
}
