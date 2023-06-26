import 'package:ezdelivershop/BackEnd/Services/SuggestionService.dart';
import 'package:ezdelivershop/Components/Widgets/Button.dart';
import 'package:ezdelivershop/Components/Widgets/TextField.dart';
import 'package:ezdelivershop/Components/snackbar/customsnackbar.dart';
import 'package:flutter/material.dart';

class SuggestProductForm extends StatefulWidget {
  @override
  State<SuggestProductForm> createState() => _SuggestProductFormState();
}

class _SuggestProductFormState extends State<SuggestProductForm> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 22,
          right: 22,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50,
            ),
            Text(
              "Suggest Products",
              style: Theme.of(context)
                  .textTheme
                  .headline4!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 18,
            ),
            Text(
              "Didn't find what you are looking for? Please suggest the products",
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 30,
            ),
            AppTextField(
                textField: TextField(
              onChanged: (v) => setState(() {}),
              controller: controller,
              decoration: const InputDecoration(
                  hintText: "Product suggestions for Pasalko"),
            )),
            SizedBox(
              height: 30,
            ),
            AppButtonPrimary(
                onPressedFunction: controller.text.trim().isNotEmpty &&
                        controller.text.trim().length > 3
                    ? () async {
                        bool done = await SuggestionService()
                            .postSuggestion(controller.text.trim());
                        if (done) {
                          Navigator.pop(context);
                          CustomSnackBar().success("Suggestion submitted");
                        }
                      }
                    : null,
                text: "Send",
                isdisable: controller.text.trim().length <= 3),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
