import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ezdelivershop/BackEnd/Entities/MyProduct.dart';
import 'package:ezdelivershop/BackEnd/Entities/SearchProduct.dart';
import 'package:ezdelivershop/BackEnd/Entities/ShopCategory.dart';
import 'package:ezdelivershop/BackEnd/Services/ProductService.dart';
import 'package:ezdelivershop/StateManagement/NotSearchingProductManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../BackEnd/Entities/UploadedImage.dart';
import '../BackEnd/Services/ShopService.dart';
import '../BackEnd/Services/UploadImageService.dart';
import '../Components/snackbar/customsnackbar.dart';

class EditProductManagement with ChangeNotifier {
  ifSent(bool sent, BuildContext context, String msg, {String? success}) {
    if (sent) {
      clearData();
      CustomSnackBar().success(success ?? "Operation successful");
      Navigator.of(context).pop();
    } else {
      CustomSnackBar().error(msg);
    }
  }

  Future<MyProduct?> editCreateOrPost(
      SearchProduct? prod, BuildContext context) async {
    if (prod == null) {
      // bool validationSuccess = productValidation();
      // if (validationSuccess) {
        MyProduct sent = await createProduct();
        Future.delayed(const Duration(milliseconds: 5))
            .then((value) => ifSent(true, context, "Failed to create"));
        return sent;
      // }
    } else if (prod.myProduct != null) {
      bool changes = checkPrev();
      bool shouldRunSafeEdit = !changes && (deactivated != !switchToggle);
      if (shouldRunSafeEdit) {
        MyProduct sent = await ProductCrudService().deactivateProd(
            !switchToggle, prod.myProduct!.id,
            remarks: remarks);
        Future.delayed(const Duration(milliseconds: 5)).then((value) => ifSent(
            sent != null,
            context,
            "Failed to ${switchToggle ? "activate" : "deactivate"}",
            success:
                "Successfully ${switchToggle ? "activated" : "deactivated"}"));
        prod.myProduct?.deactivated = !switchToggle;
        prod.myProduct = sent;
        return sent;
      }
      if (!changes) {
        Navigator.of(context).pop();
        CustomSnackBar().info("No changes recognized");
        return null;
      }
      // showModalBottomSheet(
      //     context: context, builder: (_) => const RemarksBottomSheet());

      bool validationSuccessMaster = productValidationMaster();
      if (validationSuccessMaster) {
        MyProduct sent = await updateProductData(p: prod.myProduct);
        Future.delayed(const Duration(milliseconds: 5))
            .then((value) => ifSent(true, context, "Failed to create"));
        clearData();
        return sent;
      }
    } else {
      NotSearchingProductManagement read =
          context.read<NotSearchingProductManagement>();
      bool validationSuccessMaster = productValidationMaster();
      if (validationSuccessMaster) {
        MyProduct product = await createMyProduct(master: prod);
        CustomSnackBar().success("Operation Successful");
        clearData();
        Navigator.of(context).pop();
        return product;
      }
    }
    return null;
  }

//-----------------------------check prev-----------------------------
  String? price;
  String? barcode;
  String? margin;
  bool? deactivated;

  setString(double? price, String? barcode, int? margin, bool? deactivated) {
    this.price = price.toString();
    this.barcode = (barcode ?? "").toString();
    this.margin = margin.toString();
    this.deactivated = deactivated;
  }

  bool checkPrev() {
    String marginSplit =
        (margin == null ? null : margin!.split("%").first).toString();
    String selectedMarginSplit =
        (_selectedMargin == null ? null : _selectedMargin!.split("%").first)
            .toString();
    bool changes = !(price == priceController.text &&
        barcode == barCodeController.text &&
        marginSplit == selectedMarginSplit);
    return changes;
  }

  bool get saveDisabled {
    if(deactivated ==null ) {
      return false;
    }
    return !(checkPrev() || (deactivated == _switchToggle));
  }

//-----------------------------check prev-----------------------------

  Barcode? _result;
  final Future function = ShopService().getSubCategory();

  Barcode? get result => _result;
  File? _productImage;
  List<SearchProduct>? _productList;

  List<SearchProduct>? get productList => _productList;

  set productList(List<SearchProduct>? value) {
    _productList = value;
    notifyListeners();
  }

  addAll(List<SearchProduct> prods) {
    productList?.addAll(prods);
    notifyListeners();
  }

  SearchProduct? _selectedProduct;

  SearchProduct? get selectedProduct => _selectedProduct;

  set selectedProduct(SearchProduct? value) {
    _selectedProduct = value;
    notifyListeners();
  }

  setSelectedSubCategory(SubCategory value) {
    _selectedSubCategory = value;
  }

  set result(Barcode? value) {
    _result = value;
    notifyListeners();
  }

  File? get productImage => _productImage;

  set productImage(File? value) {
    _productImage = value;
    notifyListeners();
  }

  TextEditingController tagsController = TextEditingController();
  TextEditingController barCodeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController SKUController = TextEditingController();
  TextEditingController mrpController = TextEditingController();
  String? _remarks;

  String? get remarks => _remarks;

  set remarks(String? value) {
    _remarks = value;
    notifyListeners();
  }

  String? remarksImageUrl;

  setBarcodeData() {
    if (result != null) {
      barCodeController.text = result!.code.toString();
    }
    notifyListeners();
  }

  List<String> _tags = [];

  List<String> get tags => _tags;

  set tags(List<String> value) {
    _tags = value;
    notifyListeners();
  }

  addTag() {
    if ((tagsController.text.trim().isNotEmpty)) {
      if (!_tags.contains(tagsController.text.trim())) {
        _tags.add(tagsController.text.trim());
      }
    }

    tagsController.clear();
    notifyListeners();
  }

  removeTag(String tag) {
    if (_tags.contains(tag)) {
      _tags.remove(tag);
    }
    notifyListeners();
  }

  List<String> returnPolicy = [
    "No return",
    "Within 7 days",
    "Within 3 days",
    "Within 24 hours"
  ];
  String? _selectedReturnPolicy;

  String? get selectedReturnPolicy => _selectedReturnPolicy;

  set selectedReturnPolicy(String? value) {
    _selectedReturnPolicy = value;
    notifyListeners();
  }

  String? _selectedUnit;

  String? get selectedUnit => _selectedUnit;

  set selectedUnit(String? value) {
    _selectedUnit = value;
    notifyListeners();
  }

  List<String> margins = ["0%", "10%", "20%", "50%"];
  String? _selectedMargin;

  String? get selectedMargin => _selectedMargin;

  set selectedMargin(String? value) {
    _selectedMargin = value;
    notifyListeners();
  }

  List<SubCategory> subcategory = [];
  SubCategory? _selectedSubCategory;

  SubCategory? get selectedSubCategory => _selectedSubCategory;

  set selectedSubCategory(SubCategory? value) {
    _selectedSubCategory = value;
    notifyListeners();
  }

  String? _imageUrl;

  String? get imageUrl => _imageUrl;

  set imageUrl(String? value) {
    _imageUrl = value;
    notifyListeners();
  }

  Future<void> upload(XFile xFile) async {
    List<UploadedImage> image = await UploadImageService().uploadOwnerImage([
      UploadableImage(
          xFile.path,
          "${DateTime.now().toString().replaceAll(":", ".").replaceAll("-", ".").replaceAll(" ", ".")}.jpg",
          "changedShopImage")
    ]);
    if (image.isEmpty) {
      _imageUrl = null;
      notifyListeners();
    }
    _imageUrl = image[0].url;
    notifyListeners();
  }

  int getMargin() {
    if (selectedMargin != null) {
      int margin = int.parse(
          selectedMargin.toString().substring(0, selectedMargin!.length - 1));
      return margin;
    }
    return 0;
  }

  int getReturnPolicy() {
    if (selectedReturnPolicy == "No return") {
      return 0;
    } else if (selectedReturnPolicy == "Within 7 days") {
      return 7;
    } else if (selectedReturnPolicy == "Within 3 days") {
      return 3;
    } else {
      return 1;
    }
  }

  String setReturnPolicy(int i) {
    if (i == 0) {
      return "No return";
    } else if (i == 7) {
      return "Within 7 days";
    } else if (i == 3) {
      return "Within 3 days";
    } else {
      return "Within 24 hours";
    }
  }

  String concatenateRemarks(){
    String remarksCon= """$remarks |\nbarcode: $barcode => ${barCodeController.text}, price: $price => ${priceController.text}, margin: ${margin == "null" ? " " : margin} => ${selectedMargin.toString().substring(0, selectedMargin!.length - 1)}"""  ;
  return remarksCon;
  }
  Future<MyProduct> createProduct({SearchProduct? p}) async {
    trimmer();
    MyProduct product = await ProductCrudService().createProduct(
      subcategoryId: selectedSubCategory!.id,
      margin: getMargin(),
      price: double.parse(priceController.text),
      name: productNameController.text,
      salesReturnPolicy: getReturnPolicy(),
      unit: selectedUnit!,
      barcode: barCodeController.text,
      image: _imageUrl ?? (p?.image),
      SKU: double.parse(SKUController.text),
      remarks: remarks,
      tags: tags,
      remarksUrl:remarksImageUrl,
    );
    return product;
  }

  Future<MyProduct> createMyProduct({SearchProduct? master}) async {
    trimmer();
    MyProduct product = await ProductCrudService().createMyProduct(master!,
        subcategoryId: selectedSubCategory!.id,
        margin: getMargin(),
        price: double.parse(priceController.text),
        name: productNameController.text,
        salesReturnPolicy: getReturnPolicy(),
        unit: selectedUnit!,
        barcode: barCodeController.text,
        image: _imageUrl ?? (master.image),
        SKU: double.parse(SKUController.text),
        tags: tags,
        remarksUrl: remarksImageUrl,
        remarks:concatenateRemarks());
    return product;
  }

  Future<MyProduct> updateProductData({MyProduct? p}) async {
    trimmer();
    MyProduct product = await ProductCrudService().updateProduct(
        product: p!,
        subcategoryId: selectedSubCategory!.id,
        margin: getMargin(),
        price: double.tryParse(priceController.text) ?? double.parse(price!),
        name: productNameController.text,
        salesReturnPolicy: getReturnPolicy(),
        unit: selectedUnit!,
        barcode: barCodeController.text,
        image: _imageUrl ?? (p.image),
        SKU: double.tryParse(SKUController.text),
        remarks:concatenateRemarks(),
        remarksUrl: remarksImageUrl,
        tags: tags);
    return product;
  }

  trimmer() {
    tagsController.text = tagsController.text.trim();
    barCodeController.text = barCodeController.text.trim();
    priceController.text = priceController.text.trim();
    productNameController.text = productNameController.text.trim();
    SKUController.text = SKUController.text.trim();
    mrpController.text = mrpController.text.trim();
    _remarks = _remarks?.trim();
  }

  ///---------------------------------------------------------------------------------------
  ///-------------------------------------VALIDATION----------------------------------------
  ///---------------------------------------------------------------------------------------

  String? productNameErrorText;
  String? priceErrorText;
  String? skuErrorText;

// String? weightErrorText;
  String? subCategoryErrorText;
  String? unitErrorText;
  String? marginErrorText;
  String? returnPolicyErrorText;
  bool isPhotoValidated = true;
  bool isSubCategoryValidated = true;
  bool isUnitValidated = true;
  bool isReturnValidated = true;
  bool isMarginValidated = true;
  bool _switchToggle = false;

  bool get switchToggle => _switchToggle;

  set switchToggle(bool value) {
    _switchToggle = value;
    notifyListeners();
  }

  toggleSwitch(bool b) {
    _switchToggle = b;
    notifyListeners();
  }

  bool productNameValidation() {
    bool myPersonalValidation = false;
    if (productNameController.text.trim() == "" ||
        productNameController.text.isEmpty) {
      productNameErrorText = "Please enter product name";
    } else {
      productNameErrorText = null;
      myPersonalValidation = true;
    }
    notifyListeners();
    return myPersonalValidation;
  }

  bool priceValidation() {
    bool myPersonalValidation = false;
    if (priceController.text.trim() == "" || priceController.text.isEmpty) {
      priceErrorText = "Please enter price";
    } else if (double.tryParse(priceController.text.trim()) == null) {
      priceErrorText = "Please enter valid price";
    } else {
      priceErrorText = null;
      myPersonalValidation = true;
    }
    notifyListeners();
    return myPersonalValidation;
  }

// bool weightValidation() {
//   bool myPersonalValidation = false;
//   if (weightController.text.trim() == "" || weightController.text.isEmpty) {
//     weightErrorText = "Please enter weight";
//   } else {
//     weightErrorText = null;
//     myPersonalValidation = true;
//   }
//   notifyListeners();
//   return myPersonalValidation;
// }

  bool skuValidation() {
    bool myPersonalValidation = false;
    if (SKUController.text.trim() == "" || SKUController.text.isEmpty) {
      skuErrorText = "Please enter qty";
    } else if (int.tryParse(SKUController.text.trim()) == null) {
      skuErrorText = "Please enter valid qty";
    } else {
      skuErrorText = null;
      myPersonalValidation = true;
    }
    notifyListeners();
    return myPersonalValidation;
  }

  bool productImageValidation(bool hasPhoto) {
    bool myPersonalValidation = true;
    if (productImage == null && !hasPhoto) {
      myPersonalValidation = false;
    }
    isPhotoValidated = myPersonalValidation;
    notifyListeners();
    return myPersonalValidation;
  }

  bool subCategoryValidation() {
    bool myPersonalValidation = true;
    if (_selectedSubCategory == null) {
      myPersonalValidation = false;
      subCategoryErrorText = "Please select subcategory";
    } else {
      myPersonalValidation = true;
      subCategoryErrorText = null;
    }
    isSubCategoryValidated = myPersonalValidation;
    notifyListeners();
    return myPersonalValidation;
  }

  bool unitValidation() {
    bool myPersonalValidation = true;
    if (_selectedUnit == null) {
      myPersonalValidation = false;
      unitErrorText = "Please select subcategory";
    } else {
      myPersonalValidation = true;
      unitErrorText = null;
    }
    isUnitValidated = myPersonalValidation;
    notifyListeners();
    return myPersonalValidation;
  }

  bool marginValidation() {
    bool myPersonalValidation = true;
    if (_selectedMargin == null) {
      myPersonalValidation = false;
      marginErrorText = "Please select margin";
    } else {
      myPersonalValidation = true;
      marginErrorText = null;
    }
    isMarginValidated = myPersonalValidation;
    notifyListeners();
    return myPersonalValidation;
  }

  bool returnPolicyValidation() {
    bool myPersonalValidation = true;
    if (_selectedReturnPolicy == null) {
      myPersonalValidation = false;
      returnPolicyErrorText = "Please select return day";
    } else {
      myPersonalValidation = true;
      returnPolicyErrorText = null;
    }
    isReturnValidated = myPersonalValidation;
    notifyListeners();
    return myPersonalValidation;
  }

  productValidation() {
    bool productImage = productImageValidation(false);
    bool productName = productNameValidation();
    bool price = priceValidation();
    bool sku = skuValidation();
    bool unit = unitValidation();
    bool margin = marginValidation();
    bool subCategory = subCategoryValidation();
    bool returnDay = returnPolicyValidation();
    // bool weight = weightValidation();
    notifyListeners();
    return productImage &&
        price &&
        unit &&
        productName &&
        sku &&
        subCategory &&
        margin &&
        returnDay;
  }

  productValidationMaster() {
    bool price = priceValidation();
    bool margin = marginValidation();
    notifyListeners();
    return price && margin;
  }

  ///

  clearData() {
    productNameErrorText = null;
    skuErrorText = null;
    priceErrorText = null;
    unitErrorText = null;
    _productImage = null;
    _imageUrl = null;
    // weightErrorText = null;
    tags = [];
    subCategoryErrorText = null;
    marginErrorText = null;
    productImage = null;
    SKUController.clear();
    mrpController.clear();
    priceController.clear();
    tagsController.clear();
    productNameController.clear();
    isMarginValidated = true;
    isSubCategoryValidated = true;
    isUnitValidated = true;
    isReturnValidated = true;
    returnPolicyErrorText = null;
    isPhotoValidated = true;
    selectedSubCategory = null;
    _selectedSubCategory = null;
    _selectedUnit = null;
    _selectedReturnPolicy = null;
    _selectedMargin = null;
    barCodeController.clear();
    result = null;
    remarks = null;
    notifyListeners();
  }
}
