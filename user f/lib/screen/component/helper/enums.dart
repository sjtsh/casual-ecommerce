import 'package:ezdeliver/screen/component/helper/exporter.dart';

enum Auth { login, signup, password }

enum Status {
  pending,
  failed,
  processing,
  packing,
  ontheway,
  completed,
  cancelledByShop,
  cancelledByMe,
  cancelledBySystem,
}

enum StatusForFilter {
  pending,
  failed,
  processing,
  packing,
  ontheway,
  completed,
  cancelled,
}

class StatusClass {
  StatusClass(
      {required this.label, required this.detail, required this.iconData});

  String label, detail;
  IconData iconData;
}

final Map statusDetailMap = {
  Status.pending: StatusClass(
      detail: 'This order is pending',
      label: 'Pending',
      iconData: Icons.incomplete_circle),
  Status.failed: StatusClass(
      detail: "We couldn't find any Delivery guy.",
      label: 'Failed',
      iconData: Icons.report),
  Status.processing: StatusClass(
      detail: '', label: 'Processing', iconData: Icons.info_rounded),
  Status.packing: StatusClass(
      detail: 'Your order is being packed.',
      label: 'Packing',
      iconData: Icons.check),
  Status.ontheway: StatusClass(
      detail: 'Your order is on the way',
      label: 'On The Way',
      iconData: Icons.local_shipping),
  Status.completed: StatusClass(
      detail: 'This order has been delivered',
      label: 'Completed',
      iconData: Icons.check_circle),
  Status.cancelledByShop: StatusClass(
      detail: 'This order was cancelled by the shop.',
      label: 'Cancelled',
      iconData: Icons.error),
  Status.cancelledByMe: StatusClass(
      detail: 'You cancelled this order',
      label: 'Cancelled',
      iconData: Icons.error),
  Status.cancelledBySystem: StatusClass(
      detail: 'This order was cancelled by system',
      label: 'Cancelled',
      iconData: Icons.error),
};

Status getStatus(status) {
  if (status == -1) {
    return Status.cancelledByShop;
  } else if (status == -2) {
    return Status.cancelledByMe;
  } else if (status == -3) {
    return Status.cancelledBySystem;
  }
  var s = Status.values.firstWhere(
    (element) => (element.index == status),
  );
  return s;
}

Status getStatusForFeedback(status) {
  if (status == -2) {
    return Status.cancelledByShop;
  } else if (status == -4) {
    return Status.cancelledBySystem;
  } else if (status == -5) {
    return Status.cancelledByMe;
  }
  //
  // } else if (status == -3) {
  //   return Status.cancelledBySystem;
  // }
  var newStatus = status + 1;
  var s = Status.values.firstWhere((element) => (element.index == (newStatus)));
  return s;
}

StatusClass getStatusDetail(Status status) {
  return statusDetailMap[status];
}

enum WebPage { home, search, order, subCategoriesProduct, singleProduct, faq }

enum ConditionsForNotAvail { allNotAvail, someNotAvail, allAvail }

enum BannerType {
  landing(label: "Home Top Slider"),
  subgroup(label: "Sub Category Banner"),
  category(label: "Category Banner"),
  group(label: "Group Banner");

  const BannerType({required this.label});

  final String label;
}
