// ignore_for_file: file_names

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateService {
  AppUpdateInfo? _appUpdateInfo;

  void checkForInAppUpdate({Function? onSuccess, Function? onFailure}) {
    InAppUpdate.checkForUpdate().then((value) {
      _appUpdateInfo = value;
      _checkForUpdateAvailability(onSuccess ?? () {}, (val) {
        if (val == "User denied update") {
          Future.delayed(const Duration(milliseconds: 100), () {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          });
        }

        if (onFailure != null) {
          onFailure(val);
        }
      });
    }).catchError((error) {
      // inspect(error);
      // onFailure(error.toString());
    });
  }

  bool isUpdateAvailable() {
    if (_appUpdateInfo != null) {
      return _appUpdateInfo!.updateAvailability ==
          UpdateAvailability.updateAvailable;
    }
    return false;
  }

  bool isImmediateUpdatePossible() {
    if (_appUpdateInfo != null) {
      return _appUpdateInfo!.immediateUpdateAllowed;
    }

    return false;
  }

  bool isFlexibleUpdatePossible() {
    if (_appUpdateInfo != null) {
      return _appUpdateInfo!.flexibleUpdateAllowed;
    }

    return false;
  }

  Future<void> applyImmediateUpdate(
      Function onSuccess, Function onFailure) async {
    InAppUpdate.performImmediateUpdate()
        .then((appUpdateResult) => {
              if (appUpdateResult == AppUpdateResult.userDeniedUpdate)
                {onFailure("User denied update")}
              else if (appUpdateResult == AppUpdateResult.inAppUpdateFailed)
                {onFailure("App Update Failed")}
              else
                {onSuccess()}
            })
        .catchError((onError) {
      onFailure(onError);
    });
  }

  Future<void> startFlexibleUpdate() async {
    AppUpdateResult appUpdateResult = await InAppUpdate.startFlexibleUpdate();
    if (appUpdateResult == AppUpdateResult.success) {
      InAppUpdate.completeFlexibleUpdate();
    }
  }

  void _checkForUpdateAvailability(Function onSuccess, Function onFailure) {
    bool needToUpdate = isUpdateAvailable();
    if (needToUpdate) {
      bool isImmediateUpdateAvailable = isImmediateUpdatePossible();
      if (isImmediateUpdateAvailable) {
        applyImmediateUpdate(onSuccess, onFailure);
      } else {
        bool isFlexibleUpdateAvailable = isFlexibleUpdatePossible();
        if (isFlexibleUpdateAvailable) {
          startFlexibleUpdate();
        }
      }
    }
  }
}
