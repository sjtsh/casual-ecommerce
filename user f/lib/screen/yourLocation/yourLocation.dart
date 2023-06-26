import 'package:ezdeliver/screen/addressDetails/components/addressList.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/mapScreen/mapScreen.dart';
import 'package:ezdeliver/screen/others/geocoding.dart';
import 'package:ezdeliver/screen/search/searchLocation.dart';
import 'package:ezdeliver/screen/yourLocation/components/locationWidget.dart';

class YourLocation extends ConsumerWidget {
  const YourLocation({this.showAddress = true, super.key});
  final bool showAddress;

  @override
  Widget build(BuildContext context, ref) {
    final locationService = ref.watch(locationServiceProvider);
    final locationPermission = locationService.permissionEnums;

    final selectedAddress = locationService.currentAddress;
    final addressdetail = locationService.locationDetail;
    // final address = ref.watch(userChangeProvider).loggedInUser.value!.address;
    bool show = selectedAddress != null ? false : true;
    // print(addressdetail!.current);
    return SafeArea(
        child: WillPopScope(
      onWillPop: () {
        if (addressdetail != null) {
          return Future.value(true);
        } else {
          return Future.value(false);
        }
      },
      child: Scaffold(
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {},
        //   backgroundColor: Theme.of(context).primaryColor,
        //   child: const Icon(
        //     GroceliIcon.add,
        //     size: 28,
        //   ),
        // ),
        appBar: simpleAppBar(context,
            title: "Location", search: false, close: false),
        body: Padding(
          padding: EdgeInsets.only(left: 15.sr(), right: 15.sr(), top: 15.sr()),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // TextFormField(
              //   readOnly: true,
              //   decoration: InputDecoration(
              //       hintText: "Search For New Location ...",
              //       prefixIcon: Icon(
              //         Icons.search,
              //         size: 28.sr(),
              //       ),
              //       focusedBorder: OutlineInputBorder(
              //           borderSide:
              //               BorderSide(color: Theme.of(context).primaryColor),
              //           gapPadding: 0),
              //       enabledBorder: const OutlineInputBorder(
              //           borderSide: BorderSide(color: CustomTheme.greyColor),
              //           gapPadding: 0)),
              // ),
              // SizedBox(
              //   height: 42.sh(),
              // ),
              // if (ref.watch(locationServiceProvider).permissionEnums !=
              //     LocationPermissionEnums.always)
              //   Builder(builder: (context) {
              //     return Column(
              //       children: [Text("Location")],
              //     );
              //   })
              InkWell(
                onTap: () {
                  showSearch(
                      context: context,
                      delegate: CustomLocationSerachDelegate());
                },
                child: Container(
                    margin: EdgeInsets.only(bottom: 22.sh()),
                    height: kBottomNavigationBarHeight * 0.75,
                    child: const CustomSearchField(
                      label: "Address",
                    )),
              ),

              Builder(builder: (context) {
                // final selectedAddress =
                //     ref.watch(locationServiceProvider).currentAddress;

                // print(locationPermission);
                if (locationPermission == LocationPermissionEnums.always) {
                  List<String>? address = addressdetail?.displayName.split(",");

                  return LocationWidget(
                      address: addressdetail != null && show
                          ? address!.length > 1
                              ? address[1]
                              : address.first
                          : null,
                      show:
                          addressdetail != null ? addressdetail.current : false,
                      onTap: () {
                        ref.read(locationServiceProvider).currentAddress = null;
                        Navigator.pop(context);
                      },
                      icon: GroceliIcon.current_location,
                      header: 'Use my current location');
                } else {
                  return Column(
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.sw(), vertical: 10.sh()),
                          child: Center(child: InfoMessage.noLocation())),
                      SizedBox(
                        height: 10.sh(),
                      ),
                      CustomElevatedButton(
                          onPressedElevated: () {
                            ref.read(locationServiceProvider).currentAddress =
                                null;
                          },
                          elevatedButtonText: "Grant Permission")
                    ],
                  );
                }
              }),
              SizedBox(
                height: 22.sh(),
              ),
              LocationWidget(
                  address: addressdetail != null && show
                      ? addressdetail.displayName.split(",").isNotEmpty
                          ? addressdetail.displayName.split(",").first
                          : null
                      : null,
                  show: addressdetail != null
                      ? addressdetail.current
                          ? false
                          : true
                      : false,
                  onTap: () async {
                    var locationService = ref.read(locationServiceProvider);
                    // locationService.locationDetail;
                    if (locationService.currentAddress != null) {
                      ref.read(locationServiceProvider).currentAddress = null;
                      locationService.setCurrentLocation(current: false);
                    }
                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const MapScreen();
                        },
                      ),
                    );
                    if (!showAddress) {
                      if (result is CustomAddressData) {
                        Utilities.futureDelayed(10, () {
                          Navigator.pop(context, result);
                        });
                      }
                    } else {
                      if (result != null) {
                        Utilities.futureDelayed(20, () {
                          Navigator.pop(context);
                        });
                      }
                    }
                  },
                  icon: GroceliIcon.set_pin,
                  header: "Set Pin On Map"),
              SizedBox(
                height: 30.sh(),
              ),
              // const Expanded(child: AbsorbPointer(child: MapWidget()))
              // if (address.isNotEmpty &&
              //     locationPermission == LocationPermissionEnums.always)

              if (showAddress) ...[
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Saved Location",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: CustomTheme.getBlackColor()),
                  ),
                ),
                SizedBox(
                  height: 15.sh(),
                ),
                const Expanded(
                  child: AddressList(
                    viewOnly: true,
                  ),
                ),
                SizedBox(
                  height: 15.sh(),
                ),
              ],
            ],
          ),
        ),
      ),
    ));
  }
}
