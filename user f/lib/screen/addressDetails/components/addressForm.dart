// ignore_for_file: must_be_immutable

import 'package:ezdeliver/screen/addressDetails/addresses.dart';
import 'package:ezdeliver/screen/addressDetails/components/addressLabel.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/models/shop.dart';
import 'package:ezdeliver/screen/others/geocoding.dart';
import 'package:ezdeliver/screen/others/validator.dart';
import 'package:ezdeliver/screen/users/model/addressmodel.dart';
import 'package:ezdeliver/screen/yourLocation/yourLocation.dart';

class AddressLabelItem {
  AddressLabelItem({
    required this.label,
    required this.icon,
  });
  final String label;
  final IconData icon;
}

// final landmarkProvider = StateProvider<String>((ref) {
//   return "";
// });
final pinChangeProvider = StateProvider<bool>((ref) {
  return false;
});

class AddressForm extends ConsumerWidget {
  AddressForm(
      {this.edit = false, super.key, this.editAddress, this.label = "home"});
  AddressModel? editAddress;
  bool edit;
  String label;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final List<AddressLabelItem> itemData = [
    AddressLabelItem(label: 'Home', icon: GroceliIcon.home),
    AddressLabelItem(label: 'Work', icon: GroceliIcon.work),
  ];

  // final TextEditingController nameController = TextEditingController();
  // final TextEditingController numberController = TextEditingController();
  // final TextEditingController addressController = TextEditingController();
  final address = AddressModel(
      fullName: "",
      phone: "",
      address: "",
      fullAddress: "",
      label: "",
      location: Location(
        type: "Point",
        coordinates: [87.26, 26.45],
      ));
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // print(ref.read(pinChangeProvider.state).state);
    final locationServiceRead = ref.read(locationServiceProvider);
    if (locationServiceRead.locationDetail == null) {
      locationServiceRead.setCurrentLocation();
    }

    // print("building");
    if (edit && editAddress != null && address.fullAddress == "") {
      address
        ..fullName = editAddress!.fullName
        ..phone = editAddress!.phone
        ..address = editAddress!.address
        ..fullAddress = editAddress!.fullAddress
        ..label = editAddress!.label
        ..location = editAddress!.location
        ..id = editAddress!.id
        ..saved = editAddress!.saved;
    }
    // final locationService = ref.watch(locationServiceProvider);
    final Size size = MediaQuery.of(context).size;
    // final locationService = ref.watch(locationServiceProvider);
    // final permissions = locationService.permissionEnums;
    // if (permissions == LocationPermissionEnums.allowed) {
    //   CustomLocation.determinePosition();
    // }
    // print("here");

    // print(locationService.locationDetail!.displayName.split(",")[0]);

    return Consumer(builder: (context, ref, c) {
      final locationService = ref.watch(locationServiceProvider);
      final permissions = locationService.permissionEnums;
      return SafeArea(
        child: Scaffold(
          appBar: simpleAppBar(context,
              title: edit ? "Edit Address" : "Add New Address",
              search: false, back: () {
            if (!ResponsiveLayout.isMobile) {
              ResponsiveLayout.setProfileWidget(const Addresses());
            }
            locationServiceRead.clearController();
            ref.read(pinChangeProvider.state).state = false;
          }),
          body: permissions != LocationPermissionEnums.always && !edit
              ? Padding(
                  padding: EdgeInsets.only(
                      left: 15.sr(), right: 15.sr(), top: 15.sr()),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50.sh(),
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.sw(), vertical: 10.sh()),
                          child: Center(child: InfoMessage.noLocation())),
                      CustomElevatedButton(
                          onPressedElevated: () {
                            ref.read(locationServiceProvider).currentAddress =
                                null;
                          },
                          elevatedButtonText: "Grant")
                    ],
                  ),
                )
              // Row(
              //   children: [
              //     Text('Saved Location',
              //         style: Theme.of(context)
              //             .textTheme
              //             .bodyText2!
              //             .copyWith(
              //                 color: Colors.black, fontSize: 16.ssp())),
              //     const Spacer(),
              //     Text('Change',
              // style: Theme.of(context)
              //     .textTheme
              //     .bodyText2!
              //     .copyWith(
              //         color: CustomTheme.whiteColor,
              //         fontSize: 14.ssp()))
              //   ],
              // ),
              // SizedBox(
              //   height: 20.sh(),
              // ),
              // : locationService.locationDetail == null && !edit
              //     ? Center(
              //         child: Column(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           const CircularProgressIndicator(
              //             color: CustomTheme.primaryColor,
              //           ),
              //           SizedBox(
              //             height: 15.sh(),
              //           ),
              //           const Text("Fetching Location!!!")
              //         ],
              //       ))
              : Padding(
                  padding: EdgeInsets.all(18.sr()),
                  child: Form(
                    key: formKey,
                    child: ListView(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            var result = await Utilities.pushPage(
                                const YourLocation(
                                  showAddress: false,
                                ),
                                15);

                            //     Navigator.push(context,
                            //         MaterialPageRoute(builder: (context) {
                            //   return const YourLocation(
                            //     showAddress: false,
                            //   );
                            // }));
                            print(result);
                            if (result is CustomAddressData) {
                              Utilities.futureDelayed(10, () {
                                ref.read(pinChangeProvider.notifier).state =
                                    true;
                              });
                              // address.address = locationService
                              //     .locationDetail!.displayName
                              //     .split(",")[0]
                              //     .toString();
                            }
                          },
                          child: CurrentLocationBox(
                            edit: edit,
                            editAddress: edit ? editAddress! : null,
                            onLocationChanged: (val) {
                              address.location = Location(
                                  type: "Point",
                                  coordinates: [
                                    double.parse(val.lon),
                                    double.parse(val.lat)
                                  ]);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 38.sh(),
                        ),
                        InputTextField(
                          controller: edit
                              ? TextEditingController(text: address.fullName)
                              : locationServiceRead.nameController,
                          title: "Full Name *",
                          isVisible: true,
                          onChanged: (val) {
                            address.fullName = val;
                          },
                          validator: (val) => validateName(val!),
                        ),
                        SizedBox(
                          height: 30.sh(),
                        ),
                        InputTextField(
                          controller: edit
                              ? TextEditingController(text: address.phone)
                              : locationServiceRead.phoneController,
                          limit: true,
                          limitNumber: 10,
                          title: "Mobile Number *",
                          isVisible: true,
                          isdigits: true,
                          onChanged: (val) {
                            address.phone = val;
                          },
                          validator: (val) => validatePhone(val!),
                          // isdigits: true,
                          value: address.phone,
                        ),
                        SizedBox(
                          height: 30.sh(),
                        ),
                        Consumer(builder: (context, ref, c) {
                          // String oldValue = address.address;
                          // if (permissions ==
                          //     LocationPermissionEnums.allowed) {
                          //   oldValue = locationService
                          //       .locationDetail!.displayName
                          //       .split(",")[0];
                          // }
                          // final newValue =
                          //     ref.watch(pinChangeProvider.state).state;
                          // final value = !edit
                          //     ? oldValue
                          //     : newValue
                          //         ? ""
                          //         : address.address;
                          final controller =
                              TextEditingController(text: address.address);
                          // print(controller.text);

                          return InputTextField(
                            title: "Landmark & Area Name",
                            isVisible: true,
                            onChanged: (val) {
                              address.address = val;
                            },
                            controller: controller,
                            // value: value,
                            // value:
                            //     // !edit ||
                            //     //         ref.watch(pinChangeProvider.state).state
                            //     //     ? locationService.locationDetail!.displayName
                            //     //         .split(",")[0]
                            //     //     :
                            //     !edit
                            //         ? locationService
                            //             .locationDetail!.displayName
                            //             .split(",")[0]
                            //         : ref.watch(pinChangeProvider.state).state
                            //             ? ""
                            //             : address.address,
                          );
                        }),
                        SizedBox(
                          height: 25.sh(),
                        ),
                        Text('Address Label',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(
                                    color: CustomTheme.getBlackColor(),
                                    fontSize: 16.ssp())),
                        SizedBox(
                          height: 20.sh(),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            height: 100.sh(),
                            width: 100.sw(),
                            child: AddressLabel(
                              icon: label == "Home"
                                  ? itemData[0].icon
                                  : itemData[1].icon,
                              index: label == "Home" ? 0 : 1,
                              label: label == "Home"
                                  ? itemData[0].label
                                  : itemData[1].label,
                            ),
                            // ListView.separated(
                            //     scrollDirection: Axis.horizontal,
                            //     itemBuilder: (context, index) {
                            //       return AddressLabel(
                            //         label: itemData[index].label,
                            //         index: index,
                            //         icon: itemData[index].icon,
                            //       );
                            //     },
                            //     separatorBuilder: (context, index) {
                            //       return SizedBox(
                            //         width: 20.sw(),
                            //       );
                            //     },
                            //     itemCount: itemData.length),
                          ),
                        ),
                        SizedBox(height: 30.sh()),
                        Builder(builder: (context) {
                          // if (validate != null) {
                          //   Future.delayed(Duration(milliseconds: 5), () {
                          //     validate.validate();
                          //   });
                          // }

                          return CustomElevatedButton(
                            onPressedElevated: () async {
                              address
                                ..label = label
                                // itemData[ref
                                //         .watch(addressIndexProvider.state)
                                //         .state]
                                //     .label
                                ..location = Location(
                                    type: "Point",
                                    coordinates: [
                                      locationService.location!.longitude,
                                      locationService.location!.latitude
                                    ])
                                ..fullAddress =
                                    locationService.locationDetail!.displayName;

                              // if (edit) {
                              //   if (ref
                              //           .watch(pinChangeProvider.state)
                              //           .state &&
                              //       address.address == editAddress!.address) {
                              //     address.address = locationService
                              //         .locationDetail!.displayName
                              //         .split(",")[0]
                              //         .toString();
                              //   }
                              // }

                              if (formKey.currentState!.validate()) {
                                if (address.address == "") {
                                  address.address = locationService
                                      .locationDetail!.displayName
                                      .split(",")[0]
                                      .toString();
                                }
                                if (!edit) {
                                  try {
                                    var status = await ref
                                        .read(userChangeProvider)
                                        .addAddress(address: address);
                                    if (status) {
                                      snack
                                          .success("Address added sucessfully");
                                      locationServiceRead.clearController();
                                      await Future.delayed(
                                          const Duration(milliseconds: 1), () {
                                        if (ResponsiveLayout.isMobile) {
                                          Navigator.pop(context);
                                        } else {
                                          ResponsiveLayout.setProfileWidget(
                                              const Addresses());
                                        }
                                      });
                                    }
                                  } catch (e) {
                                    print(e);
                                  }
                                } else {
                                  if (editAddress!.saved) {
                                    try {
                                      var status = await ref
                                          .read(userChangeProvider)
                                          .editAddress(address: address);
                                      if (status) {
                                        snack.success(
                                            "Address edited sucessfully");
                                        locationServiceRead.clearController();
                                        await Future.delayed(
                                            const Duration(milliseconds: 15),
                                            () {
                                          if (ResponsiveLayout.isMobile) {
                                            Navigator.pop(context);
                                          } else {
                                            ResponsiveLayout.setProfileWidget(
                                                const Addresses());
                                          }
                                        });
                                      }
                                    } catch (e) {
                                      print(e);
                                    }
                                  } else {
                                    locationServiceRead.clearController();
                                    Navigator.pop(context);
                                    Utilities.futureDelayed(15, () {
                                      ref
                                          .read(locationServiceProvider)
                                          .currentAddress = address;
                                    });
                                  }
                                }

                                formKey.currentState!.reset();
                                ref.read(pinChangeProvider.state).state = false;
                              }
                            },

                            elevatedButtonText:
                                edit ? "Update" : 'Save & Continue',

                            //     ? pri\ryColor

                            // elevatedButtonTextStyle: Theme.of(context)
                            //     .textTheme
                            //     .bodyText2!
                            //     .copyWith(
                            //         color: Colors.white, fontSize: 14.ssp()),
                            width: size.width - 20.sw(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
        ),
      );
    });
  }
}

class CurrentLocationBox extends StatefulWidget {
  CurrentLocationBox({
    Key? key,
    required this.onLocationChanged,
    this.edit = false,
    this.editAddress,
  }) : super(key: key);
  final Function(CustomAddressData) onLocationChanged;

  bool edit;
  final AddressModel? editAddress;
  @override
  State<CurrentLocationBox> createState() => _CurrentLocationBoxState();
}

class _CurrentLocationBoxState extends State<CurrentLocationBox> {
  @override
  void initState() {
    super.initState();

    // if (!widget.edit) locationService.setCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, c) {
      final locationDetail = ref.watch(locationServiceProvider).locationDetail;
      // print(locationDetail!.lon);
      // if (locationDetail == null) {
      //   ref.read(locationServiceProvider).setCurrentLocation();
      // }

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.19),
            borderRadius: BorderRadius.circular(10.sr())),
        child: !widget.edit || ref.watch(pinChangeProvider.state).state
            ? locationDetail == null
                ? Row(
                    children: [
                      SizedBox(
                        width: 10.sw(),
                      ),
                      SizedBox(
                        height: 10.sh(),
                        width: 10.sw(),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 10.sw(),
                      ),
                      Text("Getting current location ...",
                          style:
                              Theme.of(context).textTheme.bodyText2!.copyWith(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14.ssp(),
                                  ))
                    ],
                  )
                : CurrentLocationDetail(locationDetail: locationDetail)
            : CurrentLocationDetail(
                locationDetail: locationDetail,
                edit: widget.edit,
                editAddress: widget.editAddress,
              ),
      );
    });
  }
}

class CurrentLocationDetail extends StatelessWidget {
  CurrentLocationDetail({
    Key? key,
    this.locationDetail,
    this.edit = false,
    this.editAddress,
  }) : super(key: key);

  CustomAddressData? locationDetail;
  bool edit;
  AddressModel? editAddress;

  @override
  Widget build(BuildContext context) {
    // print(locationDetail!.address.toJson());
    // print(editAddress!.toJson());
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Theme.of(context).primaryColor,
          padding: EdgeInsets.all(2.sr()),
          child: Icon(
            // Icons.abc_outlined,
            GroceliIcon.current_location,
            color: CustomTheme.whiteColor,
            size: 20.ssp(),
          ),
        ),
        SizedBox(
          width: 10.sw(),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // "Address",
                edit
                    ? editAddress!.address
                    : locationDetail!.displayName.split(",")[0],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: CustomTheme.getBlackColor(),
                    fontSize: 14.ssp(),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                edit ? editAddress!.fullAddress : locationDetail!.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(color: CustomTheme.greyColor, fontSize: 14.ssp()),
              )
            ],
          ),
        ),
        SizedBox(
          width: 20.sw(),
        )
      ],
    );
  }
}
