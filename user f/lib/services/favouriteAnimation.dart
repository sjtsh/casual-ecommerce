import 'package:ezdeliver/screen/component/helper/exporter.dart';

class AnimationCollection {
  AnimationCollection();

  static animateFavourite(bool fav,
      {required AnimationController animation}) async {
    if (!fav) {
      animation.reset();
      await animation.forward();
      Duration waitTime = const Duration(milliseconds: 150);
      await animation.animateBack(0.8, duration: waitTime);
      await animation.animateTo(1, duration: waitTime);
      await animation.animateBack(0.9, duration: waitTime);
      await animation.animateBack(1, duration: waitTime);

      animation.reset();
    }
  }

  static animateAddToCart({required AnimationController controller}) async {
    controller.reset();
    Duration waitTime = const Duration(milliseconds: 50);
    await controller.animateBack(0.8, duration: waitTime);
    await controller.animateTo(1.3, duration: waitTime);

    await controller.animateBack(1, duration: waitTime);
    // await controller.animateBack(1, duration: waitTime);
    // await controller.animateTo(0, duration: waitTime);
    // controller.reset();
  }
}

class FavouriteAnimator extends ConsumerWidget {
  const FavouriteAnimator(
      {super.key, required this.child, required this.animation});
  final Widget child;
  final AnimationController animation;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        child,
        Center(
          child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: animation.value,
                  child: Icon(
                    Icons.favorite,
                    size: 70.sr(),
                    color: CustomTheme.primaryColor.withOpacity(0.45),
                  ),
                );
              }),
        )
      ],
    );
  }
}
