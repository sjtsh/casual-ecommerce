// import 'dart:math';
// import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
// import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
// import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
// import 'package:ezdelivershop/Components/Widgets/CustomAppBar.dart';
// import 'package:ezdelivershop/Components/Widgets/CustomSafeArea.dart';
// import 'package:ezdelivershop/Components/Widgets/IgnorablePadding.dart';
// import 'package:ezdelivershop/StateManagement/DeliveryRadiusManagement.dart';
// import 'package:ezdelivershop/UI/ProfileScreen/General/Widgets/Warning.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:map/map.dart';
// import 'package:provider/provider.dart';
// import 'package:latlng/latlng.dart';
// import '../../Components/CustomTheme.dart';
// import '../../Components/Widgets/Button.dart';
// import '../../StateManagement/SignInManagement.dart';
//
// class DeliveryRadiusScreen extends StatefulWidget {
//   @override
//   State<DeliveryRadiusScreen> createState() => _DeliveryRadiusScreenState();
// }
//
// class _DeliveryRadiusScreenState extends State<DeliveryRadiusScreen> {
//   final controller = MapController(
//     location: const LatLng(0, 0),
//     zoom: 13.5,
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     controller.center = LatLng(context.read<SignInManagement>().shop!.lat,
//         context.read<SignInManagement>().shop!.lng);
//
//     // context.read<DeliveryRadiusManagement>().radius =
//     //     context.read<SignInManagement>().shop!.deliveryRadius;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     SignInManagement read = context.read<SignInManagement>();
//     SignInManagement watch = context.watch<SignInManagement>();
//     double maxValue = 3000;
//     return CustomSafeArea(
//       child: Scaffold(
//         body: Column(
//           children: [
//             const CustomAppBar(
//               title: "Distance",
//               leftButton: true,
//             ),
//             SpacePalette.spaceMedium,
//             Container(
//               child: Padding(
//                 padding: SpacePalette.paddingExtraLargeH,
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.location_on,
//                             color: ColorPalette.primaryColor),
//                         SpacePalette.spaceTiny,
//                         Expanded(
//                             child: Text(read.shop?.address ?? "",
//                                 style: Theme.of(context).textTheme.headline5))
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             ColumnWithPadding(
//               padding: const EdgeInsets.all(20.0),
//               types: [Slider, Container],
//               children: [
//                 Container(
//                   height: 300,
//                   child: Stack(
//                     clipBehavior: Clip.hardEdge,
//                     alignment: Alignment.center,
//                     children: [
//                       Container(
//                         height: 300,
//                         color: Colors.blueGrey.withOpacity(0.5),
//                         child: MapLayout(
//                           controller: controller,
//                           builder: (context, transformer) {
//                             return TileLayer(
//                               builder: (context, x, y, z) {
//                                 LatLng latlng = transformer.toLatLng(Offset(0, 1));
//                                 LatLng latlng2 = transformer.toLatLng(Offset(0, 0));
//                                 double distance = Geolocator.distanceBetween(latlng.latitude, latlng.longitude, latlng2.latitude, latlng2.longitude);
//                                 final tilesInZoom = pow(2.0, z).floor();
//
//                                 while (x < 0) {
//                                   x += tilesInZoom;
//                                 }
//                                 while (y < 0) {
//                                   y += tilesInZoom;
//                                 }
//
//                                 x %= tilesInZoom;
//                                 y %= tilesInZoom;
//                                 //Google Maps
//                                 final String url =
//                                     'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';
//                                 final String darkUrl =
//                                     'https://maps.googleapis.com/maps/vt?pb=!1m5!1m4!1i$z!2i$x!3i$y!4i256!2m3!1e0!2sm!3i556279080!3m17!2sen-US!3sUS!5e18!12m4!1e68!2m2!1sset!2sRoadmap!12m3!1e37!2m1!1ssmartmaps!12m4!1e26!2m2!1sstyles!2zcC52Om9uLHMuZTpsfHAudjpvZmZ8cC5zOi0xMDAscy5lOmwudC5mfHAuczozNnxwLmM6I2ZmMDAwMDAwfHAubDo0MHxwLnY6b2ZmLHMuZTpsLnQuc3xwLnY6b2ZmfHAuYzojZmYwMDAwMDB8cC5sOjE2LHMuZTpsLml8cC52Om9mZixzLnQ6MXxzLmU6Zy5mfHAuYzojZmYwMDAwMDB8cC5sOjIwLHMudDoxfHMuZTpnLnN8cC5jOiNmZjAwMDAwMHxwLmw6MTd8cC53OjEuMixzLnQ6NXxzLmU6Z3xwLmM6I2ZmMDAwMDAwfHAubDoyMCxzLnQ6NXxzLmU6Zy5mfHAuYzojZmY0ZDYwNTkscy50OjV8cy5lOmcuc3xwLmM6I2ZmNGQ2MDU5LHMudDo4MnxzLmU6Zy5mfHAuYzojZmY0ZDYwNTkscy50OjJ8cy5lOmd8cC5sOjIxLHMudDoyfHMuZTpnLmZ8cC5jOiNmZjRkNjA1OSxzLnQ6MnxzLmU6Zy5zfHAuYzojZmY0ZDYwNTkscy50OjN8cy5lOmd8cC52Om9ufHAuYzojZmY3ZjhkODkscy50OjN8cy5lOmcuZnxwLmM6I2ZmN2Y4ZDg5LHMudDo0OXxzLmU6Zy5mfHAuYzojZmY3ZjhkODl8cC5sOjE3LHMudDo0OXxzLmU6Zy5zfHAuYzojZmY3ZjhkODl8cC5sOjI5fHAudzowLjIscy50OjUwfHMuZTpnfHAuYzojZmYwMDAwMDB8cC5sOjE4LHMudDo1MHxzLmU6Zy5mfHAuYzojZmY3ZjhkODkscy50OjUwfHMuZTpnLnN8cC5jOiNmZjdmOGQ4OSxzLnQ6NTF8cy5lOmd8cC5jOiNmZjAwMDAwMHxwLmw6MTYscy50OjUxfHMuZTpnLmZ8cC5jOiNmZjdmOGQ4OSxzLnQ6NTF8cy5lOmcuc3xwLmM6I2ZmN2Y4ZDg5LHMudDo0fHMuZTpnfHAuYzojZmYwMDAwMDB8cC5sOjE5LHMudDo2fHAuYzojZmYyYjM2Mzh8cC52Om9uLHMudDo2fHMuZTpnfHAuYzojZmYyYjM2Mzh8cC5sOjE3LHMudDo2fHMuZTpnLmZ8cC5jOiNmZjI0MjgyYixzLnQ6NnxzLmU6Zy5zfHAuYzojZmYyNDI4MmIscy50OjZ8cy5lOmx8cC52Om9mZixzLnQ6NnxzLmU6bC50fHAudjpvZmYscy50OjZ8cy5lOmwudC5mfHAudjpvZmYscy50OjZ8cy5lOmwudC5zfHAudjpvZmYscy50OjZ8cy5lOmwuaXxwLnY6b2Zm!4e0&key=AIzaSyAOqYYyBbtXQEtcHG7hwAwyCPQSYidG8yU&token=31440';
//
//                                 return StaticService.cache(
//                                   context.watch<CustomTheme>().isDarkMode
//                                       ? darkUrl
//                                       : url,
//                                   fit: BoxFit.cover,
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                       Center(
//                         child: Container(
//                           height: (watch.shop?.deliveryRadius ?? 0) *0.083618054947676,
//                           width: (watch.shop?.deliveryRadius ?? 0) * 0.083618054947676,
//                           decoration: BoxDecoration(
//                             shape: (watch.shop?.deliveryRadius ?? 0) > 10000
//                                 ? BoxShape.rectangle
//                                 : BoxShape.circle,
//                             color: ColorPalette.primaryColor.withOpacity(0.15),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         height: 300,
//                         width: MediaQuery.of(context).size.width,
//                         child: Align(
//                           alignment: Alignment(
//                             -4 / MediaQuery.of(context).size.width,
//                             -25 / 300,
//                           ),
//                           child: SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: Icon(
//                               Icons.location_on,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 24,
//                 ),
//                 const Warning(
//                     showBorder: true,
//                     infoText:
//                         "You can change your address by changing shop image."),
//                 const SizedBox(
//                   height: 24,
//                 ),
//                 Text(
//                   "Change Delivery Radius (${(watch.shop?.deliveryRadius ?? 0).toStringAsFixed(0)} m)",
//                   style: Theme.of(context).textTheme.headline5,
//                 ),
//                 const SizedBox(
//                   height: 12,
//                 ),
//                 Slider(
//                   divisions: 300,
//                   min: 0,
//                   max: maxValue,
//                   onChangeStart: (fg) {
//                     read.changeRadiusStart(fg);
//                   },
//                   onChangeEnd: (fg) => read.changeRadiusEnd(fg),
//                   onChanged: (v) {
//                     read.changeRadius(v);
//                     context
//                         .read<DeliveryRadiusManagement>()
//                         .changeCircleRadiusStart(v);
//                   },
//                   value: ((radius ?? 0) > maxValue ? maxValue : radius) ?? 0,
//                   inactiveColor: ColorPalette.grey,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text("0 m"),
//                     Text("${maxValue.toStringAsFixed(0)} m")
//                   ],
//                 ),
//               ],
//             ),
//             Expanded(child: Container()),
//             if (kDebugMode)
//               Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: AppButtonPrimary(
//                   onPressedFunction: () {
//                     read.changeRadiusEnd(999999999);
//                   },
//                   text: "Set",
//                   width: double.infinity,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
