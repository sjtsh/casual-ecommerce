import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String? labelText;
  final TextField textField;

  const AppTextField({
    Key? key,
    this.labelText,
    required this.textField,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelText == null ? Container() : Text(labelText!),
        labelText == null
            ? Container()
            : const SizedBox(
                height: 8,
              ),
        textField
      ],
    );
  }
}
