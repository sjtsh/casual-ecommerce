import 'dart:async';

import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/orderModel.dart';

int? getTimer(Order order) {
  int a = DateTime.now().difference(order.createdAt!).inMilliseconds;
  // print("Datetime.now :${DateTime.now()}");
  // print("order.createdAt! :${order.createdAt!}");
  // print(a);
  if (a <= order.waitTime) {
    return a;
  } else {
    return null;
  }
}

class CountDown extends StatefulWidget {
  const CountDown({this.waitTime = Duration.zero, super.key});
  final Duration waitTime;
  @override
  State<CountDown> createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
  late Timer timer;
  int current = 0;
  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (current >= widget.waitTime.inSeconds) {
          timer.cancel();
        } else {
          setState(() {
            current++;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = (widget.waitTime - Duration(seconds: current)).inSeconds;
    if (value == 0) return Container();
    return Text(
      getDuration(value),
      style:
          Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 12.ssp()),
    );
  }

  String getDuration(int current) {
    if (current > 59) {
      return "${current ~/ 60} m ${current % 60} s";
    } else {
      return "$current s";
    }
  }
}
