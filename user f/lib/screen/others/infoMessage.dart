import 'package:ezdeliver/screen/component/helper/exporter.dart';

class InfoMessage {
  InfoMessage._();
  static noOrders() {
    return skeleton(
        boldTitle: "",
        image: Assets.imagesNoOrderWithFilter,
        title: "You've not placed any orders yet.",
        label: " ");
  }

  static noOrdersSelected() {
    return skeleton(
        boldTitle: "",
        image: Assets.imagesNoOrderWithFilter,
        title: "You've not selected any Order",
        label: " ");
  }

  static noInternet() {
    return skeleton(
        boldTitle: "No Internet Connection!",
        image: Assets.imagesNoInternet,
        title: "Try again later",
        label: " ");
  }

  static noReview() {
    return skeleton(
        boldTitle: "No Reviews for this shop",
        image: Assets.imagesPendingorder,
        title: "This shop has not received any reviews",
        label: "");
  }

  static orderPlaced() {
    return skeleton(
        boldTitle: "We are processing your order",
        image: Assets.imagesOrderPlaced,
        title: "Thank you for your patience!",
        label: " ");
  }

  static reviewPosted() {
    return skeleton(
        boldTitle: "Your Review has been posted.",
        image: Assets.imagesOrderPlaced,
        title: "",
        label: " ");
  }

  static emptySearch(String data) {
    return skeleton(
        boldTitle: "Hmmmm...",
        image: Assets.imagesNoSearchedProduct,
        title: "We could not find any matches for '$data'",
        label: "");
  }

  static noFavourites() {
    return skeleton(
        boldTitle: "Oops! You have not added any items to favourite.",
        image: Assets.imagesNofavourites,
        title: "Double tap to add products or category to favourites.",
        label: " ");
  }

  static noSimilarProducts() {
    return skeleton(
        boldTitle: "Oops! We could not find\nsimilar products.",
        image: Assets.imagesNofavourites,
        title: "",
        label: "");
  }

  static emptyCart() {
    return skeleton(
        boldTitle: "Oops! Cart is empty",
        image: Assets.imagesCartEmpty,
        title: "Add items to Cart",
        label: " ");
  }

  static noLocation({String? boldTitle, String? title}) {
    return skeleton(
        boldTitle: boldTitle ?? "Location Services are unavailable",
        image: Assets.imagesAllowLocation,
        title: title ??
            "To deliver as quickly as possible, we would like your current location",
        label: " ");
  }
  // static noService() {
  //   return skeleton(
  //       image: "noHistory",
  //       title: "You've not placed any orders yet.",
  //       label: "Sit Tight! We're coming soon! ");
  // }

  static outOfServiceArea() {
    return skeleton(
        boldTitle: "Sit Tight! We're coming soon!",
        image: Assets.imagesNoShopsHere,
        title:
            "Our team is working tirelessly to bring quick \n deliveries to your location.",
        label: "");
  }

  static noAddresses() {
    return skeleton(
        boldTitle: "No saved addresses",
        image: Assets.imagesNosavedlocation,
        title: "There are no saved addresses. Add address first.",
        label: "");
  }

  static addresslimitExcceded() {
    return skeleton(
        boldTitle: "Address limit excceded!",
        image: Assets.imagesNosavedlocation,
        title: "You can add only two saved addresses",
        label: " ");
  }

  static noOrdersToday() {
    return skeleton(
        boldTitle: "",
        image: Assets.imagesNoOrderWithFilter,
        title: "You've not placed any orders today.",
        label: " ");
  }

  static noOrdersWithFilter() {
    return skeleton(
        boldTitle: "",
        image: Assets.imagesNoOrderWithFilter,
        title: "No orders found with current applied filters",
        label: "");
  }

  static Widget skeleton({
    BuildContext? context,
    String? image,
    required String title,
    required String label,
    required String boldTitle,
  }) {
    context ??= CustomKeys.context;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (image != null)
          Container(
            constraints: BoxConstraints(maxHeight: 200.sh()),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 70.sw(), vertical: 10.sh()),
              child: Image.asset(
                image,
              ),
            ),
          ),
        SizedBox(
          height: boldTitle.isNotEmpty ? 30.sh() : 20.sh(),
        ),
        if (boldTitle.isNotEmpty) ...[
          Text(
            boldTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: CustomTheme.primaryColor, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 14.sh(),
          ),
        ],
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                  text: title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: CustomTheme.greyColor)),
              TextSpan(
                  text: label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: CustomTheme.primaryColor))
            ],
            // Text("You've not made any orders yet. Order Now?")
          ),
        )
      ],
    );
  }
}
