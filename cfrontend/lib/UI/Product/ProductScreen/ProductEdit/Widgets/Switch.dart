import 'package:ezdelivershop/BackEnd/Entities/SearchProduct.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../Components/Constants/ColorPalette.dart';
import '../../../../../StateManagement/EditProductManagement.dart';

class ToggleArchive extends StatefulWidget {
  final SearchProduct product;
  final bool function;
  final Function() onDeactivate;

  const ToggleArchive(
      {required this.product,
      this.function = true,
      Key? key,
      required this.onDeactivate})
      : super(key: key);

  @override
  State<ToggleArchive> createState() => _ToggleArchiveState();
}

class _ToggleArchiveState extends State<ToggleArchive> {
  changeToggle(bool b) async {
    if (!b) {
      if (widget.product.myProduct == null) return;
      widget.onDeactivate();
    }
    // widget.product.myProduct = null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setParams();
      if (widget.product.myProduct != null) {
        context.read<EditProductManagement>().switchToggle =
            !widget.product.myProduct!.deactivated;
      } else {
        context.read<EditProductManagement>().switchToggle = false;
      }
    });

    super.initState();
  }

  setParams() {
    context.read<EditProductManagement>().productImage = null;
    EditProductManagement edit = context.read<EditProductManagement>();
    if (widget.product.myProduct != null) {
      if (widget.product.myProduct?.barcode != null) {
        edit.barCodeController.text =
            widget.product.myProduct!.barcode.toString();
      } else {
        edit.barCodeController.text = "";
      }
      edit.tags =  [];
      edit.productNameController.text = widget.product.myProduct?.name ?? "";
      if (widget.product.myProduct?.returnPolicy == null) {
        edit.selectedReturnPolicy = null;
      } else {
        edit.selectedReturnPolicy =
            edit.setReturnPolicy(widget.product.myProduct!.returnPolicy!);
      }
      edit.priceController.text =
          widget.product.myProduct?.price.toString() ?? "";
      if (widget.product.myProduct?.sku == null) {
        edit.SKUController.text = "";
      } else {
        if((widget.product.myProduct!.sku.toString().contains(".0"))){
          edit.SKUController.text = widget.product.myProduct!.sku!.toStringAsFixed(0);
        }else{
          edit.SKUController.text = widget.product.myProduct!.sku.toString();
        }

      }
      edit.mrpController.text = widget.product.price.toString();
      edit.selectedUnit = widget.product.myProduct?.unit;
      if (widget.product.myProduct?.margin != null) {
        edit.selectedMargin = "${widget.product.myProduct!.margin}%";
      } else {
        edit.selectedMargin = null;
      }
    } else {
      if (widget.product.barcode != null) {
        edit.barCodeController.text = widget.product.barcode.toString();
      } else {
        edit.barCodeController.text = "";
      }
      edit.productNameController.text = widget.product.name;
      if (widget.product.returnPolicy == null) {
        edit.selectedReturnPolicy = null;
      } else {
        edit.selectedReturnPolicy =
            edit.setReturnPolicy(widget.product.returnPolicy!);
      }
      // edit.priceController.text = widget.product.price.toString();
      if (widget.product.sku == null) {
        edit.SKUController.text = "";
      } else {
        edit.SKUController.text = widget.product.sku.toString();
      }
      edit.mrpController.text = widget.product.price.toString();
      edit.selectedUnit = widget.product.unit;
      if (widget.product.margin != null) {
        edit.selectedMargin = "${widget.product.margin}%";
      } else {
        edit.selectedMargin = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (disableToggle) return const CircularProgressIndicator();
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: SizedBox(
        height: 28,
        width: 42,
        child: FittedBox(
          fit: BoxFit.cover,
          child: CupertinoSwitch(
            onChanged: (bool status) {
              context.read<EditProductManagement>().toggleSwitch(status);
              changeToggle(status);
            },
            value: context.watch<EditProductManagement>().switchToggle,
            activeColor: ColorPalette.successColor,
            trackColor: ColorPalette.primaryColor.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
