import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/Components/CustomTextField2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Components/CustomTheme.dart';
import '../../Components/Widgets/ButtonOutline.dart';

class DeactivateProductDialogBox extends StatelessWidget {
  final String title;
  final String subTitle;
  final Function() onPressed;
  final bool onPressedPop;
  final TextEditingController ?controller;
  DeactivateProductDialogBox({ this.controller,required this.title, required this.subTitle, required this.onPressed, this.onPressedPop = false});

// TextEditingController remarksController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
          decoration: BoxDecoration(
              color: context.watch<CustomTheme>().isDarkMode ?ColorPalette.darkContainerColor:Colors.white, borderRadius: BorderRadius.circular(6)),
          height: 200,
          width: 400,
          child: Padding(
            padding:
            const EdgeInsets.only(left: 32, right: 32, top: 32, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headline5?.copyWith(fontWeight: FontWeight.bold),
                ),
                SpacePalette.spaceMedium,
                Text(subTitle, style: Theme.of(context).textTheme.bodyText1,),
                CustomTextField2(
                  controller: controller,
                  labelText: "Remarks",
                  maxLines: 2,
                ),
                // Text(
                //     """Your feedback has been sent. Please wait for the confirmation from customer."""),,
                const Spacer(),
                AppButtonOutline(
                  width: double.infinity,
                  height: 40,
                  onPressedFunction: () {
                    onPressed();
                    if(onPressedPop){
                      Navigator.pop(context);
                    }
                  },
                  text: "OKAY!",
                )
              ],
            ),
          )),
    );
  }
}
