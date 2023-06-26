import 'dart:async';


import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/mapScreen/mapScreen.dart';

import 'package:ezdeliver/screen/others/geocoding.dart';

import 'package:ezdeliver/screen/search/searchService.dart';

class CustomLocationSearch extends StatelessWidget {
  const CustomLocationSearch({
    Key? key,
    this.color,
  }) : super(key: key);
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showSearch(
              context: context, delegate: CustomLocationSerachDelegate());
        },
        child: CustomSearchField());
  }
}

String searchQuery = "";

class CustomLocationSerachDelegate extends SearchDelegate {
  // ignore: annotate_overrides, overridden_fields
  final searchFieldLabel = 'Search Address';

  final maintainState = true;

  Completer<List<CustomAddressData>> _completer = Completer();
  late final Debouncer _debouncer = Debouncer(const Duration(milliseconds: 500),
      initialValue: '', onChanged: (value) {
    // print("query");
    _completer.complete(CustomKeys.ref
        .read(searchServiceProvider)
        .searchAddress(value)); // call the API endpoint
  });

  List<CustomAddressData>? _address;

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

      return searchResult();
    }
    return Container();
  }

  Widget searchResult() {
    return FutureBuilder<List<CustomAddressData>?>(
        future: _completer.future,
        builder: (context, snapshot) {
          // print(snapshot.data!.length);
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: InfoMessage.noInternet());
          }
          List<CustomAddressData> address = [];
          if (snapshot.hasData) {
            _address ??= [];

            if (snapshot.data!.isNotEmpty) {
              _address!.clear();
              _address!.addAll(snapshot.data!);
            } else {
              _address = null;
            }
          } else {
            if (_address != null) {
              if (_address!.isEmpty) {
                _address = null;
              }
            }
          }

          if (_address != null) {
            address = _address!.toList();
          }

          return AnimatedSwitcher(
              duration: widgetSwitchAnimationDuration,
              child: snapshot.hasData || _address != null
                  ? address.isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.only(
                              top: 18.sh(),
                              left: 20.sr(),
                              right: 20.sr(),
                              bottom: 18.sh()),
                          itemCount: address.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () async {
                                var location = LatLng(
                                    double.parse(address[index].lat),
                                    double.parse(address[index].lon));
                                var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return MapScreen(
                                        initialCoordinate: location,
                                      );
                                    },
                                  ),
                                );

                                if (result is CustomAddressData) {
                                  Utilities.futureDelayed(10, () {
                                    Navigator.pop(CustomKeys.context, result);
                                    Utilities.futureDelayed(10, () {
                                      Navigator.pop(CustomKeys.context, result);
                                    });
                                  });
                                }
                                // if (!showAddress) {
                                //   if (result is CustomAddressData) {
                                //     Utilities.futureDelayed(10, () {
                                //       Navigator.pop(context, result);
                                //     });
                                //   }
                                // } else {
                                //   if (result != null) {
                                //     Utilities.futureDelayed(20, () {
                                //       Navigator.pop(context);
                                //     });
                                //   }
                                // }
                              },
                              leading: const Icon(Icons.location_on),
                              title: Text(address[index].displayName),
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


