String? validateEmailphone(String value) {
  // Pattern pattern =
  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  // RegExp regExp = RegExp(pattern as String);
  if (value.isEmpty) {
    return 'Please enter mobile number or email address';
  }
  // else if (!regExp.hasMatch(value)) {
  //   return 'Enter valid email address';
  // }
  else {
    return null;
  }
}

String? validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = RegExp(pattern as String);
  if (value.isEmpty) {
    return 'Please enter email address';
  } else if (!regExp.hasMatch(value)) {
    return 'Please Enter valid email address';
  } else {
    return null;
  }
}

String? validatePassword(String value) {
  // Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])[a-zA-Z\d]{8,}$';

  if (value.isEmpty) {
    return 'Please enter password';
  } else if (value.length < 8) {
    return 'Password must be of atleast 8 characters';
  } else {
    return null;
  }
}

String? validateConfirmPassword(String value, String password) {
  // Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])[a-zA-Z\d]{8,}$';

  if (value.isEmpty) {
    return 'Please confirm password';
  } else if (value != password) {
    return 'Passwords do not match';
  } else {
    return null;
  }
}

String? validateRegisterPassword(String value) {
  // Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])[a-zA-Z\d]{8,}$';
  // RegExp regExp = RegExp(pattern as String);
  if (value.isEmpty) {
    return 'Please enter password';
  } else {
    String errorMsg = 'Your password must contain';
    bool error = false;

    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));

    if (!hasUppercase) {
      errorMsg += 'at least one uppercase,';
      error = true;
    }
    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    if (!hasLowercase) {
      errorMsg += ' one lowercase,';
      error = true;
    }

    bool hasDigits = value.contains(RegExp(r'[0-9]'));

    if (!hasDigits) {
      errorMsg += ' one number,';
      error = true;
    }

    bool hasSpecialCharacters =
        value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    if (!hasSpecialCharacters) {
      errorMsg += ' one special character';
      error = true;
    }
    if (value.length < 8) {
      errorMsg += ' and must be of atleast 8 characters ';
      error = true;
    }
    if (hasSpecialCharacters &&
        hasDigits &&
        hasLowercase &&
        hasUppercase &&
        value.length < 8) {
      errorMsg = 'Your password must be of atleast 8 characters';
    }
    if (error) {
      return errorMsg;
    } else {
      return null;
    }
  }
}

String? validatePhone(String value) {
  Pattern pattern = "^[9]{1}[6-8]{1}[0-9]{8}";
  RegExp regExp = RegExp(pattern as String);
  if (value.isEmpty) {
    return 'Please enter mobile number';
  } else if (value.length < 10) {
    return 'Mobile number must be 10 digits';
    // } else if (!regExp.hasMatch(value)) {
    //   return 'Please enter a valid mobile number';
  } else {
    return null;
  }
}

String? validateUserName(String value, {String label = "Username"}) {
  Pattern pattern = r"\s";
  RegExp regExp = RegExp(pattern as String);
  if (value.isEmpty) {
    return 'Please enter $label';
  } else if (value.length < 5) {
    return '$label should be atleast 5 characters';
  } else if (regExp.hasMatch(value)) {
    return '$label should not have white spaces';
  } else if ((RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value))) {
    return "$label cannot have special characters";
  } else {
    return null;
  }
}

String? validateName(String value) {
  // Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])[a-zA-Z\d]{8,}$';
  // RegExp regExp = RegExp(pattern as String);
  Pattern pattern = "^ {1}";
  RegExp regExp = RegExp(pattern as String);
  if (value.isEmpty) {
    return 'Please enter  name';
  } else if (regExp.hasMatch(value)) {
    return "WhiteSpace is not allowed in first letter.";
  } else {
    return null;
  }
}

// String? validateNum(String value, {String label = "Name", length = 0}) {
//   Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])[a-zA-Z\d]{8,}$';
//   RegExp regExp = new RegExp(pattern as String);
//   if (value.isEmpty) {
//     return 'Please enter $label';
//   } else if (value.length < length) {
//     return '$label should be atleast $length digit long';
//   } else {
//     return null;
//   }
// }

String? validateArea(String value, {String label = "Area"}) {
  // Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])[a-zA-Z\d]{8,}$';
  // RegExp regExp = RegExp(pattern as String);
  if (value.isEmpty) {
    return 'Please enter Area';
  } else if (value.length > 20) {
    return '$label should not be greater than 20 characters';
  } else {
    return null;
  }
}

String? validateShop(String value) {
  // Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])[a-zA-Z\d]{8,}$';
  // RegExp regExp = RegExp(pattern as String);
  if (value.isEmpty) {
    return 'Please enter shop name';
  } else {
    return null;
  }
}

String? validatePin(String value) {
  // Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])[a-zA-Z\d]{8,}$';
  // RegExp regExp = RegExp(pattern as String);
  if (value.isEmpty) {
    return 'Please enter code';
  } else if (value.length < 6) {
    return 'Please enter a valid code';
  } else {
    return null;
  }
}
