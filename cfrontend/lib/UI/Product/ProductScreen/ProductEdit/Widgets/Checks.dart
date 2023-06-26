import 'package:ezdelivershop/BackEnd/Entities/MyProduct.dart';
import 'package:ezdelivershop/Components/keys.dart';
import 'package:ezdelivershop/UI/Product/ProductScreen/ProductEdit/Widgets/RemarkBottomSheetNew.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../BackEnd/Enums/RemarksFrom.dart';

class Checks extends StatelessWidget {
  final MyProduct? myProduct;

  Checks(this.myProduct);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AverageCheck(myProduct),
      onPressed: () {
        _showModal(RemarkBottomSheetNew(myProduct), context);
      },
    );
  }

  _showModal(Widget widget, BuildContext context) => showModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(36), topRight: Radius.circular(36))),
      context: context,
      builder: (_) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(CustomKeys.context?? context).viewInsets.bottom),
            child: widget,
          ));
}

class AverageCheck extends StatelessWidget {
  final MyProduct? prod;

  const AverageCheck(this.prod, {Key? key}) : super(key: key);

  Widget buildPending(BuildContext context) =>
      SvgPicture.asset(height: 20, width: 20, "assets/Icon/pending.svg");

  @override
  Widget build(BuildContext context) {
    if (RemarksFrom.staff.getStatus(prod) == 1) return buildPending(context);
    if (RemarksFrom.outlet.getStatus(prod) == 0 ||
        RemarksFrom.admin.getStatus(prod) == 0) {
      return const Icon(Icons.remove_circle, color: Colors.red);
    }
    if (RemarksFrom.admin.getStatus(prod) == 2) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    return const Icon(Icons.check_circle, color: Colors.grey);
  }
}
