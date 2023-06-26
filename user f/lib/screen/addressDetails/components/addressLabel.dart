import 'package:ezdeliver/screen/component/helper/exporter.dart';

final addressIndexProvider = StateProvider<int>((ref) {
  return 0;
});

class AddressLabel extends ConsumerWidget {
  AddressLabel({
    Key? key,
    required this.label,
    required this.index,
    required this.icon,
  }) : super(key: key);
  final String label;
  final int index;
  final IconData icon;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    // final selectedIndex = ref.watch(addressIndexProvider.state).state;
    // ref.read(addressIndexProvider.state).state = index;
    return GestureDetector(
        // onTap: () {
        //   ref.read(addressIndexProvider.state).state = index;
        // },
        child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(14.sr()),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.sr()),
              border: Border.all(
                  style: BorderStyle.solid,
                  color:
                      // selectedIndex == index
                      //     ?
                      Theme.of(context).primaryColor
                  // : CustomTheme.greyColor,
                  )),
          child: Icon(
            icon,
            color:
                // selectedIndex == index
                //     ?
                Theme.of(context).primaryColor,
            // : CustomTheme.greyColor,
            size: 38.sr(),
          ),
        ),
        SizedBox(
          height: 13.sh(),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyText2!.copyWith(
              color:
                  // selectedIndex == index
                  // ?
                  Theme.of(context).primaryColor,
              // : CustomTheme.getBlackColor(),
              fontSize: 12.ssp()),
        ),
      ],
    )

        // Container(
        //     padding: EdgeInsets.symmetric(vertical: 5.sh(), horizontal: 10.sw()),
        //     decoration: BoxDecoration(
        //         color: selectedIndex == index
        //             ? Theme.of(context).primaryColor
        //             : CustomTheme.whiteColor,
        //         borderRadius: BorderRadius.circular(12.sr()),
        //         border: Border.all(
        //             strokeAlign: StrokeAlign.outside,
        //             color: Theme.of(context).primaryColor)),
        //     child: Text(
        //       label,
        //       style: Theme.of(context).textTheme.bodyText2!.copyWith(
        //           color: selectedIndex == index
        //               ? CustomTheme.whiteColor
        //               : Theme.of(context).primaryColor,
        //           fontSize: 12.ssp()),
        //     )),
        );
  }
}
