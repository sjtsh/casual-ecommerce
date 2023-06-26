import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/yourLocation/components/setPinOnMap.dart';
import "package:map/map.dart";
import 'package:flutter/gestures.dart';
import 'dart:math';
// ignore: depend_on_referenced_packages

class MapWidget extends ConsumerStatefulWidget {
  const MapWidget({super.key, this.pinMode = false, this.initialCoordinate});
  // final MapController controller;
  final bool pinMode;
  final LatLng? initialCoordinate;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapState();
}

class _MapState extends ConsumerState<MapWidget> {
  late MapController controller;
  bool pinMoving = false;
  @override
  void initState() {
    super.initState();
    final location = ref.read(locationServiceProvider).location;

    controller = MapController(
        location: widget.initialCoordinate != null
            ? widget.initialCoordinate!
            : location != null
                ? LatLng(location.latitude, location.longitude)
                : const LatLng(27.7090319, 85.2911134),
        zoom: 16.5);
    controller.addListener(() {
      setState(() {});
    });
  }

  void _onDoubleTap(MapTransformer transformer, Offset position) {
    const delta = 0.5;
    final zoom = clamp(controller.zoom + delta, 2, 18);

    transformer.setZoomInPlace(zoom, position);
    setState(() {});
  }

  Offset? _dragStart;
  double _scaleStart = 1.0;
  void _onScaleStart(ScaleStartDetails details) {
    setState(() {
      pinMoving = true;
    });
    _dragStart = details.focalPoint;
    _scaleStart = 1.0;
    setState(() {
      pinMoving = false;
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails details, MapTransformer transformer) {
    setState(() {
      pinMoving = true;
    });
    final scaleDiff = details.scale - _scaleStart;
    _scaleStart = details.scale;

    if (scaleDiff > 0) {
      controller.zoom += 0.02;
      setState(() {});
    } else if (scaleDiff < 0) {
      controller.zoom -= 0.02;
      setState(() {});
    } else {
      final now = details.focalPoint;
      final diff = now - _dragStart!;
      _dragStart = now;
      transformer.drag(diff.dx, diff.dy);
      setState(() {});
    }
  }

  // Rect findPoints(LatLng center, double dist, MapTransformer transformer) {
  //   LatLng data;
  //   double distance = 0;
  //   do {
  //     final lon = center.latitude + 0.025;
  //     distance = Geolocator.distanceBetween(
  //         center.latitude, center.longitude, lon, center.longitude);

  //     data = LatLng(lon, center.longitude);
  //   } while (distance <= dist);
  //   var centerOffset = transformer.toOffset(center);
  //   var dataOffset = transformer.toOffset(data);
  //   var finalRect = Rect.fromCircle(
  //       center: centerOffset, radius: (centerOffset.dy - dataOffset.dy).abs());
  //   print(distance);
  //   return finalRect;
  //   // var topleft = transformer.toLatLng(finalRect.topLeft);
  //   // var bottomRight = transformer.toLatLng(finalRect.bottomRight);
  //   // print(distance);
  //   // return [
  //   //   topleft.latitude.toString(),
  //   //   topleft.longitude.toString(),
  //   //   bottomRight.latitude.toString(),
  //   //   bottomRight.longitude.toString()
  //   // ];
  // }

  Rect findBox(LatLng point, double distance, MapTransformer transformer) {
    final diff = 360 * distance / 40075.04;

    final newPoint = LatLng(point.latitude - diff, point.longitude);

    final pointOffset = transformer.toOffset(point);
    final newPointOffset = transformer.toOffset(newPoint);

    final rect = Rect.fromCircle(
        center: pointOffset,
        radius: (pointOffset.dy - newPointOffset.dy).abs());
    return rect;
  }

  List<String> getTwoPointsFromRect(
      LatLng point, double distance, MapTransformer transformer) {
    final rect = findBox(point, distance, transformer);
    final topLeft = transformer.toLatLng(rect.topLeft);
    final bottomRight = transformer.toLatLng(rect.bottomRight);
    return [
      topLeft.latitude.toString(),
      topLeft.longitude.toString(),
      bottomRight.latitude.toString(),
      bottomRight.longitude.toString()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: MapLayout(
          controller: controller,
          builder: (context, transformer) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTapDown: (details) => _onDoubleTap(
                transformer,
                details.localPosition,
              ),
              onScaleStart: _onScaleStart,
              onScaleUpdate: (details) => _onScaleUpdate(details, transformer),
              onScaleEnd: (details) => setState(() {
                pinMoving = false;
              }),
              onTapUp: (details) {
                // final location = transformer.toLatLng(details.localPosition);

                // ref.read(locationServiceProvider).setPinAndLoadData(location);

                //final clicked = transformer.fromLatLngToXYCoords(location);
                //print('${location.longitude}, ${location.latitude}');
                //print('${clicked.dx}, ${clicked.dy}');
                //print('${details.localPosition.dx}, ${details.localPosition.dy}');

                // showDialog(
                //   context: context,
                //   builder: (context) => AlertDialog(
                //     content: Text(
                //         'You have clicked on (${location.longitude}, ${location.latitude}).'),
                //   ),
                // );
              },
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    final delta = event.scrollDelta.dy / -1000.0;
                    final zoom = clamp(controller.zoom + delta, 2, 18);

                    transformer.setZoomInPlace(zoom, event.localPosition);
                    setState(() {});
                  }
                },
                child: Stack(
                  children: [
                    TileLayer(
                      builder: (context, x, y, z) {
                        final tilesInZoom = pow(2.0, z).floor();

                        while (x < 0) {
                          x += tilesInZoom;
                        }
                        while (y < 0) {
                          y += tilesInZoom;
                        }

                        x %= tilesInZoom;
                        y %= tilesInZoom;

                        return CachedNetworkImage(
                          imageUrl: CustomTheme.darkMode
                              ? googleDark(z, x, y)
                              : google(z, x, y),
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    // Center(
                    //     child: Container(
                    //   decoration: BoxDecoration(
                    //     shape: BoxShape.circle,
                    //     color: Colors.blue,
                    //   ),
                    //   width: 3,
                    //   height: 3,
                    // )),

                    if (widget.pinMode) ...[
                      Consumer(builder: (context, ref, child) {
                        // final location =
                        //     ref.watch(locationServiceProvider).location;
                        // if (location == null) {
                        //   final loc =
                        //       LatLng(location.latitude, location.longitude);
                        //   if (controller.center != loc) controller.center = loc;
                        // }

                        return SetPinWidget(
                          pinMoving: pinMoving,
                          size: 30.0,
                          coordinate: controller.center,
                        );
                      }),
                    ],

                    if (!widget.pinMode)
                      Consumer(builder: (context, ref, child) {
                        final location =
                            ref.watch(locationServiceProvider).location;

                        if (location == null) {
                          return Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 15.sr(),
                                  width: 15.sr(),
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                SizedBox(
                                  height: 12.sh(),
                                ),
                                Text(
                                  'Searching ...',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                          color: CustomTheme.getBlackColor()),
                                )
                              ],
                            ),
                          );
                        }

                        final positionLatLng =
                            LatLng(location.latitude, location.longitude);

                        final positionOffset =
                            transformer.toOffset(positionLatLng);
                        Future.delayed(const Duration(milliseconds: 10), () {
                          controller.center = positionLatLng;
                        });
                        return Positioned(
                          left: positionOffset.dx,
                          top: positionOffset.dy,
                          child: Container(
                            width: 14.sr(),
                            height: 14.sr(),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 3,
                                      color: CustomTheme.getBlackColor()
                                          .withOpacity(0.35))
                                ],
                                shape: BoxShape.circle,
                                color: CustomTheme.whiteColor),
                            child: Container(
                              margin: EdgeInsets.all(1.5.sr()),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        );
                      })

                    // CustomPaint(
                    //   painter: BoundPainter(
                    //       findBox(currentLocation!, 5, transformer)),
                    // ),

                    // Positioned(
                    //   // left: 0,
                    //   right: 21.sw(),
                    //   bottom: 180.sh(),
                    //   child: FloatingActionButton(
                    //     mini: true,
                    //     backgroundColor: Theme.of(context).primaryColor,
                    //     onPressed: _gotoDefault,
                    //     tooltip: 'Recenter',
                    //     child: Icon(
                    //       InlineIcon.location_gps,
                    //       size: 40.sr(),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
            );
          },
        ));
  }
}

/// Legal notice: This url is only used for demo and educational purposes. You need a license key for production use.
String google(int z, int x, int y) {
  //Google Maps
  final url =
      'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';

  return url;
}

/// Legal notice: This url is only used for demo and educational purposes. You need a license key for production use.
String googleDark(int z, int x, int y) {
  final url =
      'https://www.google.com/maps/vt?pb=!1m5!1m4!1i$z!2i$x!3i$y!4i256!2m3!1e0!2sm!3i556279080!3m17!2sen-US!3sUS!5e18!12m4!1e68!2m2!1sset!2sRoadmap!12m3!1e37!2m1!1ssmartmaps!12m4!1e26!2m2!1sstyles!2zcC52Om9uLHMuZTpsfHAudjpvZmZ8cC5zOi0xMDAscy5lOmwudC5mfHAuczozNnxwLmM6I2ZmMDAwMDAwfHAubDo0MHxwLnY6b2ZmLHMuZTpsLnQuc3xwLnY6b2ZmfHAuYzojZmYwMDAwMDB8cC5sOjE2LHMuZTpsLml8cC52Om9mZixzLnQ6MXxzLmU6Zy5mfHAuYzojZmYwMDAwMDB8cC5sOjIwLHMudDoxfHMuZTpnLnN8cC5jOiNmZjAwMDAwMHxwLmw6MTd8cC53OjEuMixzLnQ6NXxzLmU6Z3xwLmM6I2ZmMDAwMDAwfHAubDoyMCxzLnQ6NXxzLmU6Zy5mfHAuYzojZmY0ZDYwNTkscy50OjV8cy5lOmcuc3xwLmM6I2ZmNGQ2MDU5LHMudDo4MnxzLmU6Zy5mfHAuYzojZmY0ZDYwNTkscy50OjJ8cy5lOmd8cC5sOjIxLHMudDoyfHMuZTpnLmZ8cC5jOiNmZjRkNjA1OSxzLnQ6MnxzLmU6Zy5zfHAuYzojZmY0ZDYwNTkscy50OjN8cy5lOmd8cC52Om9ufHAuYzojZmY3ZjhkODkscy50OjN8cy5lOmcuZnxwLmM6I2ZmN2Y4ZDg5LHMudDo0OXxzLmU6Zy5mfHAuYzojZmY3ZjhkODl8cC5sOjE3LHMudDo0OXxzLmU6Zy5zfHAuYzojZmY3ZjhkODl8cC5sOjI5fHAudzowLjIscy50OjUwfHMuZTpnfHAuYzojZmYwMDAwMDB8cC5sOjE4LHMudDo1MHxzLmU6Zy5mfHAuYzojZmY3ZjhkODkscy50OjUwfHMuZTpnLnN8cC5jOiNmZjdmOGQ4OSxzLnQ6NTF8cy5lOmd8cC5jOiNmZjAwMDAwMHxwLmw6MTYscy50OjUxfHMuZTpnLmZ8cC5jOiNmZjdmOGQ4OSxzLnQ6NTF8cy5lOmcuc3xwLmM6I2ZmN2Y4ZDg5LHMudDo0fHMuZTpnfHAuYzojZmYwMDAwMDB8cC5sOjE5LHMudDo2fHAuYzojZmYyYjM2Mzh8cC52Om9uLHMudDo2fHMuZTpnfHAuYzojZmYyYjM2Mzh8cC5sOjE3LHMudDo2fHMuZTpnLmZ8cC5jOiNmZjI0MjgyYixzLnQ6NnxzLmU6Zy5zfHAuYzojZmYyNDI4MmIscy50OjZ8cy5lOmx8cC52Om9mZixzLnQ6NnxzLmU6bC50fHAudjpvZmYscy50OjZ8cy5lOmwudC5mfHAudjpvZmYscy50OjZ8cy5lOmwudC5zfHAudjpvZmYscy50OjZ8cy5lOmwuaXxwLnY6b2Zm!4e0';
  return url;
}

double clamp(double x, double min, double max) {
  if (x < min) x = min;
  if (x > max) x = max;

  return x;
}

// class BoundPainter extends CustomPainter {
//   final Rect boundingBox;

//   BoundPainter(this.boundingBox);
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = CustomTheme.primaryColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2;

//     canvas.drawCircle(boundingBox.center,
//         boundingBox.center.dx - boundingBox.centerLeft.dx, paint);
//     // canvas.drawRect(boundingBox, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     // TODO: implement shouldRepaint
//     return false;
//   }
// }
