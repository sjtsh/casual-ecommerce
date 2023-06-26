import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final double? appBarHeight;
  final String? title;
  final Widget? titleWidget;
  final bool? rightButton;
  final bool? leftButton;
  final void Function()? rightButtonFunction;
  final void Function()? leftButtonFunction;
  final IconData? appIcons;
  final Widget? rightButtonWidget;
  final Widget? leftButtonWidget;
  final Color? color;

   const CustomAppBar({
    Key? key,
    this.title,
    this.titleWidget,
    this.leftButton,
    this.rightButton,
    this.rightButtonFunction,
    this.leftButtonFunction,
    this.appIcons,
    this.appBarHeight,
    this.rightButtonWidget,
    this.leftButtonWidget,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: appBarHeight ?? 60,
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(top: 0,),
            child: Row(
              children: [
                leftButtonWidget ??
                    (leftButton ?? false
                        ? IconButton(
                        padding: EdgeInsets.zero,
                            splashRadius: 26,
                            // splashColor: Colors.transparent,
                            onPressed: leftButtonFunction ??
                                () {
                                  Navigator.pop(context);
                                },
                            icon: const Icon(
                              Icons.arrow_back_ios_outlined,
                            ))
                        : IconButton(
                      padding: EdgeInsets.zero,
                            splashRadius: 26,
                            splashColor: Colors.transparent,
                            onPressed: () {},
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.transparent,
                            ))),
                Expanded(
                  child:title!=null?Text(
                    title ?? "",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ): titleWidget ?? Container(),
                ),
                rightButtonWidget ??
                    (rightButton ?? false
                        ? IconButton(
                            splashRadius: 26,
                            splashColor: Colors.transparent,
                            onPressed: rightButtonFunction ?? () {},
                            icon: Icon(
                              appIcons,
                            ))
                        : IconButton(
                            splashRadius: 26,
                            splashColor: Colors.transparent,
                            onPressed: () {},
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.transparent,
                            )))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
