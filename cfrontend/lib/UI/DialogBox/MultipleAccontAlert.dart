import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Components/CustomTheme.dart';
import '../../Components/Widgets/ButtonOutline.dart';

class MultipleAccountAlert extends StatelessWidget {
  // final String title;
  // final String subTitle;
  final Function() onPressed;
  final bool onPressedPop;

  const MultipleAccountAlert(
      {super.key, required this.onPressed, this.onPressedPop = false});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
            decoration: BoxDecoration(
                color: context.watch<CustomTheme>().isDarkMode
                    ? ColorPalette.darkContainerColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(6)),
            height: 200,
            width: 400,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 32, right: 32, top: 32, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Multiple login detected",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Session can only be watched by one device at a time",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  // Text(
                  //     """Your feedback has been sent. Please wait for the confirmation from customer."""),
                  const SizedBox(
                    height: 8,
                  ),
                  const Spacer(),
                  AppButtonOutline(
                      width: double.infinity,
                      height: 40,
                      onPressedFunction: () {
                        onPressed();
                        if (onPressedPop) {
                          Navigator.pop(context);
                        }
                      },
                      text: "Okay",
                     )
                ],
              ),
            )),
      ),
    );
  }
}
