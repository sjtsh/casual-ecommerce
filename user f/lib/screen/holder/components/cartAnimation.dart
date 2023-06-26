import 'dart:ui';

import 'package:ezdeliver/screen/component/helper/exporter.dart';

class CartAnimator extends HookConsumerWidget {
  CartAnimator({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // const animationDuration = Duration(milliseconds: 650);

    return Stack(
      clipBehavior: Clip.none,
      children: [child, const CartHolder()],
    );
  }
}

class CartHolder extends HookConsumerWidget {
  const CartHolder({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAnimationService = ref.watch(cartAnimationProvider);
    final animator = useAnimationController(
        lowerBound: 0,
        upperBound: 0.85,
        duration: cartAnimationService.animationDuration,
        animationBehavior: AnimationBehavior.preserve);
    return Builder(builder: (context) {
      animator.reset();
      return AnimatedBuilder(
          animation: animator,
          builder: (context, widget) {
            if (cartAnimationService.child == null) {
              return Positioned(
                child: Container(),
              );
            }

            animator.forward().whenComplete(() {
              ref.read(cartAnimationProvider).clear();
            });
            var left = lerpDouble(cartAnimationService.offsets.first.dx,
                cartAnimationService.offsets.last.dx, animator.value);

            var top = lerpDouble(cartAnimationService.offsets.first.dy,
                cartAnimationService.offsets.last.dy, animator.value);

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 50),
              left: left,
              top: top,
              child: Opacity(
                opacity: lerpDouble(1, 0.75, animator.value)!,
                child: Transform.scale(
                    scale: lerpDouble(1, 0.25, animator.value)!,
                    child: cartAnimationService.child!),
              ),
            );
          });
    });
  }
}

final cartAnimationProvider =
    ChangeNotifierProvider<CartAnimationService>((ref) {
  return CartAnimationService._();
});

class CartAnimationService extends ChangeNotifier {
  CartAnimationService._();

  Widget? child;
  final List<Offset> offsets = [];
  Duration animationDuration = const Duration(milliseconds: 600);
  Future addToCart(Widget newChild, Offset start, Offset end) async {
    offsets.clear();
    child = newChild;

    var duration = Duration(
        milliseconds:
            lerpDouble(250, 750, (end.dy - start.dy) / 1000)!.toInt());

    animationDuration = duration;
    offsets.addAll([start, end]);
    notifyListeners();
    await Future.delayed(duration);
  }

  clear() {
    offsets.clear();
    child = null;
    notifyListeners();
  }
}
