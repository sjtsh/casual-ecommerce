import 'package:ezdeliver/screen/component/helper/exporter.dart';

var percentFactor = 25;

extension ResponsiveDouble on double {
  sw({double? min}) {
    double value = this;

    return calculateResult(value, value.w, min: min);
  }

  sh({double? min}) {
    double value = this;
    return calculateResult(value, value.h, min: min);
  }

  ssp({double? min}) {
    double value = this;
    return calculateResult(value, value.sp, min: min);
  }

  sr({double? min}) {
    double value = this;

    return calculateResult(value, value.r, min: min);
  }
}

extension ResponsiveInt on int {
  sw({double? min}) {
    var value = this;

    return calculateResult(value, value.w, min: min);
  }

  sh({double? min}) {
    var value = this;
    return calculateResult(value, value.h, min: min);
  }

  ssp({double? min}) {
    var value = this;
    var val = calculateResult(value, value.sp, min: min);
    // print("$value $val");
    return val;
  }

  sr({double? min}) {
    var value = this;

    return calculateResult(value, value.r, min: min);
  }
}

double calculateResult(value, result, {var min}) {
  var factor = (percentFactor / 100) * value;
  // print(factor.toString() + ' ' + result.toString());
  if (min == null) {
    if (result < value - factor) return value - factor;
    if (result > factor + value) return factor + value;

    return result;
  } else {
    if (result < min) return min;
    if (result > factor + value) return factor + value;
    return result;
  }
}
