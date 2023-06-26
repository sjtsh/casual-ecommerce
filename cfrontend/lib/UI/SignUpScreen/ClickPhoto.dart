import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:ezdelivershop/UI/SignUpScreen/CameraPreview.dart';
import 'package:ezdelivershop/StateManagement/SignUpAndCameraManagement.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../BackEnd/Entities/UploadedImage.dart';
import '../../BackEnd/Services/UploadImageService.dart';
import '../../Components/Constants/ColorPalette.dart';
import '../../Components/snackbar/customsnackbar.dart';

class ClickPhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SignUpAndCameraManagement watch =
        context.watch<SignUpAndCameraManagement>();
    return GestureDetector(
      onTap: () async {
        SignUpAndCameraManagement read =
            context.read<SignUpAndCameraManagement>();
        NavigatorState navigatorState = Navigator.of(context);
        XFile? imagePath =
            await navigatorState.push(MaterialPageRoute(builder: (_) {
          return PersonalCameraPreview();
        }));
        context.read<SignUpAndCameraManagement>().unFocusAll();
        if (imagePath == null) return;
        read.shopImage = File(imagePath.path);
        read.photoValidation();
          read.position = await Geolocator.getCurrentPosition();
        try {
          if(read.position!=null){
            List<Placemark> placeMarks = await placemarkFromCoordinates(
                read.position!.latitude, read.position!.longitude);
            read.addressController.text =
                "${placeMarks[0].subLocality}, ${placeMarks[0].locality}, ${placeMarks[0].administrativeArea}";
          }
        } catch (e) {
          CustomSnackBar().error("Could not access your location");
        }
        try {
          context.read<SignUpAndCameraManagement>().imageUploading =
              UploadImageService().uploadOwnerImage([
            UploadableImage(
                read.shopImage?.path,
                "${DateTime.now().toString().replaceAll("-", ".").replaceAll(":", ".").replaceAll(" ", ".")}.jpg",
                "shop_image")
          ]).then((value) {
            read.shopImageUploadedUrl = value.first.url;
            return value;
          });
        } catch (e) {
          CustomSnackBar().error("Could not upload the image");
        }
        // if (res.statusCode != 200) throw "try again";
        // // Map<String, dynamic> parsable = jsonDecode(res.body);
        // //
        // // return parsable.entries
        // //     .map((entry) => UploadedImage(entry.value, entry.key))
        // //     .toList();
        // print("level 6");
        // if (uploadedImages.isEmpty) {
        //   return CustomSnackBar().error("The image could not be uploaded");
        // }
        // print("level 7");
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                width: watch.isPhotoValidated ? 1 : 2,
                color: watch.isPhotoValidated
                    ? ColorPalette.primaryColor
                    : Colors.red,
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Center(
                    child: DottedBorder(
                      dashPattern: [16, 55, 48, 151, 48, 55, 48, 151, 40],
                      borderType: BorderType.RRect,
                      radius: Radius.circular(8),
                      color: ColorPalette.primaryColor,
                      child: SizedBox(
                        height: 100,
                        width: 200,
                        child: watch.shopImage != null
                            ? Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Center(
                                    child: Stack(
                                  children: [
                                    Image.file(
                                      context
                                          .watch<SignUpAndCameraManagement>()
                                          .shopImage!,
                                      fit: BoxFit.cover,
                                      height: 100,
                                      width: 200,
                                    ),
                                    FutureBuilder(
                                        future: context
                                                .watch<
                                                    SignUpAndCameraManagement>()
                                                .imageUploading ??
                                            Future.value(0),
                                        builder:
                                            (context, AsyncSnapshot snapshot) {
                                          if (snapshot.hasData) {
                                            return Container();
                                          }
                                          return Container(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        }),
                                  ],
                                )),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Text("Click Photo Of Your Shop"),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          watch.isPhotoValidated
              ? Container()
              : const Padding(
                  padding: EdgeInsets.only(
                    left: 18.0,
                    top: 9.0,
                  ),
                  child: Text(
                    "Click a photo",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
