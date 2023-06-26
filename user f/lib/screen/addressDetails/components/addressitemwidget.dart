// ignore_for_file: prefer_const_constructors

import 'package:ezdeliver/screen/addressDetails/components/addressForm.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/users/model/addressmodel.dart';

class AddressItemWidget extends StatelessWidget {
  const AddressItemWidget(
      {Key? key,
      required this.item,
      this.onSelected,
      this.isSelected = false,
      this.click = true,
      this.isDetail = false,
      this.showIcon = true,
      this.transparent = true})
      : super(key: key);

  final AddressModel item;
  final Function? onSelected;
  final bool isSelected, click, isDetail, showIcon, transparent;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onLongPress: () {},
      onTap: () async {
        // print("object");
        if (click) {
          if (onSelected == null) {
            if (item.saved) {
              if (ResponsiveLayout.isMobile) {
                Utilities.pushPage(
                    AddressForm(
                      edit: true,
                      editAddress: item,
                      label: item.label,
                    ),
                    15);
              } else {
                ResponsiveLayout.setProfileWidget(AddressForm(
                  edit: true,
                  editAddress: item,
                  label: item.label,
                ));
              }
              // await Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => AddressForm(
              //               edit: true,
              //               editAddress: item,
              //               label: item.label,
              //             )));
              CustomKeys.ref.read(locationServiceProvider).clearController();
            }
          } else {
            onSelected!();
          }
        }
      },
      child: Container(
        padding: !transparent
            ? EdgeInsets.symmetric(horizontal: 7.sw(), vertical: 12.sh())
            : null,
        margin: !transparent
            ? !showIcon
                ? EdgeInsets.zero
                : EdgeInsets.only(left: 15.sw(), right: 15.sw(), top: 15.sh())
            : null,
        decoration: !showIcon
            ? null
            : BoxDecoration(
                border: transparent
                    ? null
                    : Border.all(
                        color: isSelected && onSelected != null
                            ? Theme.of(context).primaryColor
                            : Colors.transparent),
                borderRadius: BorderRadius.circular(8.sr()),
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: transparent
                    ? []
                    : [
                        BoxShadow(
                            offset: const Offset(4, 4),
                            blurRadius: 14,
                            color: CustomTheme.blackColor.withOpacity(0.05))
                      ],
              ),
        child: Column(
          children: [
            if (isDetail && item.fullName.isNotEmpty) ...[
              Row(
                children: [
                  Text(item.fullName,
                      style: Theme.of(context).textTheme.bodyText2),
                  const Spacer(),
                  Text(item.phone,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .copyWith(color: Theme.of(context).primaryColor))
                ],
              ),
              SizedBox(
                height: 12.sh(),
              )
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isDetail && showIcon) ...[
                  Container(
                    color: Theme.of(context).primaryColor,
                    padding: EdgeInsets.all(2.sr()),
                    child: const Icon(
                      GroceliIcon.location,
                      color: CustomTheme.whiteColor,
                    ),
                  ),
                  SizedBox(
                    width: 22.sw(),
                  ),
                ],
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.address.isNotEmpty) ...[
                        Text(
                          item.address,
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                        SizedBox(
                          height: 6.sh(),
                        ),
                      ],
                      Text(
                        item.fullAddress,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(color: CustomTheme.greyColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                if (item.label.isNotEmpty)
                  Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 5.sr(),
                            backgroundColor: item.label.toLowerCase() == "home"
                                ? CustomTheme.homeColor
                                : CustomTheme.workColor,
                          ),
                          SizedBox(
                            width: 4.sw(),
                          ),
                          Text(item.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(color: CustomTheme.greyColor)),
                        ],
                      ))
              ],
            ),
          ],
        ),

        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
        //   children: [
        //     Expanded(
        //       flex: 1,
        //       child: Column(
        //         children: [
        //           Container(
        //               margin: EdgeInsets.symmetric(horizontal: 10.sw()),
        //               padding: EdgeInsets.symmetric(
        //                 vertical: 4.sh(),
        //                 // horizontal: 6.sw()
        //               ),
        //               decoration: BoxDecoration(
        //                 color: CustomTheme.whiteColor,
        //                 borderRadius: BorderRadius.circular(8.sr()),
        //                 boxShadow: [
        //                   BoxShadow(
        //                       offset: const Offset(0, 4),
        //                       blurRadius: 2,
        //                       color: CustomTheme.greyColor.withOpacity(0.4))
        //                 ],
        //               ),
        //               child: Center(
        //                   child: item.label.toLowerCase() == "home"
        //                       ? const Icon(
        //                           Icons.home,
        //                           color: CustomTheme.whiteColor,
        //                         )
        //                       : const Icon(
        //                           Icons.work,
        //                           color: CustomTheme.whiteColor,
        //                         ))),
        //           SizedBox(
        //             height: 4.sh(),
        //           ),
        //           Text(
        //             item.label,
        //             style: Theme.of(context).textTheme.bodyText2!.copyWith(
        //                 fontSize: 14.ssp(), color: CustomTheme.blackColor),
        //             textAlign: TextAlign.center,
        //           ),
        //         ],
        //       ),
        //     ),
        //     SizedBox(
        //       width: 10.sw(),
        //     ),
        //     Expanded(
        //       flex: 5,
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           Row(children: [
        //             Text(
        //               item.fullName,
        //               style: Theme.of(context).textTheme.bodyText2!.copyWith(
        //                   fontSize: 18.ssp(), color: CustomTheme.blackColor),
        //             ),
        //             const Spacer(),
        //             if (click)
        //               Consumer(builder: (context, ref, c) {
        //                 return IconButton(
        //                     onPressed: () {
        //                       showDialog(
        //                           context: context,
        //                           builder: (context) {
        //                             return CustomDialog(
        //                                 textSecond: "delete this address?",
        //                                 elevatedButtonText: "Delete",
        //                                 onPressedElevated: () {
        //                                   ref
        //                                       .read(userChangeProvider)
        //                                       .deleteAddress(id: item.id!);
        //                                   snack.success("Address deleted");
        //                                 });
        //                           });
        //                     },
        //                     icon: const Icon(
        //                       Icons.delete,
        //                       color: CustomTheme.whiteColor,
        //                     ));
        //               })
        //           ]),
        //           Text(
        //             item.phone,
        //             style: Theme.of(context).textTheme.bodyText2!.copyWith(
        //                 fontSize: 16.ssp(), color: CustomTheme.blackColor),
        //           ),
        //           SizedBox(
        //             height: 4.sh(),
        //           ),
        //           Row(
        //             children: [
        //               Text(item.address,
        //                   style: Theme.of(context)
        //                       .textTheme
        //                       .bodyText2!
        //                       .copyWith(fontSize: 16.ssp())),
        //             ],
        //           ),
        //           SizedBox(
        //             height: 4.sh(),
        //           ),
        //           Text(
        //             item.fullAddress,
        //             maxLines: 2,
        //             overflow: TextOverflow.ellipsis,
        //             style: Theme.of(context).textTheme.bodyText2!,
        //           ),
        //         ],
        //       ),
        //     ),
        //   ],
        // )),
      ),
    );
  }
}
