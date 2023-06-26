import 'dart:io';
import 'package:camera/camera.dart';
import 'package:ezdelivershop/BackEnd/Entities/UploadedImage.dart';
import 'package:ezdelivershop/BackEnd/Services/ShopService.dart';
import 'package:ezdelivershop/BackEnd/Services/UploadImageService.dart';
import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/Components/Widgets/Button.dart';
import 'package:ezdelivershop/Components/Widgets/ButtonOutline.dart';
import 'package:ezdelivershop/Components/snackbar/customsnackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Components/Constants/ColorPalette.dart';
import '../../Components/CustomTheme.dart';

class UploadingImageDialog extends StatefulWidget {
  final XFile xFile;

  UploadingImageDialog(this.xFile);

  @override
  State<UploadingImageDialog> createState() => _UploadingImageDialogState();
}

class _UploadingImageDialogState extends State<UploadingImageDialog> {
  String? imageUrl;
  // Position? position;
  bool finale = false;
  String? errorText;
  TextEditingController locationController = TextEditingController();
  TextEditingController fetchingController = TextEditingController(text: "Getting location");

  // @override
  // void initState() {
  //   super.initState();
  //   getLocation();
  // }

  // getLocation() async {
  //   position = await Geolocator.getCurrentPosition();
  //   try {
  //     if (position != null) {
  //     List<Placemark> placeMarks = await placemarkFromCoordinates(
  //         position!.latitude, position!.longitude);
  //       locationController.text =
  //           "${placeMarks[0].subLocality}, ${placeMarks[0].locality}, ${placeMarks[0].administrativeArea}";
  //     }
  //   } catch (e) {
  //     CustomSnackBar().error("Could not access your location");
  //   }
  //   setState(() {
  //
  //     finale = true;
  //   });
  // }

  Future<String?> upload() async {
    List<UploadedImage> image = await UploadImageService().uploadOwnerImage([
      UploadableImage(
          widget.xFile.path,
          "${DateTime.now()
              .toString()
              .replaceAll(":", ".")
              .replaceAll("-", ".")
              .replaceAll(" ", ".")}.jpg",
          "changedShopImage")
    ]);
    if (image.isEmpty) {
      Navigator.pop(context);
      CustomSnackBar().error("Image could not be uploaded");
      return null;
    }
    imageUrl = image[0].url;
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            color: context.watch<CustomTheme>().isDarkMode
                ? ColorPalette.darkContainerColor
                : Colors.white,
            borderRadius: BorderRadius.circular(6)),
        height: 450,
        width: 400,
        child: Padding(
          padding: SpacePalette.paddingExtraLarge,
          child: Column(
            children: [
              Expanded(
                  child: Container(
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.black.withOpacity(0.5)),
                          image: DecorationImage(
                              image: FileImage(File(
                                widget.xFile.path,
                              )),
                              fit: BoxFit.cover)))),
              SpacePalette.spaceExtraLarge,
              // finale?
              //   TextField(
              //     controller: locationController,
              //     decoration: InputDecoration(
              //         labelText: "Address", errorText: errorText),
              //   )
              //     :Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //   const  SizedBox(height:24, width:24,child: CircularProgressIndicator()),
              //     SpacePalette.spaceExtraLarge,
              //     Text("Getting location", style: Theme.of(context).textTheme.headline5,)
              //   ],
              // ),
              SpacePalette.spaceExtraLarge,
              Row(
                children: [
                  Expanded(
                      child: AppButtonOutline(
                    onPressedFunction: () {
                      Navigator.pop(context, false);
                    },
                    text: "Retake",
                    borderRadius: 0,
                    height: 46,
                  )),
                  SpacePalette.spaceExtraLarge,
                  Expanded(
                      child: AppButtonPrimary(
                          onPressedFunction: () async {
                            String? url = await upload();
                            if (url == null) return;

                              bool success = await ShopService()
                                  .changeShopImage(
                                      imageUrl!,
                                      locationController.text.trim());
                              if (success) {

                                CustomSnackBar().error("Function not written");
                              } else {
                                CustomSnackBar().error("Please try again");
                              }

                          },
                          text: "Confirm")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
// Future checkLocationService(BuildContext context) async {
//   try {
//     if (await Geolocator.checkPermission() != LocationPermission.denied) {
//       position=
//       await Geolocator.getCurrentPosition();
//       if (position != null) {
//         List<Placemark> placeMarks = await placemarkFromCoordinates(
//             read.position!.latitude, read.position!.longitude);
//         read.addressController.text =
//         "${placeMarks[0].street}, ${placeMarks[0].locality}";
//       }
//     } else {
//       CustomSnackBar().error("Could not access your position");
//     }
//   } catch (E) {
//     print("e");
//   }
// }
}
