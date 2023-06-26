import 'package:ezdeliver/screen/addressDetails/components/addressForm.dart';
import 'package:ezdeliver/screen/addressDetails/components/addressitemwidget.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/yourLocation/components/slidableWidget.dart';

class AddressList extends ConsumerWidget {
  const AddressList({
    this.viewOnly = false,
    this.isDetail = false,
    Key? key,
  }) : super(key: key);
  final bool viewOnly, isDetail;

  @override
  Widget build(BuildContext context, ref) {
    final address = ref.watch(userChangeProvider).loggedInUser.value?.address;
    // final locationService = ref.watch(locationServiceProvider);
    // final locationPermission = locationService.permissionEnums;
    if (address == null) return Container();
    return ListView.separated(
      itemBuilder: (context, index) {
        // if (index > address.length - 1 && address.length < 2) {
        //   return Column(
        //     children: [
        //       SizedBox(
        //         height: 50.sh(),
        //       ),
        //       Container(
        //         width: MediaQuery.of(context).size.width * .5,
        //         child: CustomElevatedButton(
        //           elevatedButtonText: "Add New Address",
        //           onPressedElevated: () async {
        //             await Navigator.push(
        //                 context,
        //                 MaterialPageRoute(
        //                     builder: (context) => AddressForm(
        //                           edit: false,
        //                         )));
        //             ref.read(locationServiceProvider).clearController();
        //           },
        //         ),
        //       ),
        //     ],
        //   );
        // }

        // if (index > address.length - 1 && address.length == 2) {
        //   return InfoMessage.addresslimitExcceded();
        // }
        if (address.isNotEmpty) {
          if (address[index].fullName.isEmpty) {
            return GestureDetector(
              onTap: () async {
                if (ResponsiveLayout.isMobile) {
                  await Utilities.pushPage(
                      AddressForm(
                        label: address[index].label,
                        edit: false,
                      ),
                      15);
                } else {
                  ResponsiveLayout.setProfileWidget(AddressForm(
                    label: address[index].label,
                    edit: false,
                  ));
                }

                ref.read(locationServiceProvider).clearController();
              },
              child: Container(
                padding: EdgeInsets.all(8.sr()),
                decoration: BoxDecoration(
                    color: CustomTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.sr())),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CustomTheme.primaryColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        index == 0 ? GroceliIcon.home : GroceliIcon.work,
                        color: CustomTheme.primaryColor,
                      ),
                    ),
                    SizedBox(
                      width: 20.sw(),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address[index].label,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text("Set ${address[index].label} address")
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            return SlidableWidget(
              isDetail: true,
              address: address[index],
              child: AddressItemWidget(
                  transparent: false,
                  isDetail: isDetail,
                  isSelected: address[index] ==
                      ref.watch(locationServiceProvider).currentAddress,
                  onSelected: !viewOnly
                      ? null
                      : () {
                          ref.read(locationServiceProvider).currentAddress =
                              address[index];
                          Navigator.pop(context);
                        },
                  item: address[index]),
            );
          }
        }
        return Container();
      },

      //     return SlidableWidget(
      //       isDetail: isDetail,
      //       address: address[index],
      //       child: AddressItemWidget(
      //           transparent: false,
      //           isDetail: isDetail,
      //           isSelected: address[index] ==
      //               ref.watch(locationServiceProvider).currentAddress,
      //           onSelected: !viewOnly
      //               ? null
      //               : () {
      //                   ref.read(locationServiceProvider).currentAddress =
      //                       address[index];
      //                   Navigator.pop(context);
      //                 },
      //           item: address[index]),
      //     );
      //   },
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 15.sh(),
        );
      },
      itemCount: 2,
    );
    // : locationPermission != LocationPermissionEnums.always
    //     ? const Center(
    //         child: Text("No Saved Location"),
    //       )
    //     : Center(
    //         child: InfoMessage.noAddresses(),
    //       );
  }
}
