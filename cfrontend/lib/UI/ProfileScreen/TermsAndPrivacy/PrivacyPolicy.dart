
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


class CustomInAppWebView extends StatefulWidget {
  const CustomInAppWebView({super.key, required this.uri});
  final Uri uri;
  @override
  State<CustomInAppWebView> createState() => _CustomInAppWebViewState();
}

class _CustomInAppWebViewState extends State<CustomInAppWebView> {
  int progress = 0;
  bool error = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          if (!error)
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: widget.uri,
              ),
              onProgressChanged: (controller, p) {
                setState(() {
                  progress = p;
                });
              },
              onLoadError: (controller, url, code, message) {
                setState(() {
                  error = true;
                });
              },
            )
          else
            const SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Text("Opps! something went wrong"),
              ),
            ),
          if (progress < 100 && !error)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: progress / 100,
              ),
            ),
          const Positioned(
            right: 0,
            top: 0,
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Material(color: Colors.transparent,child: CloseButton()),
            ),
          ),
        ],
      ),
    );
  }}
