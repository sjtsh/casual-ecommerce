import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/orderHistory/components/orderListItem.dart';

class OrderFilter extends StatelessWidget {
  const OrderFilter({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusList = StatusForFilter.values.map((e) {
      return e.index;
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 22.sw(),
        right: 22.sw(),
        bottom: 0.sh(),
      ),
      child: Row(
        children: [
          const Expanded(child: FilterChipRow()),
          SizedBox(
            width: 12.sw(),
          ),
          PopupMenuButton(
              padding: EdgeInsets.zero,
              color: Theme.of(context).backgroundColor,
              child: Icon(GroceliIcon.filter_circle,
                  size: 26.sr(), color: CustomTheme.primaryColor),
              itemBuilder: (context) {
                return statusList
                    .asMap()
                    .entries
                    .map((e) => PopupMenuItem(
                        enabled: false,
                        onTap: null,
                        child: FilterItemWidget(
                          status: e.value,
                        )))
                    .toList();
              }),
        ],
      ),
    );
  }
}

class FilterItemWidget extends ConsumerWidget {
  const FilterItemWidget({
    Key? key,
    required this.status,
  }) : super(key: key);
  final int status;

  @override
  Widget build(BuildContext context, ref) {
    final activeFilters = ref.watch(orderHistoryServiceProvider).activeFilters;

    return GestureDetector(
      onTap: () {
        ref.read(orderHistoryServiceProvider).addOrRemoveFilter(status);
      },
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: Checkbox(
                  value: activeFilters.isEmpty
                      ? false
                      : activeFilters.contains(status),
                  onChanged: (val) {
                    ref
                        .read(orderHistoryServiceProvider)
                        .addOrRemoveFilter(status);
                  }),
            ),
            SizedBox(
              width: 8.sw(),
            ),
            Text(
              getStatusDetail(getStatus(status)).label,
              style: kTextStyleInterRegular.copyWith(
                  fontSize: 12.ssp(), color: CustomTheme.getBlackColor()),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterChipRow extends ConsumerWidget {
  const FilterChipRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilters = ref.watch(orderHistoryServiceProvider).activeFilters;

    return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: activeFilters.isEmpty ? 1 : activeFilters.length,
        separatorBuilder: (context, index) => SizedBox(
              width: 20.sw(),
            ),
        itemBuilder: (context, index) {
          if (activeFilters.isEmpty) {
            return Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.sw(), vertical: 4.sh()),
              color: CustomTheme.successColor.withAlpha(30),
              child: Text(
                "All",
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    fontSize: 14.ssp(), color: CustomTheme.successColor),
              ),
            );
          }
          // print(activeFilters[index]);
          return StatusBox(
            toolTip: false,
            status: activeFilters[index],
            filter: () {
              ref
                  .read(orderHistoryServiceProvider)
                  .addOrRemoveFilter(activeFilters[index]);
            },
          );
        });
  }
}
