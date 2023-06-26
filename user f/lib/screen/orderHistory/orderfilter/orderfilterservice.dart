// import 'package:ezdeliver/screen/component/helper/enums.dart';
// import 'package:ezdeliver/screen/component/helper/exporter.dart';

// final OrderHistoryServiceProvider =
//     ChangeNotifierProvider<OrderFilterService>((ref) {
//   return OrderFilterService._();
// });

// class OrderFilterService extends ChangeNotifier {
//   OrderFilterService._();

//   List<Status> _selectedItems = [];
//   set selectedItems(List<Status> items) {
//     _selectedItems.addAll(items.toList());
//   }

//   List<Status> get selectedItems => _selectedItems;

//   additems(Status status) {
//     if (_selectedItems.isEmpty) {
//       _selectedItems.add(status);
//     } else if (_selectedItems.contains(status)) {
//       _selectedItems.remove(status);
//     } else {
//       _selectedItems.add(status);
//     }
//   }
// }
