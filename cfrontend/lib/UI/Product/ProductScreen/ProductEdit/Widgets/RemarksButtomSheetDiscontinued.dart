import 'package:ezdelivershop/Components/Widgets/Button.dart';
import 'package:ezdelivershop/Components/Widgets/ButtonOutline.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../Components/Constants/SpacePalette.dart';
import '../../../../../StateManagement/EditProductManagement.dart';

class RemarksBottomSheetDiscontinued extends StatelessWidget {
  final Future<void> Function() onSave;

  RemarksBottomSheetDiscontinued({required this.onSave});

  buildRemarks(String s, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: (){
          context.read<EditProductManagement>().remarks = s;
        },
        child: Container(
          color: Colors.transparent,
          child: Row(
            children: [
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context
                                  .watch<EditProductManagement>()
                                  .remarks ==
                              s
                          ? Theme.of(context).primaryColor
                          : null,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              SpacePalette.spaceMedium,
              Text(s, style:Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).primaryColor),)
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        return Future.value(false);
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Please select the reason",
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
            SpacePalette.spaceLarge,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildRemarks("No stock", context),
                buildRemarks("Discontinued", context)
              ],
            ),
            SpacePalette.spaceLarge,
            Row(
              children: [
                Expanded(
                    child: AppButtonOutline(
                  height: 46,
                  borderRadius: 4,
                  onPressedFunction: () {
                    context.read<EditProductManagement>().toggleSwitch(true);
                    Navigator.of(context).pop();
                  },
                  text: "Close",
                )),
                SpacePalette.spaceMedium,
                Expanded(
                    child: AppButtonPrimary(
                  isdisable: context
                          .watch<EditProductManagement>()
                          .remarks ==
                      null,
                  onPressedFunction: onSave,
                  text: "Save",
                ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
