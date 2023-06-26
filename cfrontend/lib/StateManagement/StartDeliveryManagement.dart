// import 'package:flutter/cupertino.dart';
//
// class StartDeliveryManagement with ChangeNotifier {
//   String? lastOrderId;
//   String? _billImage;
//
//   String? get billImage => _billImage;
//
//   set billImage(String? value) {
//     _billImage = value;
//     notifyListeners();
//   }
//
//   bool _billImageValidation = true;
//
//   bool get billImageValidation => _billImageValidation;
//
//   set billImageValidation(bool value) {
//     _billImageValidation = value;
//     notifyListeners();
//   }
//
//   List<bool>? _productImagesValidation;
//
//   List<bool>? get productImagesValidation => _productImagesValidation;
//
//   set productImagesValidation(List<bool>? value) {
//     _productImagesValidation = value;
//     notifyListeners();
//   }
//
//   List<String?>? _productImage;
//
//   List<String?>? get productImage => _productImage;
//
//   set productImage(List<String?>? value) {
//     _productImage = value;
//     notifyListeners();
//   }
//
//   init(int length, String orderID) {
//     if(lastOrderId != orderID) {
//       validateCountPressed = false;
//       productImagesValidation = List.generate(length, (e) => true);
//       productImage = List.generate(length, (e) => null);
//       billImage = null;
//       billImageValidation = true;
//     }
//     lastOrderId = orderID;
//     notifyListeners();
//   }
//
//   bool validateCountPressed = false;
//
//   int? validateCount() {
//     validateCountPressed = true;
//     notifyListeners();
//     if (_billImage == null) return null;
//     if (_productImage == null) return 0;
//     int count = 0;
//     for (var i in _productImage!) {
//       if (i == null) count++;
//     }
//     return count;
//   }
//
//   bool get isDisabled {
//     return (_productImage?.contains(null) ?? true) || billImage == null;
//   }
//
//   bool validate() {
//     int? count = validateCount();
//     if (count == 0) return true;
//     return false;
//   }
//
//   @override
//   void notifyListeners() {
//     if (validateCountPressed &&
//         _productImage != null &&
//         productImagesValidation != null) {
//       for (int i = 0; i < _productImage!.length; i++) {
//         productImagesValidation![i] = _productImage![i] != null;
//       }
//       _billImageValidation = _billImage != null;
//     }
//     super.notifyListeners();
//   }
// }
