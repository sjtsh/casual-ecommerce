import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/home/components/suggestProductForm.dart';

class SuggestProductInfo extends StatelessWidget {
  const SuggestProductInfo({super.key, this.log = false});
  final bool log;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.sw()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Didn't find what you were looking for?",
            style: Theme.of(context).textTheme.headline2!.copyWith(
                letterSpacing: 0.5,
                fontWeight: FontWeight.w500,
                color: CustomTheme.greyColor),
          ),
          SizedBox(
            height: 14.sh(),
          ),
          Text(
            "Suggest something & we'll look into it",
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: CustomTheme.greyColor),
          ),
          SizedBox(
            height: 20.sh(),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * .52,
            child: CustomElevatedButton(
                onPressedElevated: () async {
                  if (log)
                    await FirebaseAnalytics.instance
                        .logEvent(name: "Suggest_a_product", parameters: {
                      "id": CustomKeys.ref
                          .read(userChangeProvider)
                          .loggedInUser
                          .value
                          ?.id,
                      "name": CustomKeys.ref
                          .read(userChangeProvider)
                          .loggedInUser
                          .value
                          ?.name
                    });
                  showModalBottomSheet(
                      backgroundColor: Theme.of(context).backgroundColor,
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return SuggestProductForm();
                      });
                },
                elevatedButtonText: "Suggest a Product"),
          ),
          SizedBox(
            height: 30.sh(),
          ),
        ],
      ),
    );
  }
}
