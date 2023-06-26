import 'dart:async';

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:firebase_auth/firebase_auth.dart';

final otpServiceProvider = ChangeNotifierProvider<OtpService>((ref) {
  return OtpService._();
});

class OtpService extends ChangeNotifier {
  OtpService._();

  bool smsSent = false;
  String verificationId = '';
  String smsCode = '';
  int? retryToken;
  String? phone, countryCode;
  String? uid;
  DateTime? lastOtpSentAt;
  final Duration waitTIme = const Duration(minutes: 1);

  String get getPhone => "$countryCode$phone";

  TextEditingController pinController = TextEditingController();
  Future<bool> verifyCode() async {
    var credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);

    try {
      var user = await FirebaseAuth.instance.signInWithCredential(credential);
      uid = user.user?.uid;

      return true;
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-verification-code') {
          snack.error("Invalid Verification Code");
        }
      }
      return false;
    }
  }

  setSmsCOde(String code) {
    smsCode = code;
    notifyListeners();
  }

  Future<bool> sendCode({BuildContext? context, bool forced = false}) async {
    if (!smsSent || forced) {
      if (Api.hasInternet) {
        await FirebaseAuth.instance.verifyPhoneNumber(
            // timeout: ,
            phoneNumber: getPhone,
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
              snack.error(exception.code);
              context != null ? Navigator.pop(context) : 1;
              clear();
            },
            codeSent: (String verificationid, int? resendToken) {
              print(verificationid);

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
        snack.noInternet();
        return false;
      }
    } else {
      return false;
    }
  }

  clear() {
    smsSent = false;
    smsCode = '';
    verificationId = '';
    retryToken = null;
    phone = null;
    countryCode = null;
    uid = null;
    pinController = TextEditingController(text: "");
    notifyListeners();
  }

  // int? calculateTime() {
  //   if (lastOtpSentAt == null) return null;
  //   var difference = DateTime.now().difference(lastOtpSentAt!);
  //   print(difference);
  //   print(waitTIme);
  // }

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
}
