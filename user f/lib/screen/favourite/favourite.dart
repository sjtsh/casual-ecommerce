import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/home/components/FeaturedBox.dart';

class FavouriteScreen extends ConsumerWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userChangeProvider).loggedInUser.value!;
    final products = user.favourites.products;

    final categorys = user.favourites.categories;
    bool empty = products.isEmpty && categorys.isEmpty;
    // print(empty);

    return SafeArea(
        child: Scaffold(
      appBar: simpleAppBar(
        context,
        title: "Favourite",
        close: ResponsiveLayout.isMobile ? true : false,
      ),
      body: empty
          ? Center(
              child: Padding(
              padding: EdgeInsets.all(30.sr()),
              child: InfoMessage.noFavourites(),
            ))
          : Column(
              children: [
                if (categorys.isNotEmpty)
                  Expanded(
                      flex: 2,
                      child: ItemBox(
                        isLoading: false,
                        items: categorys,
                        trending: products.isEmpty ? true : false,
                        favourite: "Categories",
                      )),
                if (products.isNotEmpty)
                  Expanded(
                      flex: 5,
                      child: ItemBox(
                        isLoading: false,
                        items: products,
                        trending: true,
                        favourite: "Products",
                      )),
              ],
            ),
    ));
  }
}
