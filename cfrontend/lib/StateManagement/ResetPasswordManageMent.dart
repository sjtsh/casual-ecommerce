import 'package:ezdelivershop/Components/snackbar/customsnackbar.dart';
import 'package:flutter/cupertino.dart';

import '../BackEnd/Services/resetPasswordService.dart';

class ResetPasswordManagement with ChangeNotifier {
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController currentPassword = TextEditingController();

  String? newPasswordErrorText;
  String? confirmPasswordErrorText;
  String? phoneErrorText;
  String? currentPasswordErrorText;
  bool passwordMatched = false;
  bool currentPasswordVisibility = true;
  bool newPasswordVisibility = true;
  bool confirmPasswordVisibility = true;

  showPassword({required bool newPassword}) {
    if (newPassword) {
      newPasswordVisibility = !newPasswordVisibility;
    } else {
      confirmPasswordVisibility = !confirmPasswordVisibility;
    }
    notifyListeners();
  }

  showPasswordProfile() {
    currentPasswordVisibility = !currentPasswordVisibility;
    notifyListeners();
  }

  phoneValidation() {
    bool myPersonalValidation = false;
    RegExp intValid = RegExp(r'^([0-9]{10})+$');
    if (phoneNumberController.text.trim() == "") {
      phoneErrorText = "Please enter Number";
    } else if (intValid.hasMatch(phoneNumberController.text.trim())) {
      phoneErrorText = null;
      myPersonalValidation = true;
    } else {
      phoneErrorText = "Phone number must contain 10 digits";
    }
    notifyListeners();
    return myPersonalValidation;
  }

  newPasswordValidation() {
    RegExp regex = RegExp(r'^.{8,}$');
    if (newPassword.text.trim() == "" || newPassword.text.isEmpty) {
      newPasswordErrorText = "New password cannot be empty";
      notifyListeners();
    }else if (!regex.hasMatch(newPassword.text)){
      newPasswordErrorText = "Password must contain at least 8 characters";
    } else {
      newPasswordErrorText = null;
      notifyListeners();
    }
  }

  confirmPasswordValidation() {
    RegExp regex = RegExp(r'^.{8,}$');
    if (confirmPassword.text.trim() == "" || confirmPassword.text.isEmpty) {
      confirmPasswordErrorText = "Confirm password cannot be empty";
      notifyListeners();
    } else if (!regex.hasMatch(confirmPassword.text)){
      confirmPasswordErrorText = "Password must contain at least 8 characters";
    }else {
      confirmPasswordErrorText = null;
      notifyListeners();
    }
  }

  currentPasswordValidation() {
    if (currentPassword.text.trim() == "" || currentPassword.text.isEmpty) {
      currentPasswordErrorText = "Confirm password cannot be empty";
      notifyListeners();
    } else {
      currentPasswordErrorText = null;
      notifyListeners();
    }
  }

  passWordValidationFromForgetPassword() {
    bool myPersonalValidation = true;
    if (newPassword.text.trim() == "" || newPassword.text.isEmpty) {
      newPasswordErrorText = "New password cannot be empty";
      myPersonalValidation = false;
    } else {
      newPasswordErrorText = null;
      notifyListeners();
    }
    if (confirmPassword.text.trim()== "" || confirmPassword.text.isEmpty) {
      confirmPasswordErrorText = "Confirm password cannot be empty";
      myPersonalValidation = false;
      notifyListeners();
    } else {
      confirmPasswordErrorText = null;
      notifyListeners();
    }
    return myPersonalValidation;
  }

  changePasswordValidationFromProfile() {
    bool myPersonalValidation = true;
    if (newPassword.text.trim() == "" || newPassword.text.isEmpty) {
      newPasswordErrorText = "New password cannot be empty";
      myPersonalValidation = false;
    } else {
      newPasswordErrorText = null;
      notifyListeners();
    }
    if (confirmPassword.text.trim() == "" || confirmPassword.text.isEmpty) {
      confirmPasswordErrorText = "Confirm password cannot be empty";
      myPersonalValidation = false;
      notifyListeners();
    } else {
      confirmPasswordErrorText = null;
      notifyListeners();
    }
    if (currentPassword.text.trim() == "" || currentPassword.text.isEmpty) {
      currentPasswordErrorText = "Current password cannot be empty";
      myPersonalValidation = false;
      notifyListeners();
    } else {
      currentPasswordErrorText = null;
      notifyListeners();
    }
    return myPersonalValidation;
  }

  matchPasswordConfirm(String confirmPassword1) {
    if ((confirmPassword.text.trim() == "" || confirmPassword.text.isEmpty) &&
        (newPassword.text == "" || newPassword.text.isEmpty)) {
      passwordMatched = false;
      notifyListeners();
    } else if (newPassword.text == confirmPassword1) {
      passwordMatched = true;
    } else {
      passwordMatched = false;
    }
    notifyListeners();
  }

  matchPasswordNew(String newPassword1) {
    if ((newPassword.text.trim() == "" || newPassword.text.isEmpty) &&
        (confirmPassword.text.trim() == "" || confirmPassword.text.isEmpty)) {
      passwordMatched = false;
      notifyListeners();
    } else if (confirmPassword.text == newPassword1) {
      passwordMatched = true;
    } else {
      passwordMatched = false;
    }
    notifyListeners();
  }

  changePasswordFromProfile(BuildContext context) async {
    bool isValidated = changePasswordValidationFromProfile();
    if (!isValidated) return;
    bool success = await ResetPasswordService().editPasswordFromProfile(
        currentPassword: currentPassword.text.trim(),
        newPassword: confirmPassword.text.trim());
    if (!success) return;
    CustomSnackBar().success("Password successfully changed");
    Navigator.pop(context);
  }

  clearData() {
    newPassword.clear();
    confirmPassword.clear();
    newPasswordVisibility = true;
    confirmPasswordVisibility = true;
    newPasswordErrorText = null;
    confirmPasswordErrorText = null;
    currentPasswordVisibility = true;
    currentPasswordErrorText = null;
    currentPassword.clear();
    passwordMatched = false;
  }
}
