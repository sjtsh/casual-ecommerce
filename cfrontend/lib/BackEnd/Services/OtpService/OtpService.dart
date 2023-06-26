import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../Components/snackbar/customsnackbar.dart';
import '../../ApiService.dart';

class OtpService with ChangeNotifier {
  bool smsSent = false;
  String verificationId = '';
  String smsCode = '';
  int? retryToken;
  String? phone;
  String? uid;
  DateTime? lastOtpSentAt;
  bool _isVerifying = false;
  final Duration waitTIme = const Duration(minutes: 1);


  bool get isVerifying => _isVerifying;

  pressVerify() {
    _isVerifying = !_isVerifying;
    notifyListeners();
  }

  TextEditingController pinController = TextEditingController();

  Future<bool> verifyCode() async {
    var credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: pinController.text);
    try {
      var user = await FirebaseAuth.instance.signInWithCredential(credential);
      uid = user.user?.uid;

      return true;
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-verification-code') {
          CustomSnackBar().error("Invalid Verification Code");
        }
      }
      return false;
    }
  }
  setSmsCOde(String code) {
    smsCode = code;
    notifyListeners();
  }

  Future<bool> sendCode({String? newPhone, BuildContext? context,  bool forced = false}) async {
    if (!smsSent||forced) {
      if (ApiService.hasInternet) {
        await FirebaseAuth.instance.verifyPhoneNumber(
            // timeout: ,
            phoneNumber: newPhone ?? phone,
            forceResendingToken: retryToken,
            verificationCompleted: (PhoneAuthCredential credential) {
              // setState(() {
              //   smsCode = credential.smsCode!;
              // });

              if (credential.verificationId != null) {
                // _pinController.text = credential.smsCode!;

                verificationId = credential.verificationId!;
                pinController.text = credential.smsCode!;

                notifyListeners();
              }
            },
            verificationFailed: (FirebaseAuthException exception) {
              CustomSnackBar().error(exception.code);
              pressVerify();
              clear();
            },
            codeSent: (String verificationid, int? resendToken) {
              smsSent = true;
              verificationId = verificationid;
              resendToken = resendToken;
              lastOtpSentAt = DateTime.now();
              notifyListeners();
            },
            codeAutoRetrievalTimeout: (String verficationid) {
              if (verificationId.isNotEmpty) {
                verificationId = verficationid;
                notifyListeners();
              }
            });
        return true;
      } else {
        CustomSnackBar().noInternet();
        return false;
      }
    } else {
      return false;
    }
  }
  resetResend() {
    lastOtpSentAt = null;
    notifyListeners();
  }

  resend() async {
    lastOtpSentAt = null;
    smsSent = false;
    notifyListeners();
    var status = await sendCode(forced: true);
  }
  clear() {
    smsSent = false;
    verificationId = '';
    retryToken = null;
    phone = null;
    uid = null;
    pinController.text = "";
    notifyListeners();
  }
}
