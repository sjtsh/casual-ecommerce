import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/orderModel.dart';
import 'package:ezdeliver/screen/orderHistory/components/orderListItem.dart';
import 'package:ezdeliver/screen/orderHistory/components/orderdetail.dart';

class OrderList extends ConsumerWidget {
  OrderList({
    this.today = true,
    Key? key,
    // required this.orders,
  }) : super(key: key);

  // final List<Order> orders;
  final bool today;
  late final ScrollController scrollController = initScroll();

  ScrollController initScroll() {
    final controller = ScrollController();
    controller.addListener(() async {
      if (controller.position.extentAfter < 10) {
        await CustomKeys.ref
            .read(orderHistoryServiceProvider)
            .loadMoreData(today: today);
      }
    });
    return controller;
  }

  final List<Order>? modifiedOrders = [];
  @override
  Widget build(BuildContext context, ref) {
    final activeFilters = ref.watch(orderHistoryServiceProvider).activeFilters;
    final orderHistoryService = ref.read(orderHistoryServiceProvider);
    var ordersCheck = filterOrders(
        today ? orderHistoryService.ordersToday : orderHistoryService.orders,
        activeFilters);

    // sortOrders(today, ref, activeFilters: activeFilters);
    if (ordersCheck == null) return InfoMessage.noOrdersWithFilter();
    modifiedOrders!.addAll(ordersCheck);
    if (ordersCheck.isEmpty && today) {
      return InfoMessage.noOrdersToday();
    }

    return modifiedOrders!.isEmpty
        ? InfoMessage.noOrders()
        : RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: () async {
              await ref
                  .read(orderHistoryServiceProvider)
                  .fetchOrders(clear: true, today: today);
            },
            child: Consumer(builder: (context, ref, c) {
              final isLoadingMore =
                  ref.watch(orderHistoryServiceProvider).isLoadingMoreData;

              return ListView.separated(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(
                      horizontal: 18.sw(), vertical: 30.sh()),
                  itemBuilder: (context, index) {
                    var newIndex = index;

                    if (index == modifiedOrders!.length && isLoadingMore) {
                      return Center(
                        child: Transform.scale(
                            scale: 0.8,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            )),
                      );
                    }
                    // print(modifiedOrders![index].orderId);
                    var child = GestureDetector(
                      onTap: () {
                        ref.read(orderHistoryServiceProvider).selectedOrder =
                            modifiedOrders![newIndex];

                        ref
                            .read(orderHistoryServiceProvider)
                            .fetchOneOrder(order: modifiedOrders![newIndex]);
                        if (ResponsiveLayout.isMobile) {
                          Utilities.pushPage(const OrderDetail(), 10,
                              context: context,
                              id: modifiedOrders![newIndex].id);
                        }
                      },
                      child: OrderListItem(
                        order: modifiedOrders![index],
                      ),
                    );
                    return child;
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 21.sh());
                  },
                  itemCount: isLoadingMore
                      ? modifiedOrders!.length + 1
                      : modifiedOrders!.length);
            }),
          );
  }

  // List<Order>? sortOrders(bool today, WidgetRef ref,
  //     {required List<int> activeFilters}) {
  //   List<Order> order = [];
  //   if (today) {
  //     order = ref.read(orderHistoryServiceProvider).ordersToday;
  //   } else {
  //     order = ref.read(orderHistoryServiceProvider).orders;
  //   }

  //   // var todayOrder = orders
  //   //     .where((element) => element.createdAt!.day == DateTime.now().day)
  //   //     .toList();

  //   // if (today) {
  //   //   return filterOrders(todayOrder, activeFilters);
  //   // } else {
  //   //   if (todayOrder.isNotEmpty) {
  //   //     List<Order> oldOrders = [];
  //   //     for (var element in orders) {
  //   //       if (!todayOrder.contains(element)) {
  //   //         oldOrders.add(element);
  //   //       }
  //   //     }
  //   //     return filterOrders(oldOrders, activeFilters);
  //   //   }
  //   //   return filterOrders(orders, activeFilters);
  //   // }
  //   return filterOrders(order, activeFilters);
  // }

  List<Order>? filterOrders(List<Order> newOrders, List<int> activeFilters) {
    List<Order> finalOrders = [];
    List<int> newFilter = [];

    if (activeFilters.isEmpty) {
      return newOrders;
    } else {
      newFilter.clear();
      newFilter.addAll(activeFilters);
      if (activeFilters.contains(6)) {
        for (int i = 7; i < 9; i++) {
          newFilter.add(i);
        }
      }
      for (var element in newOrders) {
        // print(getStatus(element.status).index);
        if (newFilter.contains(getStatus(element.status).index)) {
          finalOrders.add(element);
        }
      }
      return finalOrders.isEmpty ? null : finalOrders;
    }
  }
}
