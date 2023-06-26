import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/others/geocoding.dart';

class SetPinWidget extends ConsumerWidget {
  SetPinWidget({
    Key? key,
    required this.pinMoving,
    required this.size,
    required this.coordinate,
    this.log = false,
  }) : super(key: key);

  final bool pinMoving;
  final bool log;
  final double size;
  final LatLng coordinate;

  final customAddressDataProvider = StateProvider<CustomAddressData?>((ref) {
    return;
  });
  @override
  Widget build(BuildContext context, ref) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.bounceInOut,
      top: pinMoving ? -size * 1.5 : -size * .8,
      left: 0,
      right: 0,
      bottom: 0,
      child: Stack(
        children: [
          Positioned.fill(
            bottom: -size * .9,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: pinMoving ? 0 : 0.65,
              child: Transform.scale(
                scale: 0.025,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            spreadRadius: 15,
                            blurRadius: 300)
                      ]),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Icon(
              Icons.push_pin,
              color: Theme.of(context).primaryColor,
              size: size,
            ),
          ),
          Positioned.fill(
              top: -size * 2 - 15.sr(),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: pinMoving ? 0 : 0.95,
                child: GestureDetector(
                  onTap: () async {
                    if (log) {
                      await FirebaseAnalytics.instance
                          .logEvent(name: "SET_pin_Text", parameters: {
                        "id":
                            ref.read(userChangeProvider).loggedInUser.value?.id,
                        "name": ref
                            .read(userChangeProvider)
                            .loggedInUser
                            .value
                            ?.name
                      });
                    }
                  },
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10.sr()),
                      decoration: BoxDecoration(
                          color: CustomTheme.greyColor,
                          borderRadius: BorderRadius.circular(6.sr())),
                      // width: 100,
                      // height: 200,

                      child: FutureBuilder(
                          future: pinMoving
                              ? Future.value(null)
                              : CustomLocation.getAddressFromLocation(
                                  current: false,
                                  location: CustomLocation.emptyPosition(
                                      latlng: coordinate)),
                          builder: (context, snapshot) {
                            var loading = SizedBox(
                              width: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .fontSize!
                                  .ssp(),
                              height: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .fontSize!
                                  .ssp(),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            );
                            var textStyle = Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(color: Colors.white);
                            if (snapshot.hasError) {
                              return Text(
                                "Try again",
                                style: textStyle,
                              );
                            }
                            if (snapshot.hasData) {
                              if (snapshot.data == null) {
                                return Text(
                                  "Try again",
                                  style: textStyle,
                                );
                              }

                              var address =
                                  snapshot.data!.displayName.split(",");

                              if (address.isNotEmpty) {
                                Utilities.futureDelayed(10, () {
                                  ref
                                      .read(customAddressDataProvider.state)
                                      .state = snapshot.data;
                                });
                                return Text(
                                  "${address[0]},${address.length > 1 ? address[1] : ""}",
                                  style: textStyle,
                                );
                              }
                            }

                            return loading;
                          }),
                    ),
                  ),
                ),
              )),
          Builder(builder: (context) {
            final data = ref.watch(customAddressDataProvider);
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
              bottom: pinMoving ? -200 : 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(12.sr()),
                // color: Theme.of(context).primaryColor,
                child: Center(
                    child: CustomElevatedButton(
                  onPressedElevated: data != null
                      ? () {
                          ref.read(locationServiceProvider).setCurrentLocation(
                              current: false,
                              location: CustomLocation.emptyPosition(
                                  latlng: coordinate),
                              addressData: data);
                          Utilities.futureDelayed(50, () {
                            Navigator.pop(context, data);
                          });
                        }
                      : null,
                  elevatedButtonText: "Set Pin",
                )),
              ),
            );
          })
        ],
      ),
    );
  }
}
