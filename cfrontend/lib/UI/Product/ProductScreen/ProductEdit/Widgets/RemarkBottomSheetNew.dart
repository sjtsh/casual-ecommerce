
import 'package:ezdelivershop/BackEnd/Entities/MyProduct.dart';
import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../BackEnd/Enums/RemarksFrom.dart';
import '../../../../../BackEnd/StaticService/StaticService.dart';
import 'Checks.dart';

class RemarkBottomSheetNew extends StatefulWidget {
  final MyProduct? myProduct;

  const RemarkBottomSheetNew(this.myProduct,
      {Key? key})
      : super(key: key);

  @override
  State<RemarkBottomSheetNew> createState() => _RemarkBottomSheetNewState();
}

class _RemarkBottomSheetNewState extends State<RemarkBottomSheetNew> {
  Widget buildPending() =>
      SvgPicture.asset(height: 20, width: 20, "assets/Icon/pending.svg");

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
               RemarksFrom.averageText(widget.myProduct),
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              SpacePalette.spaceMedium,
              AverageCheck(widget.myProduct)
            ],
          ),
          SpacePalette.spaceLarge,
          Row(
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(.3),
                            borderRadius: BorderRadius.circular(6)),
                        child: Center(
                          child: StaticService.cache(widget
                              .myProduct?.remarks?.remarksStaffReferenceUrl),
                        )),
                    SpacePalette.spaceTiny,
                    Text(
                      "Reference Photo",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
              SpacePalette.spaceTiny,
              Expanded(
                flex: 12,
                child: Builder(builder: (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RemarksFrom.staff,
                      RemarksFrom.outlet,
                      RemarksFrom.admin
                    ]
                        .map((e) => Padding(
                          padding:  EdgeInsets.only(bottom: SpacePalette.spaceTiny.height ?? 0.0),
                          child: buildData(
                              changer: e.getChanger(widget.myProduct),
                              remark: e.getRemarks(widget.myProduct),
                              status: e.getStatus(widget.myProduct)),
                        ))
                        .toList(),
                  );
                }),
              ),
            ],
          ),
          SpacePalette.spaceExtraLarge,
        ]));
  }

  Widget buildData(
      {required String changer, required String remark, required int status}) {
    IconData? iconData;
    Color? colora;
    if (status == 0) {
      iconData = Icons.remove_circle;
      colora = Colors.red;
    } else if (status == 2) {
      iconData = Icons.check_circle;
      colora = Colors.green;
    }
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                changer,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(fontSize: 11, color: Colors.grey),
                maxLines: 3,
              ),
              Text(remark,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      ?.copyWith(fontSize: 10)),
            ],
          ),
        ),
        iconData == null
            ? SvgPicture.asset(height: 20, width: 20, "assets/Icon/pending.svg")
            : Icon(
                iconData,
                color: colora,
              ),
      ],
    );
  }
}
