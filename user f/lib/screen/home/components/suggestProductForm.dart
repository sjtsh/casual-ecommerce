import 'package:ezdeliver/screen/component/helper/exporter.dart';

final textProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

class SuggestProductForm extends ConsumerWidget {
  const SuggestProductForm({super.key});
  // final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // final textProvider = StateProvider<String>((ref) {
  //   return '';
  // });

  @override
  Widget build(BuildContext context, ref) {
    return Padding(
      padding: EdgeInsets.only(
          left: 22.sw(),
          right: 22.sw(),
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50.sh(),
            ),
            Text(
              "Suggest Products",
              style: Theme.of(context)
                  .textTheme
                  .headline4!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 18.sh(),
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
              height: 30.sh(),
            ),
            InputTextField(
              title: '',
              hintText:
                  "Enter the name of the products you would like to see on Faasto",
              // validator: (value) => validateArea(value!),
              onChanged: (val) {
                ref.read(textProvider.state).state = val;
              },
            ),
            SizedBox(
              height: 30.sh(),
            ),
            Consumer(builder: (context, ref, child) {
              final text = ref.watch(textProvider);
              return CustomElevatedButton(
                  onPressedElevated: text.isNotEmpty && text.length > 3
                      ? () async {
                          var done = await ref
                              .read(productCategoryServiceProvider)
                              .sendProductSuggestion(text);
                          print(done);
                          if (done) {
                            Utilities.futureDelayed(10, () {
                              Navigator.pop(context);
                              snack.success("Suggestion submitted");
                            });
                          }
                        }
                      : null,
                  // onPressedElevated: () {},
                  elevatedButtonText: "Send");
            }),
            SizedBox(
              height: 30.sh(),
            ),
          ],
        ),
      ),
    );
  }
}
