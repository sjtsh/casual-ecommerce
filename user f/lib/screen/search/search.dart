import 'dart:async';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/productModel.dart';
import 'package:ezdeliver/screen/products/components/productbox.dart';
import 'package:ezdeliver/screen/search/searchService.dart';

class CustomSearchButton extends StatelessWidget {
  const CustomSearchButton({
    Key? key,
    this.color,
  }) : super(key: key);
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          showSearch(context: context, delegate: CustomSerachDelegate());
        },
        child: Icon(
          Icons.search,
          color: color ?? Theme.of(context).primaryColor,
        ));
  }
}

String searchQuery = "";

class CustomSerachDelegate extends SearchDelegate {
  // ignore: annotate_overrides, overridden_fields
  final searchFieldLabel = 'Search Products';

  final maintainState = true;

  Completer<List<Product>> _completer = Completer();
  late final Debouncer _debouncer = Debouncer(const Duration(milliseconds: 500),
      initialValue: '', onChanged: (value) {
    // print("query");
    _completer.complete(CustomKeys.ref
        .read(searchServiceProvider)
        .searchProducts(value)); // call the API endpoint
  });

  List<Product>? _products;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query != "")
        IconButton(
          onPressed: () {
            query = '';
            // CustomKeys().ref!.read(searchServiceProvider).clearProducts();
          },
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final isdark = CustomKeys.ref.watch(customThemeServiceProvider).isDarkMode;
    var theme = isdark ? CustomTheme.darkTheme : CustomTheme.lightTheme;
    final newtheme = theme.copyWith(
      inputDecorationTheme: const InputDecorationTheme().copyWith(
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
      textSelectionTheme:
          TextSelectionThemeData(cursorColor: Theme.of(context).primaryColor),
      hintColor: CustomTheme.greyColor,
      appBarTheme: AppBarTheme(
          // systemOverlayStyle: SystemUiOverlayStyle(
          //     statusBarColor:
          //         CustomKeys.ref.read(customThemeServiceProvider).isDarkMode
          //             ? Theme.of(context).scaffoldBackgroundColor
          //             : CustomTheme.primaryColor),
          elevation: 0,
          iconTheme: IconThemeData(color: CustomTheme.getBlackColor()),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor),
      // backgroundColor: Theme.of(context).primaryColor,
      // textTheme: TextTheme(
      //   headline6: TextStyle(
      //     color: CustomTheme.getBlackColor(),
      //     fontSize: 18.0.ssp(),
      //   ),
      // )
    );

    return newtheme;
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back_ios));
  }

  @override
  Widget buildResults(BuildContext context) {
    return searchResult();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) {
      searchQuery = query;
      _debouncer.value = query; // update the _debouncer
      _completer = Completer();
      print(_completer);
      return searchResult();
    }
    return Container();
  }

  Widget searchResult() {
    return FutureBuilder<List<Product>?>(
        future: _completer.future,
        builder: (context, snapshot) {
          // print(snapshot.data!.length);
          if (snapshot.hasError) {
            // print(snapshot.error);
            return Center(child: InfoMessage.noInternet());
          }
          List<Product> products = [];
          if (snapshot.hasData) {
            _products ??= [];

            if (snapshot.data!.isNotEmpty) {
              _products!.clear();
              _products!.addAll(snapshot.data!);
            } else {
              _products = null;
            }
          } else {
            if (_products != null) {
              if (_products!.isEmpty) {
                _products = null;
              }
            }
          }

          if (_products != null) {
            products = _products!.toList();
          }

          return AnimatedSwitcher(
              duration: widgetSwitchAnimationDuration,
              child: snapshot.hasData || _products != null
                  ? products.isNotEmpty
                      ? GridView.builder(
                          padding: EdgeInsets.only(
                              top: 18.sh(),
                              left: 20.sr(),
                              right: 20.sr(),
                              bottom: 18.sh()),
                          itemCount: products.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            // maxCrossAxisExtent: 150,
                            mainAxisSpacing: 30.sw(),
                            crossAxisSpacing: 20.sh(),
                            // mainAxisExtent: 200,
                            childAspectRatio: 0.65,
                          ),
                          itemBuilder: (context, index) {
                            return ProductBox(
                              query: query,
                              // loading: true,
                              onAddToCart: () {
                                CustomKeys.ref
                                    .read(cartServiceProvider)
                                    .addItem(products[index]);
                              },
                              product: products[index],
                            );
                          },
                        )
                      : Center(
                          child: InfoMessage.emptySearch(query),
                        )
                  : Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    ));
        });
  }
  // Widget searchResult() {
  //   final searchedProducts =
  //       CustomKeys.ref.watch(searchServiceProvider).searchProduct;
  //   return FutureBuilder<List<Product>>(
  //       future: _completer.future,
  //       builder: (context, AsyncSnapshot snapshot) {
  //         if (snapshot.hasError) {
  //           return Center(child: InfoMessage.noInternet());
  //         }
  //         if (searchedProducts != null) {
  //           return searchedProducts.isNotEmpty
  //               ? GridView.builder(
  //                   padding: EdgeInsets.only(
  //                       top: 18.sh(),
  //                       left: 20.sr(),
  //                       right: 20.sr(),
  //                       bottom: 18.sh()),
  //                   itemCount: searchedProducts.length,
  //                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                       crossAxisCount: 2,
  //                       // maxCrossAxisExtent: 150,
  //                       mainAxisSpacing: 30.sw(),
  //                       crossAxisSpacing: 20.sh(),
  //                       // mainAxisExtent: 200,
  //                       childAspectRatio: 0.6),
  //                   itemBuilder: (context, index) {
  //                     return ProductBox(
  //                       // loading: true,
  //                       onAddToCart: () {
  //                         CustomKeys.ref
  //                             .read(cartServiceProvider)
  //                             .addItem(searchedProducts[index]);
  //                       },
  //                       product: searchedProducts[index],
  //                     );
  //                   },
  //                 )
  //               : Center(
  //                   child: InfoMessage.emptySearch(query),
  //                 );
  //         }

  //         return AnimatedSwitcher(
  //             duration: widgetSwitchAnimationDuration,
  //             child: Center(
  //               child: CircularProgressIndicator(
  //                 color: Theme.of(context).primaryColor,
  //               ),
  //             ));
  //       });
  // }
}
//  Widget buildSuggestions(BuildContext context) {
//     if (query.isNotEmpty) {
//       searchQuery = query;
//       _debouncer.value = query; // update the _debouncer
//       _completer = Completer();
//       return searchResult();
//     } else if (query != "") {
//       _debouncer.value = searchQuery; // update the _debouncer
//       _completer = Completer();
//       return searchResult();
//     }
//     return Container();
//   }


