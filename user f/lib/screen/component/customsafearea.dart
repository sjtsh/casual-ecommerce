import 'package:ezdeliver/screen/component/helper/exporter.dart';

class CustomSafeArea extends ConsumerWidget {
  const CustomSafeArea({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context, ref) {
    return SafeArea(child: child);
  }
}
