import 'package:ezdeliver/screen/addressDetails/components/addressList.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';

/// Address widget check build method
/// ``` dart
/// final int test=0;
/// //Basic usage example
/// for(int i=0;i<test.length,i++)
/// {
/// //Your code here}
/// }
/// ```
class Addresses extends ConsumerWidget {
  const Addresses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final userService = ref.watch(userChangeProvider);
    // final address = userService.loggedInUser.value!.address;
    return
        // address.isNotEmpty
        //     ?
        SafeArea(
      child: Scaffold(
        appBar: simpleAppBar(context,
            title: "Addresses",
            search: false,
            close: ResponsiveLayout.isMobile ? true : false),
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Theme.of(context).primaryColor,
        //   splashColor: CustomTheme.whiteColor,
        //   child: const Icon(
        //     GroceliIcon.add,
        //     // Icons.add,
        //     color: CustomTheme.whiteColor,
        //   ),
        //   onPressed: () async {
        //     await Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => AddressForm(
        //                   edit: false,
        //                 )));
        //     ref.read(locationServiceProvider).clearController();
        //   },
        // ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.sw()),
          child: const Column(
            children: [
              Expanded(
                  child: AddressList(
                isDetail: true,
              ))
            ],
          ),
        ),
      ),
    )
        // : AddressForm()
        ;
  }
}
