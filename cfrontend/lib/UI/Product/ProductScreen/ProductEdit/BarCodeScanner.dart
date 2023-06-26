import 'dart:developer';
import 'dart:io';

import 'package:ezdelivershop/StateManagement/EditProductManagement.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class BarScannerView extends StatefulWidget {
  const BarScannerView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BarScannerViewState();
}

class _BarScannerViewState extends State<BarScannerView> {
  Barcode? result;
  String message = "Scan a barcode";

  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
             Text(message)
        ],
      ),
    );
  }


  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    // var scanArea = (MediaQuery.of(context).size.width < 400 ||
    //         MediaQuery.of(context).size.height < 400)
    //     ? 200.0
    //     : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,

      formatsAllowed: const [BarcodeFormat.codabar, BarcodeFormat.code39, BarcodeFormat.code93, BarcodeFormat.code128, BarcodeFormat.ean8, BarcodeFormat.ean13, BarcodeFormat.itf, BarcodeFormat.rss14, BarcodeFormat.rssExpanded, BarcodeFormat.upcA, BarcodeFormat.upcE, BarcodeFormat.upcEanExtension],
      onQRViewCreated: (QRViewController controller) {
        setState(() {
          this.controller = controller;
        });
        controller.scannedDataStream.listen((scanData) {
          controller.pauseCamera();
          if(scanData.format == BarcodeFormat.qrcode) {
            setState(() {
              message = "Invalid Barcode";
            });
            return;
          }
          context.read<EditProductManagement>().result = scanData;
          if (context.read<EditProductManagement>().result != null) {
            controller.pauseCamera();
            Navigator.of(context).pop(scanData);
          }
        });
      },
      overlay: QrScannerOverlayShape(
        cutOutWidth:MediaQuery.of(context).size.width<400?300: 400,
          cutOutHeight:MediaQuery.of(context).size.height < 400 ?200: 150,
          borderColor: Theme.of(context).primaryColor,
          borderRadius: 10,
          borderLength: 25,
          borderWidth: 6,
          // cutOutSize: scanArea
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  // void _onQRViewCreated(QRViewController controller) {
  //   setState(() {
  //     this.controller = controller;
  //   });
  //   controller.scannedDataStream.listen((scanData) {
  //     setState(() {
  //       result = scanData;
  //     });
  //   });
  // }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
