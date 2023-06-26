// ignore_for_file: prefer_const_constructors

import 'package:ezdeliver/screen/addressDetails/components/addressForm.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/users/model/addressmodel.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidableWidget extends StatelessWidget {
  const SlidableWidget(
      {super.key,
      required this.child,
      this.isDetail = false,
      required this.address});
  final Widget child;
  final bool isDetail;
  final AddressModel address;
  @override
  Widget build(BuildContext context) {
    return Slidable(
        // Specify a key if the Slidable is dismissible.
        key: const ValueKey(0),

        // The start action pane is the one at the left or the top side.

        // The end action pane is the one at the right or the bottom side.
        endActionPane: ActionPane(
          extentRatio: isDetail ? 0.15 : 0.3,
          motion: ScrollMotion(),
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return CustomDialog(
                          textSecond: "delete this address?",
                          elevatedButtonText: "Delete",
                          onPressedElevated: () {
                            CustomKeys.ref
                                .read(userChangeProvider)
                                .deleteAddress(id: address.id!);
                            snack.success("Address deleted");
                          });
                    });
              },
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withOpacity(0.19)),
                child: Icon(
                  GroceliIcon.delete,
                  color: Theme.of(context).primaryColor,
                  size: 40.sr(),
                ),
              ),
            ),

            // SlidableAction(
            //   // An action can be bigger than the others.
            //   borderRadius: BorderRadius.circular(24.sr()),
            //   onPressed: (context) {
            //     showDialog(
            //         context: context,
            //         builder: (context) {
            //           return CustomDialog(
            //               textSecond: "delete this address?",
            //               elevatedButtonText: "Delete",
            //               onPressedElevated: () {
            //                 // ref
            //                 //     .read(userChangeProvider)
            //                 //     .deleteAddress(id: item.id!);
            //                 // snack.success("Address deleted");
            //               });
            //         });
            //   },
            //   backgroundColor: Theme.of(context).primaryColor.withOpacity(0.19),
            //   foregroundColor: Theme.of(context).primaryColor,
            //   icon: GroceliIcon.delete,
            //   // label: 'Delete',
            // ),
            SizedBox(
              width: 18,
            ),

            if (!isDetail)
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddressForm(
                                edit: true,
                                editAddress: address,
                              )));
                  CustomKeys.ref
                      .read(locationServiceProvider)
                      .clearController();
                },
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomTheme.successColor.withOpacity(0.19)),
                  child: Icon(
                    GroceliIcon.edit,
                    color: CustomTheme.successColor,
                    size: 40.sr(),
                  ),
                  // SlidableAction(
                  //   borderRadius: BorderRadius.circular(24.sr()),
                  //   onPressed: null,
                  //   backgroundColor: CustomTheme.successColor.withOpacity(0.19),
                  //   foregroundColor: CustomTheme.successColor,
                  //   icon: GroceliIcon.edit,
                  //   // label: 'Edit',
                  // ),
                ),
              ),
          ],
        ),

        // The child of the Slidable is what the user sees when the
        // component is not dragged.
        child: child);
  }
}
