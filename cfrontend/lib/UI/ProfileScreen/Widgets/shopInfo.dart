
import 'package:flutter/material.dart';

class ShopInfo extends StatelessWidget {
  final String text;
  final double size;
  final Color ? textColor;
  const ShopInfo({  required this.text,required this.size, this.textColor,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Center(
        child: Text(
         text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyText2?.copyWith( fontSize: size,
              fontWeight: FontWeight.bold,
              color: textColor?? Colors.black)
        ),
      ),
    );
  }
}
