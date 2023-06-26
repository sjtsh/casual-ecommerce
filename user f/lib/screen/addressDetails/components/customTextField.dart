// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:ezdeliver/screen/component/helper/exporter.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField(
      {Key? key,
      required this.formHeader,
      this.isRequired = false,
      this.validator,
      this.initialValue,
      this.isDigit = false,
      this.onChanged,
      this.controller})
      : super(key: key);
  final String formHeader;
  String? initialValue;
  bool isRequired;
  final String? Function(String? val)? validator;
  final bool isDigit;
  final Function(String input)? onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: formHeader,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(fontSize: 14.ssp()),
            ),
            if (isRequired)
              TextSpan(
                text: " *",
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    fontSize: 14.ssp(), color: CustomTheme.errorColor),
              ),
          ]),
        ),
        SizedBox(
          height: 5.sh(),
        ),
        TextFormField(
          initialValue: initialValue,
          controller: controller,
          keyboardType: isDigit ? TextInputType.phone : TextInputType.multiline,
          inputFormatters: [
            if (isDigit) LengthLimitingTextInputFormatter(10),
            isDigit
                ? FilteringTextInputFormatter.digitsOnly
                : FilteringTextInputFormatter.singleLineFormatter
          ],
          onChanged: onChanged,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide.none)),
        ),
      ],
    );
  }
}
