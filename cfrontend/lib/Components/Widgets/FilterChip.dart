import 'package:flutter/material.dart';
import '../Constants/ColorPalette.dart';

class MyFilterChip extends StatelessWidget {
  final String title;
  final int index;
  final int selectedIndex;

  MyFilterChip(this.title, this.index, this.selectedIndex);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
          color: selectedIndex == index
              ? Theme.of(context).primaryColor
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(4),
          border: selectedIndex == index
              ? null
              : Border.all(width: 1, color: ColorPalette.grey)),
      child: Center(
        child: Text(
          title,
          style: selectedIndex == index
              ? Theme.of(context)
                  .textTheme
                  .headline5
                  ?.copyWith(color: Colors.white)
              : Theme.of(context).textTheme.headline5,
        ),
      ),
    );
  }
}
