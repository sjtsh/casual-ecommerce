import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
import 'package:camera/camera.dart';
import 'package:ezdelivershop/Components/snackbar/customsnackbar.dart';
import 'package:ezdelivershop/StateManagement/SignUpAndCameraManagement.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class PersonalCameraPreview extends StatefulWidget {
 final  bool isToChangeImage;
 PersonalCameraPreview({this.isToChangeImage = false});
  @override
  State<PersonalCameraPreview> createState() => _PersonalCameraPreviewState();
}

class _PersonalCameraPreviewState extends State<PersonalCameraPreview> {
  CameraController? cameraController;
  List<CameraDescription> cameras = [];
  bool isBackCamera = false;
  int current = 0;
  bool disabled = false;
  bool isFlashOn = false;

  bool showFocusCircle = false;
  double x = 0;
  double y = 0;

  @override
  void initState() {
    super.initState();
    context.read<SignUpAndCameraManagement>().isShotTaken = false;
    initializeCameras();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null) {
      return buildProcessingWidget();
    }
    return Scaffold(
      body: GestureDetector(
        onTapUp: (details) {
          _onTap(details);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              height: MediaQuery.of(context).size.height,
              child: CameraPreview(
                cameraController!,
              ),
            ),
            Positioned(
              bottom: 12,
              child: buildTakePhotoButton(context),
            ),
            Positioned(
              top: 48,
              right: 12,
              child: buildFlashButton(),
            ),
            if (showFocusCircle)
              Positioned(
                  top: y - 20,
                  left: x - 20,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5)),
                  )),
            buildBackButton()
          ],
        ),
      ),
    );
  }

  initializeCameras() async {
    cameras = await availableCameras();
    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.max,
    );
    await cameraController?.initialize();
    cameraController?.setFlashMode(FlashMode.off);

    setState(() {});
  }

  Widget buildBackButton() {
    return Positioned(
      top: 48,
      left: 12,
      child: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          )),
    );
  }

  Widget buildProcessingWidget() {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildTakePhotoButton(BuildContext context, {int? rotateTurn}) {
    return GestureDetector(
      onTap: () async {
        SignUpAndCameraManagement read =
            context.read<SignUpAndCameraManagement>();
        context.read<SignUpAndCameraManagement>().shot();
        if (cameraController != null) {
          try {
            cameraController!.takePicture().then((XFile? a) {
              Navigator.pop(context, rotateTurn == null ? a : [a, rotateTurn]);
            });
          } catch (E) {
            if (kDebugMode) {
              print(E);
            }
          }
          if(!widget.isToChangeImage){
            await checkLocationService(context);
          }
        }

        read.shot();
      },
      child: Container(
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 50,
            width: 50,
            decoration: !context.watch<SignUpAndCameraManagement>().isShotTaken
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: ColorPalette.pinkBackground, width: 2))
                : null,
            child: !context.watch<SignUpAndCameraManagement>().isShotTaken
                ? null
                : const CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
          ),
        ),
      ),
    );
  }

  Widget buildFlashButton() {
    return SizedBox(
        // height: 50,
        child: IconButton(
            onPressed: () {
              setState(() {
                isFlashOn = !isFlashOn;
              });
              if (isFlashOn) {
                cameraController?.setFlashMode(FlashMode.always);
              } else {
                cameraController?.setFlashMode(FlashMode.off);
              }
            },
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            )));
  }

  Widget buildRotateDeviceWidget() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Stack(
        children: [
          Positioned(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              child: CameraPreview(
                cameraController!,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    color: Colors.black,
                    child: const Text(
                      "Please Rotate your device",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              )),
          buildBackButton(),
        ],
      );
    });
  }

  Future<void> _onTap(TapUpDetails details) async {
    if (cameraController!.value.isInitialized) {
      x = details.localPosition.dx;
      y = details.localPosition.dy;

      double fullWidth = MediaQuery.of(context).size.width;
      double cameraHeight = fullWidth * cameraController!.value.aspectRatio;

      double xp = x / fullWidth;
      double yp = y / cameraHeight;

      Offset point = Offset(xp, yp);

      // Manually focus
      await cameraController?.setFocusPoint(point);

      // Manually set light exposure
      //controller.setExposurePoint(point);
    }
  }

  Future checkLocationService(BuildContext context) async {
    try {
      SignUpAndCameraManagement read =
          context.read<SignUpAndCameraManagement>();
      if (await Geolocator.checkPermission() != LocationPermission.denied) {
        context.read<SignUpAndCameraManagement>().position =
            await Geolocator.getCurrentPosition();
        if (read.position != null) {
          List<Placemark> placeMarks = await placemarkFromCoordinates(
              read.position!.latitude, read.position!.longitude);
          read.addressController.text =
              "${placeMarks[0].subLocality}, ${placeMarks[0].locality}, ${placeMarks[0].administrativeArea}";
        }
      } else {
        CustomSnackBar().error("Could not access your position");
      }
    } catch (E) {
      if (kDebugMode) {
        print("e");
      }
    }
  }
}
