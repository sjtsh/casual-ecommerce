import 'dart:io';

import 'package:ezdelivershop/Components/Widgets/Button.dart';
import 'package:ezdelivershop/Components/Widgets/ButtonOutline.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../BackEnd/Entities/UploadedImage.dart';
import '../../../../../BackEnd/Services/UploadImageService.dart';
import '../../../../../BackEnd/StaticService/StaticService.dart';
import '../../../../../Components/Constants/ColorPalette.dart';
import '../../../../../Components/Constants/SpacePalette.dart';
import '../../../../../Components/CustomTextField2.dart';
import '../../../../../StateManagement/EditProductManagement.dart';

class RemarksBottomSheetSave extends StatefulWidget {
  final Future<void> Function() onSave;

  RemarksBottomSheetSave({required this.onSave});

  @override
  State<RemarksBottomSheetSave> createState() => _RemarksBottomSheetSaveState();
}

class _RemarksBottomSheetSaveState extends State<RemarksBottomSheetSave> {
  File? url;
  String? uploadedUrl;
  bool disabled = true;
  bool imageUploading = false;

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()=>Future.value(false),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Please add remarks before saving",
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
            SpacePalette.spaceMedium,
            GestureDetector(
              onTap: () async {
                pickImage();
              },
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: context
                                .watch<EditProductManagement>()
                                .isPhotoValidated
                            ? Theme.of(context).primaryColor
                            : Colors.red)),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Stack(
                    children: [
                      Builder(builder: (context) {
                        if (uploadedUrl != null) {

                          return StaticService.cache(uploadedUrl!.replaceAll("localhost", "192.168.1.75"),
                              height: 150, fit: BoxFit.contain);
                        }
                        if (url != null) {
                          return SizedBox(
                              height: 126,
                              width: 126,
                              child: Image.file(url!, fit: BoxFit.cover));
                        }
                        return Container(
                            height: 126,
                            width: 126,
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(.3),
                                borderRadius: BorderRadius.circular(6)),
                            child: const Center(
                              child: Icon(Icons.camera_alt,
                                  size: 48, color: Colors.white),
                            ));
                      }),
                      Positioned(
                          top: 4,
                          right: 4,
                          child: Builder(builder: (context) {
                            if (uploadedUrl != null) {
                              return Icon(Icons.check_circle,
                                  color: ColorPalette.successColor);
                            }
                            if (url != null) {
                              return const SizedBox(
                                  height: 12,
                                  width: 12,
                                  child: CircularProgressIndicator());
                            }
                            return Container();
                          }))
                    ],
                  ),
                ),
              ),
            ),
            SpacePalette.spaceTiny,
            uploadedUrl == null?  TextButton(
              onPressed: (){
                pickImage();
              },
              child: Text("Add Reference Photo",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline),),

            ):TextButton(
              onPressed: (){
                setState(() {
                  uploadedUrl = null;
                  url =null;
                });

              },
              child: Text("Remove", style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline),),

            ),
            SpacePalette.spaceTiny,
            CustomTextField2(
              maxLength: 60,
                labelText: "Remarks",
                maxLines: 2,
                controller: controller,
                onChanged: (String? s) {
                  if (s == null) return;
                  if (s.isEmpty) {
                    setState(() => disabled = true);
                  } else {
                    setState(() => disabled = false);
                  }
                }),
            SpacePalette.spaceMedium,
            Row(
              children: [
                Expanded(
                    child: AppButtonOutline(
                  height: 46,
                  borderRadius: 4,
                  onPressedFunction: () {
                    Navigator.of(context).pop();
                  },
                  text: "Close",
                )),
                SpacePalette.spaceMedium,
                Expanded(
                    child: AppButtonPrimary(
                  isdisable: imageUploading || disabled,
                  onPressedFunction: () async {
                    context.read<EditProductManagement>().remarks =
                        controller.text;
                    context.read<EditProductManagement>().remarksImageUrl =
                        uploadedUrl;
                    await widget.onSave();
                  },
                  text: "Save",
                ))
              ],
            )
          ],
        ),
      ),
    );
  }

  pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera,imageQuality: 10);
    if (image == null) return;
    url = File(image.path);
    setState(() {});
    if(uploadedUrl!=null) {
      uploadedUrl =null;
    }

    imageUploading = true;
    List<UploadedImage> imageUploaded =
        await UploadImageService().uploadOwnerImage([
      UploadableImage(
          image.path,
          "${DateTime.now().toString().replaceAll(":", ".").replaceAll("-", ".").replaceAll(" ", ".")}.jpg",
          "changedShopImage")
    ]);
    if (imageUploaded.isEmpty) url = null;
    uploadedUrl = imageUploaded[0].url;
    imageUploading =false;
    setState(() {});
  }
}
