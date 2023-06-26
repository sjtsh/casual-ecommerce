import 'dart:ui';

import 'package:flutter/material.dart';

enum Approval {
  pending,
  approved,
  denied;

  @override
  String toString() {
    switch (this) {
      case Approval.pending:
        return "Pending";
      case Approval.approved:
        return "Approved";
      case Approval.denied:
        return "Denied";
    }
  }

  static List<Approval> filterValues = [pending, approved, denied];

  static Approval status(int? i) {
    switch (i) {
      case 0:
        return denied;
      case 1:
        return pending;
      case 2:
        return approved;
      default:
        return denied;
    }
  }

  int toInt() {
    switch (this) {
      case Approval.pending:
        return 1;
      case Approval.approved:
        return 2;
      case Approval.denied:
        return 0;
    }
  }

  Color get color {
    switch (this) {
      case Approval.pending:
        return Colors.black.withOpacity(0.5);
      case Approval.approved:
        return Colors.green;
      case Approval.denied:
        return Colors.red;
    }
  }
}
