import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:ezdelivershop/BackEnd/Entities/SearchProduct.dart';
import 'package:ezdelivershop/BackEnd/StaticService/StaticService.dart';
import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/Components/CustomTextField2.dart';
import 'package:ezdelivershop/Components/Widgets/Button.dart';
import 'package:ezdelivershop/Components/Widgets/ButtonOutline.dart';
import 'package:ezdelivershop/Components/Widgets/CustomAppBar.dart';
import 'package:ezdelivershop/Components/Widgets/CustomSafeArea.dart';
import 'package:ezdelivershop/StateManagement/EditProductManagement.dart';
import 'package:ezdelivershop/StateManagement/NotSearchingProductManagement.dart';
import 'package:ezdelivershop/StateManagement/SearchingProductManagement.dart';
import 'package:ezdelivershop/UI/DialogBox/customdialogbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../BackEnd/Entities/MyProduct.dart';
import '../../../../Components/CustomTheme.dart';
import '../../../../StateManagement/DeliveryRadiusManagement.dart';
import 'BarCodeScanner.dart';
import 'Widgets/ChooseSubCategoryDropDown.dart';
import 'Widgets/RemarksButtomSheetDiscontinued.dart';
import 'Widgets/RemarksButtomSheetSave.dart';
import 'Widgets/Switch.dart';
import 'Widgets/UnitDropDown.dart';

class ProductEditScreen extends StatefulWidget {
  final SearchProduct? product;
  final String? query;
  final String ? shopId;

  const ProductEditScreen({this.shopId,this.query, this.product, Key? key})
      : super(key: key);

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusManager.instance.primaryFocus?.unfocus();
      if (widget.product == null) {
        context.read<EditProductManagement>().setString(null, null, null, null);
      } else if (widget.product?.myProduct != null) {
        context.read<EditProductManagement>().setString(
            widget.product?.myProduct?.price,
            widget.product?.myProduct?.barcode,
            widget.product?.myProduct?.margin,
            widget.product?.myProduct?.deactivated);
      } else {
        context.read<EditProductManagement>().setString(widget.product?.price,
            widget.product?.barcode, widget.product?.margin, true);
      }
      if (widget.product == null) {
        context.read<EditProductManagement>().selectedSubCategory = null;
        context.read<EditProductManagement>().productNameController.text =
            widget.query!;
      }
    });
  }

  showMenuUpload() async {
    if (widget.product != null) return;
    showMenu(
      context: context,
      position: RelativeRect.fromSize(
          Rect.fromCenter(
              center: const Offset(150, 120), width: 50, height: 100),
          const Size(200, 200)),
      items: [
        PopupMenuItem(
          child: const Text("Open Gallery"),
          onTap: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(
                source: ImageSource.gallery, imageQuality: 25);
            if (image == null) return;
            Future.delayed(const Duration(milliseconds: 10))
                .then((value) async {
              context.read<EditProductManagement>().productImage =
                  File(image.path);
              await context.read<EditProductManagement>().upload(image);
            });
          },
        ),
        PopupMenuItem(
          child: const Text("Open Camera"),
          onTap: () async {
            final ImagePicker _picker = ImagePicker();
            final XFile? image = await _picker.pickImage(
                source: ImageSource.camera, imageQuality: 25);
            if (image == null) return;
            Future.delayed(const Duration(milliseconds: 10)).then((value) {
              context.read<EditProductManagement>().productImage =
                  File(image.path);
              context.read<EditProductManagement>().upload(image);
            });
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: WillPopScope(
        onWillPop: () {
          discardDialog();
          return Future.value(true);
        },
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAppBar(
                leftButtonFunction: () {
                  discardDialog();
                },
                leftButton: true,
                title: widget.product == null ? "New" : "Update",
                rightButtonWidget: widget.product == null
                    ? null
                    : ToggleArchive(
                        product: widget.product!,
                        function: false,
                        onDeactivate: () {
                          EditProductManagement read =
                              context.read<EditProductManagement>();
                          if (!read.deactivated! != read.switchToggle) {
                            context.read<EditProductManagement>().remarks =
                                null;
                            _showModal(RemarksBottomSheetDiscontinued(
                                onSave: () async {
                              EditProductManagement read =
                                  context.read<EditProductManagement>();
                              context
                                  .read<EditProductManagement>()
                                  .switchToggle = false;
                              MyProduct? myProduct = await onSave();
                              context
                                  .read<NotSearchingProductManagement>()
                                  .deactivateMProduct(widget.product!,
                                      remarks: read.remarks);
                              Navigator.pop(context);
                            }), context);
                          }
                        }),
                rightButton: true,
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Padding(
                      padding: SpacePalette.paddingExtraLargeH,
                      child: Column(
                        children: [
                          SpacePalette.spaceExtraLarge,
                          GestureDetector(
                            onTap: showMenuUpload,
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
                                child: widget.product == null
                                    ? Center(
                                        child: context
                                                    .watch<
                                                        EditProductManagement>()
                                                    .productImage !=
                                                null
                                            ? Stack(
                                                children: [
                                                  Container(
                                                    height: 126,
                                                    width: 126,
                                                    child: Image.file(
                                                      context
                                                          .read<
                                                              EditProductManagement>()
                                                          .productImage!,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                      top: 4,
                                                      right: 4,
                                                      child: context
                                                                  .read<
                                                                      EditProductManagement>()
                                                                  .imageUrl !=
                                                              null
                                                          ? Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color: ColorPalette
                                                                  .successColor,
                                                            )
                                                          : const SizedBox(
                                                              height: 12,
                                                              width: 12,
                                                              child:
                                                                  CircularProgressIndicator()))
                                                ],
                                              )
                                            : Container(
                                                height: 126,
                                                width: 126,
                                                decoration: BoxDecoration(
                                                    border: context
                                                            .read<
                                                                EditProductManagement>()
                                                            .isPhotoValidated
                                                        ? null
                                                        : Border.all(
                                                            color: Colors.red),
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(.3),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6)),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    size: 48,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                      )
                                    : context
                                                .read<EditProductManagement>()
                                                .productImage !=
                                            null
                                        ? Center(
                                            child: Stack(
                                              children: [
                                                Container(
                                                  height: 126,
                                                  width: 126,
                                                  child: Image.file(
                                                    context
                                                        .read<
                                                            EditProductManagement>()
                                                        .productImage!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Positioned(
                                                    top: 4,
                                                    right: 4,
                                                    child: context
                                                                .read<
                                                                    EditProductManagement>()
                                                                .imageUrl !=
                                                            null
                                                        ? Icon(
                                                            Icons.check_circle,
                                                            color: ColorPalette
                                                                .successColor,
                                                          )
                                                        : const SizedBox(
                                                            height: 12,
                                                            width: 12,
                                                            child:
                                                                CircularProgressIndicator()))
                                              ],
                                            ),
                                          )
                                        : StaticService.cache(
                                            widget.product?.myProduct?.image ??
                                                widget.product?.image,
                                            height: 150,
                                            fit: BoxFit.contain,
                                          ),
                              ),
                            ),
                          ),
                          SpacePalette.spaceExtraLarge,
                          if (widget.product == null)
                            GestureDetector(
                                onTap: showMenuUpload,
                                child: Text(
                                  widget.product == null
                                      ? "Add Product Photo"
                                      : "Edit Product Photo",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      ?.copyWith(
                                          decoration: TextDecoration.underline,
                                          color:
                                              Theme.of(context).primaryColor),
                                )),
                          SpacePalette.spaceMedium,
                          ChooseSubCategoryDropdown(product: widget.product),
                          SpacePalette.spaceMedium,
                          CustomTextField2(
                              labelText: "Bar code id",
                              controller: context
                                  .read<EditProductManagement>()
                                  .barCodeController,
                              onChanged: (s) => context
                                  .read<EditProductManagement>()
                                  .notifyListeners(),
                              suffixIcon: GestureDetector(
                                onTap: () async {
                                  await StaticService.pushPage(
                                      context: context,
                                      route: const BarScannerView());
                                  Future.delayed(
                                          const Duration(milliseconds: 10))
                                      .then((value) => context
                                          .read<EditProductManagement>()
                                          .setBarcodeData());
                                },
                                child: Icon(
                                  Icons.barcode_reader,
                                  color: Theme.of(context).primaryColor,
                                  size: 32,
                                ),
                              )),
                          CustomTextField2(
                            enable: widget.product == null &&
                                widget.product != null,
                            errorText: context
                                .watch<EditProductManagement>()
                                .productNameErrorText,
                            controller: context
                                .read<EditProductManagement>()
                                .productNameController,
                            labelText: "Product Name",
                            onChanged: (val) {
                              context
                                  .read<EditProductManagement>()
                                  .productNameValidation();
                            },
                          ),
                          Row(
                            children: [
                              widget.product == null
                                  ? Container()
                                  : Expanded(
                                      child: CustomTextField2(
                                        enable: false,
                                        keyboardType: TextInputType.number,
                                        // errorText: context
                                        //     .watch<EditProductManagement>()
                                        //     .mrpErrorText,
                                        controller: context
                                            .read<EditProductManagement>()
                                            .mrpController,
                                        labelText: "MRP",
                                        onChanged: (val) {
                                          // context
                                          //     .read<EditProductManagement>()
                                          //     .mrpValidation();
                                        },
                                      ),
                                    ),
                              widget.product == null
                                  ? Container()
                                  : SpacePalette.spaceMedium,
                              Expanded(
                                child: CustomTextField2(
                                  keyboardType: TextInputType.number,
                                  errorText: context
                                      .watch<EditProductManagement>()
                                      .priceErrorText,
                                  controller: context
                                      .read<EditProductManagement>()
                                      .priceController,
                                  labelText: "Price",
                                  onChanged: (val) {
                                    context
                                        .read<EditProductManagement>()
                                        .priceValidation();
                                  },
                                ),
                              ),
                            ],
                          ),
                          SpacePalette.spaceMedium,
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField2(
                                  enable: widget.product == null,
                                  keyboardType: TextInputType.number,
                                  errorText: context
                                      .read<EditProductManagement>()
                                      .skuErrorText,
                                  controller: context
                                      .read<EditProductManagement>()
                                      .SKUController,
                                  labelText: "Qty",
                                  onChanged: (val) {
                                    context
                                        .read<EditProductManagement>()
                                        .skuValidation();
                                  },
                                ),
                              ),
                              SpacePalette.spaceMedium,
                              Expanded(
                                  child: UnitDropDown(
                                enabled: widget.product == null,
                              )),
                            ],
                          ),
                          // SpacePalette.spaceTiny,
                          SpacePalette.spaceMedium,
                          SpacePalette.spaceTiny,
                          Row(
                            children: [
                              Expanded(child: Builder(builder: (context) {
                                return DropdownSearch<String>(
                                    enabled: widget.product == null,
                                    popupProps: const PopupProps.menu(
                                        // showSearchBox: true,
                                        ),
                                    items: context
                                        .read<EditProductManagement>()
                                        .returnPolicy,
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      baseStyle: widget.product != null
                                          ? const TextStyle(color: Colors.grey)
                                          : null,
                                      dropdownSearchDecoration: InputDecoration(
                                          errorText: context
                                              .watch<EditProductManagement>()
                                              .returnPolicyErrorText,
                                          // labelText: "Choose Subcategory",
                                          labelStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          // hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                                          hintText: "Sales return policy",
                                          suffixIconColor:
                                              Theme.of(context).primaryColor),
                                    ),
                                    onChanged: (String? value) {
                                      context
                                          .read<EditProductManagement>()
                                          .selectedReturnPolicy = value;
                                      context
                                          .read<EditProductManagement>()
                                          .returnPolicyValidation();
                                    },
                                    selectedItem: context
                                        .watch<EditProductManagement>()
                                        .selectedReturnPolicy);
                              })),
                              SpacePalette.spaceMedium,
                              Expanded(child: Builder(builder: (context) {
                                return DropdownSearch<String>(
                                    popupProps: const PopupProps.menu(
                                        // showSearchBox: true,
                                        ),
                                    items: context
                                        .read<EditProductManagement>()
                                        .margins,
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                          errorText: context
                                              .watch<EditProductManagement>()
                                              .marginErrorText,
                                          labelStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          // hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                                          hintText: "Margin %",
                                          suffixIconColor:
                                              Theme.of(context).primaryColor),
                                    ),
                                    onChanged: (String? value) {
                                      context
                                          .read<EditProductManagement>()
                                          .selectedMargin = value;
                                      context
                                          .read<EditProductManagement>()
                                          .marginValidation();
                                    },
                                    selectedItem: context
                                        .watch<EditProductManagement>()
                                        .selectedMargin);
                              })),
                            ],
                          ),
                          SpacePalette.spaceMedium,
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: CustomTextField2(
                                    enable: widget.product == null,
                                    controller: context
                                        .read<EditProductManagement>()
                                        .tagsController,
                                    labelText: "Tags",
                                  ),
                                ),
                                SpacePalette.spaceMedium,
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      context
                                          .read<EditProductManagement>()
                                          .addTag();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Center(
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Builder(builder: (context) {
                            context.watch<DeliveryRadiusManagement>();
                            return Wrap(
                              children: context
                                  .watch<EditProductManagement>()
                                  .tags
                                  .map((e) => tags(context, e))
                                  .toList(),
                            );
                          }),
                          SpacePalette.spaceMedium,
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                    child: AppButtonOutline(
                                  height: 48,
                                  onPressedFunction: () async {
                                    discardDialog();
                                  },
                                  text: "Discard",
                                  borderRadius: 4,
                                )),
                                SpacePalette.spaceMedium,
                                Expanded(
                                    child: AppButtonPrimary(
                                        isdisable: context
                                            .watch<EditProductManagement>()
                                            .saveDisabled,
                                        onPressedFunction: _onSave,
                                        text: widget.product == null
                                            ? "Create"
                                            : "Save"))
                              ],
                            ),
                          ),
                          SpacePalette.spaceLarge,
                        ],
                      ),
                    ),
                    Builder(builder: (context) {
                      if (context.watch<EditProductManagement>().switchToggle) {
                        return Container();
                      }
                      return Positioned.fill(
                        child: Container(
                          color: context.watch<CustomTheme>().isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                        ),
                      );
                    })
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  _onSave() async {
    EditProductManagement read = context.read<EditProductManagement>();
    NotSearchingProductManagement readSP =
        context.read<NotSearchingProductManagement>();
    if (widget.product == null) {
      bool validationSuccess =
          context.read<EditProductManagement>().productValidation();
      if (validationSuccess) {
        await _showModal(RemarksBottomSheetSave(
          onSave: () async {
            MyProduct? prod = await onSave();
            if (prod != null) {
              if (read.selectedSubCategory != null) {
                await readSP.activateWithCreate(
                    prod, read.selectedSubCategory!);
              }
              Navigator.pop(context);
            }
          },
        ), context);
      }

      return;
    }

    if (widget.product!.myProduct == null) {
      bool validationSuccess =
          context.read<EditProductManagement>().productValidationMaster();
      if (validationSuccess) {
        await _showModal(RemarksBottomSheetSave(
          onSave: () async {
            await onSave();
            await readSP.activateMProduct(widget.product!,
                remarks: read.remarks, refUrl: read.remarksImageUrl);
            Navigator.pop(context);
          },
        ), context);

        read.remarks = null;
        read.remarksImageUrl = null;
      }
      return;
    }

    bool result = !read.checkPrev() && read.switchToggle;
    if (result) {
      await onSave();
      await readSP.activateMProduct(widget.product!,
          remarks: "Product Activated ", refUrl: read.remarksImageUrl);
      return;
    }

    await _showModal(RemarksBottomSheetSave(
      onSave: () async {
        await onSave();
        await readSP.activateMProduct(widget.product!,
            remarks: read.remarks, refUrl: read.remarksImageUrl);
        Navigator.pop(context);
      },
    ), context);
    read.remarks = null;
    read.remarksImageUrl = null;
  }

  _showModal(Widget widget, BuildContext context) {
    showModalBottomSheet(
        isDismissible: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(36), topRight: Radius.circular(36))),
        context: context,
        builder: (_) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: widget,
            ));
  }

  Future<MyProduct?> onSave() async {
    EditProductManagement readEdit = context.read<EditProductManagement>();
    SearchingProductManagement readSearch =
        context.read<SearchingProductManagement>();
    MyProduct? result =
        await readEdit.editCreateOrPost(widget.product, context );
    if (result != null) {
      if (widget.product?.myProduct == null) {
        widget.product?.myProduct = result;
        readSearch.notifyListeners();
      }
      readSearch.updateSearch(
          result,
          result.remarks?.remarksStaff?.remarks ?? readEdit.remarks,
          result.remarks?.remarksStaffReferenceUrl ?? readEdit.remarksImageUrl);
      widget.product?.myProduct = result;
      readSearch.notifyListeners();
    }
    return result;
  }

  Widget tags(BuildContext context, String tag) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          context.read<EditProductManagement>().removeTag(tag);
        },
        child: Chip(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(.2),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tag,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                SpacePalette.spaceTiny,
                Container(
                  color: Colors.transparent,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                )
              ],
            )),
      ),
    );
  }

  discardDialog() {
    bool changesMade = context.read<EditProductManagement>().checkPrev();
    if (!changesMade) {
      Navigator.of(context).pop();
      context.read<EditProductManagement>().clearData();
      return;
    }
    StaticService.showDialogBox(
        context: context,
        child: CustomDialog(
            textFirst: "Are you sure?",
            textSecond: "Your changes will be lost.",
            elevatedButtonText: "Discard",
            onPressedElevated: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              context.read<EditProductManagement>().clearData();
            }));
  }
}
