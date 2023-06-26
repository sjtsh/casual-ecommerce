import 'package:intl/intl.dart';

import '../Entities/MyProduct.dart';

enum RemarksFrom {
  staff,
  admin,
  outlet;

  static String averageText(MyProduct? prod) {
    if (RemarksFrom.admin.getStatus(prod) == 2) return "Visible to the users";
    return  "Not visible to the users";
  }

  int getStatus(MyProduct? prod) {
    int two = (prod?.verificationOutlet ?? 1);
    int three = (prod?.verificationAdmin ?? 1);
    switch (this) {
      case RemarksFrom.staff:
        return prod == null ? 1 : 2;
      case RemarksFrom.outlet:
        return two == 1 ? three : two;
      case RemarksFrom.admin:
        return three;
    }
  }

  String dateFormat(DateTime? dateTime) {
    if (dateTime == null) return "";
    DateTime date = dateTime.add(const Duration(hours: 5, minutes: 45));
    return "${DateFormat.yMd().format(date)} at ${DateFormat.jm().format(date)}";
  }

  String getChanger(MyProduct? prod) {
    RemarksWithUserModel? remarkSuperAdmin = prod?.remarks?.remarksSuperAdmin;
    RemarksWithUserModel? remarkOutletAdmin = prod?.remarks?.remarksOutletAdmin;
    switch (this) {
      case RemarksFrom.staff:
        if (prod?.remarks?.remarksStaff == null) return "Partner";
        return "Partner (${getChangerDetail(prod)}";
      case RemarksFrom.outlet:

        if (remarkOutletAdmin != null) {
          return "Outlet (${getChangerDetail(prod)}";
        }
        if (remarkSuperAdmin == null) return "Outlet";
        return RemarksFrom.admin.getChanger(prod);
      case RemarksFrom.admin:
        if (remarkSuperAdmin == null) return "Admin";
        return "Admin (${getChangerDetail(prod)}";
    }
  }

  String getChangerDetail(MyProduct? prod) {
    switch (this) {
      case RemarksFrom.staff:
        return "${prod?.remarks?.remarksStaff!.phone}) on ${dateFormat(prod?.remarks?.remarksStaff!.createdAt)}";
      case RemarksFrom.outlet:
        return "${prod?.remarks?.remarksOutletAdmin?.phone}) on ${dateFormat(prod?.remarks?.remarksOutletAdmin?.createdAt)}";
      case RemarksFrom.admin:
        return "${prod?.remarks?.remarksSuperAdmin?.phone}) on ${dateFormat(prod?.remarks?.remarksSuperAdmin?.createdAt)}";
    }
  }

  String getRemarks(MyProduct? prod) {
    RemarksWithUserModel? remarkSuperAdmin = prod?.remarks?.remarksSuperAdmin;
    RemarksWithUserModel? remarkOutletAdmin = prod?.remarks?.remarksOutletAdmin;
    String status = showWhenNull(getStatus(prod));
    switch (this) {
      case RemarksFrom.staff:
        return prod?.remarks?.remarksStaff?.remarks!.split("|").first ?? status;
      case RemarksFrom.outlet:
        return (remarkOutletAdmin?.remarks?.split("\n"))?.first ??
            RemarksFrom.admin.getRemarks(prod);
      case RemarksFrom.admin:
        return (remarkSuperAdmin?.remarks?.split("\n"))?.first ?? status;
    }
  }

  String showWhenNull(int status) {
    return "No remarks";
  }
}
