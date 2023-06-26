import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/models/productModel.dart';
import 'package:ezdeliver/screen/products/components/productbox.dart';
import 'package:ezdeliver/screen/search/searchService.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.query,
  });
  final String query;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<Product>> productFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    searchProducts();
  }

  searchProducts() async {
    productFuture =
        CustomKeys.ref.read(searchServiceProvider).searchProducts(widget.query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: simpleAppBar(context,
            title: "Search Results for ${widget.query}",
            close: false,
            centerTitle: false),
        body: FutureBuilder<List<Product>>(
          future: productFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: InfoMessage.noInternet(),
              );
            }

            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return snapshot.data!.isNotEmpty
                ? GridView.builder(
                    padding: EdgeInsets.only(
                        top: 18.sh(),
                        left: 20.sr(),
                        right: 20.sr(),
                        bottom: 18.sh()),
                    itemCount: snapshot.data!.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      // maxCrossAxisExtent: 150,
                      mainAxisSpacing: 30.sw(),
                      crossAxisSpacing: 20.sh(),
                      // mainAxisExtent: 200,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      return ProductBox(
                        query: widget.query,
                        // loading: true,
                        onAddToCart: () {
                          CustomKeys.ref
                              .read(cartServiceProvider)
                              .addItem(snapshot.data![index]);
                        },
                        product: snapshot.data![index],
                      );
                    },
                  )
                : Center(
                    child: InfoMessage.emptySearch(widget.query),
                  );
          },
        ));
  }
}
