import 'dart:io';
import 'package:ezdelivershop/BackEnd/Entities/ShopCategory.dart';
import 'package:ezdelivershop/BackEnd/Entities/UploadedImage.dart';
import 'package:ezdelivershop/BackEnd/Services/ShopService.dart';
import 'package:ezdelivershop/BackEnd/Services/SignUp.dart';
import 'package:ezdelivershop/Components/snackbar/customsnackbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';


class SignUpAndCameraManagement with ChangeNotifier {
  Set<ShopCategory> _selectedCategories = {};

  Set<ShopCategory> get selectedCategories => _selectedCategories;

  set selectedCategories(Set<ShopCategory> value) {
    _selectedCategories = value;
    notifyListeners();
  }

  removeSelectedCategory(ShopCategory category) {
    selectedCategories.remove(category);
    notifyListeners();
  }

  Future<List<UploadedImage>>? _imageUploading;
  String? shopImageUploadedUrl;

  /// Camera
  File? _shopImage;
  bool isFlashTurnedOn = false;
  bool isShotTaken = false;

  /// Location
  Position? position;

  /// select Category down
  List<ShopCategory> _selectedCategory = [];

  List<ShopCategory> get selectedCategory => _selectedCategory;

  set selectedCategory(List<ShopCategory> value) {
    _selectedCategory = value;
    notifyListeners();
  }

  Future<List<UploadedImage>>? get imageUploading => _imageUploading;

  set imageUploading(Future<List<UploadedImage>>? value) {
    _imageUploading = value;
    notifyListeners();
  }

  Set<String> _editCategory = {};

  Set<String> get editCategory => _editCategory;

  set editCategory(Set<String> value) {
    _editCategory = value;
    notifyListeners();
  }

  /// Sign up start
  bool _isSignupStarted = false;

  bool get isSignupStarted => _isSignupStarted;

  set isSignupStarted(bool value) {
    _isSignupStarted = value;
  }

  startSignup() {
    _isSignupStarted = !_isSignupStarted;
    notifyListeners();
  }

  ///

  File? get shopImage => _shopImage; // String

  set shopImage(File? value) {
    _shopImage = value;
    notifyListeners();
  }

  changeFlash() {
    isFlashTurnedOn = !isFlashTurnedOn;
    notifyListeners();
  }

  shot() {
    isShotTaken = !isShotTaken;
    notifyListeners();
  }

  /// Sign Up
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController panController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController ownerNameController = TextEditingController();

  String? nameErrorText;
  String? passwordErrorText;
  String? panErrorText;
  String? phoneNumberErrorText;
  String? addressErrorText;
  String? ownerErrorText;
  bool _validated = false;
  bool isPhotoValidated = true;
  bool isCategoryValidated = true;

  FocusNode nameNode = FocusNode();
  FocusNode passwordNode = FocusNode();
  FocusNode panNode = FocusNode();
  FocusNode phoneNode = FocusNode();
  FocusNode addressNode = FocusNode();
  FocusNode ownerNameNode = FocusNode();

  bool get validated => _validated;

  set validated(bool value) {
    _validated = value;
    notifyListeners();
  }

  nameValidation() {
    bool myPersonalValidation = false;
    if (nameController.text == "" || nameController.text.isEmpty) {
      nameErrorText = "Please type your shop name";
    } else {
      nameErrorText = null;
      myPersonalValidation = true;
    }
    notifyListeners();
    return myPersonalValidation;
  }

  ownerNameValidation() {
    bool myPersonalValidation = false;
    if (ownerNameController.text == "" || ownerNameController.text.isEmpty) {
      ownerErrorText = "Please type your name";
    } else {
      ownerErrorText = null;
      myPersonalValidation = true;
    }
    notifyListeners();
    return myPersonalValidation;
  }

  passwordValidation() {

    bool myPersonalValidation = false;
    RegExp regex = RegExp(r'^.{8,}$');

    if (passwordController.text == "" || passwordController.text.isEmpty) {
      passwordErrorText = "Please type your password";
    }else if(!regex.hasMatch(passwordController.text)){
      passwordErrorText ="Password must contain at least 8 characters";
    } else {
      passwordErrorText = null;
      myPersonalValidation = true;
    }
    notifyListeners();
    return myPersonalValidation;
  }

  panValidation() {
    bool myPersonalValidation = true;
    RegExp intValid = RegExp(r'^([0-9]{9})+$');

    if (intValid.hasMatch(panController.text) ||
        panController.text.trim() == "") {
      panErrorText = null;
    } else {
      panErrorText = "PAN numbers must contain 9 digits.";
      myPersonalValidation = false;
    }
    notifyListeners();
    return myPersonalValidation;
  }

  phoneValidation() {
    bool myPersonalValidation = false;
    RegExp intValid = RegExp(r'^([0-9]{10})+$');
    if (phoneController.text.trim() == "") {
      phoneNumberErrorText = "Please enter Number";
    } else if (intValid.hasMatch(phoneController.text)) {
      phoneNumberErrorText = null;
      myPersonalValidation = true;
    } else {
      phoneNumberErrorText = "Phone number must contain 10 digits";
    }
    notifyListeners();
    return myPersonalValidation;
  }

  addressValidation() {
    bool myPersonalValidation = false;
    if (addressController.text.trim() == "" || addressController.text.isEmpty) {
      addressErrorText = "Please type your address";
    } else {
      addressErrorText = null;
      myPersonalValidation = true;
    }
    notifyListeners();
    return myPersonalValidation;
  }

  bool photoValidation() {
    bool myPersonalValidation = true;
    if (shopImage == null) {
      myPersonalValidation = false;
    }
    isPhotoValidated = myPersonalValidation;
    notifyListeners();
    return myPersonalValidation;
  }

  bool categoryValidation() {
    bool myPersonalValidation = true;
    if (_selectedCategories.isEmpty) {
      myPersonalValidation = false;
    }
    isCategoryValidated = myPersonalValidation;
    notifyListeners();
    return myPersonalValidation;
  }

  signUpValidation() {
    bool nameValidator = nameValidation();
    bool passwordValidator = passwordValidation();
    bool panValidator = panValidation();
    bool phoneValidator = phoneValidation();
    bool addressValidator = addressValidation();
    bool photoValidator = photoValidation();
    bool ownerValidation = ownerNameValidation();
    bool categoryValidator = categoryValidation();
    notifyListeners();
    return nameValidator &&
        passwordValidator &&
        panValidator &&
        phoneValidator &&
        addressValidator &&
        photoValidator &&
        ownerValidation &&
        categoryValidator;
  }

  unFocusAll() {
    nameNode.unfocus();
    passwordNode.unfocus();
    panNode.unfocus();
    phoneNode.unfocus();
    addressNode.unfocus();
    ownerNameNode.unfocus();
  }

  Future<bool> signUp() async {
    if (shopImageUploadedUrl == null) {
      CustomSnackBar().error("Please wait while image is being uploaded");
      return false;
    }
    return await SignUpService().signUp(
        nameController.text.trim(),
        ownerNameController.text.trim(),
        phoneController.text.trim(),
        shopImageUploadedUrl!,
        passwordController.text.trim(),
        panController.text.trim(),
        addressController.text.trim(),
        position!,
        _selectedCategories.toList());
  }

  clearValidation() {
    addressErrorText = null;
    // panErrorText = null;
    ownerErrorText = null;
    passwordErrorText = null;
    nameErrorText = null;
    phoneNumberErrorText = null;
    isPhotoValidated = true;
    _selectedCategory.clear();
  }

  clearData() {
    nameController.clear();
    panController.clear();
    addressController.clear();
    phoneController.clear();
    passwordController.clear();
    ownerErrorText = null;
    position =null;
    shopImage = null;
    shopImageUploadedUrl = null;
    selectedCategories.clear();
    ownerNameController.clear();
    clearValidation();
  }

  Future<bool> updateShopCategory() async {
    return await ShopService().updateShopCategories(_editCategory.toList());
  }
}
