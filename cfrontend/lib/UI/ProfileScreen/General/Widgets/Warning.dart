import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:flutter/material.dart';

class Warning extends StatelessWidget {
  final String infoText;
  final bool showBorder;

  const Warning({this.showBorder = false, required this.infoText, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Theme.of(context).primaryColor,
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.info, color: Colors.white, size: 24),
              SpacePalette.spaceTiny,
              Expanded(
                  child: Text(infoText,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(color: Colors.white,height: 1.2)))
            ],
          ),
        ));
  }
}
// Center(
// child: RichText(
// text: TextSpan(children: [
// WidgetSpan(
// child: Icon(Icons.info,
// color: Colors.grey.shade300, size: 20),
// ),
// WidgetSpan(
// child: SpacePalette.spaceTiny,
// ),
// TextSpan(
// text: infoText, style: Theme.of(context).textTheme.bodyText1)
// ]),maxLines: 10,
// ),
// ),
