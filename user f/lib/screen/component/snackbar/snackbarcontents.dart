// ignore_for_file: prefer_const_constructors

import 'package:ezdeliver/screen/component/helper/exporter.dart';

class CustomSnackBarContent extends StatelessWidget {
  const CustomSnackBarContent({
    Key? key,
    required this.message,
    required this.icon,
    required this.color,
  }) : super(key: key);

  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kBottomNavigationBarHeight,
      width: 345.sw(),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            // Container(
            //   height: 26.sh(),
            //   width: 3.sh(),
            //   decoration: BoxDecoration(
            //     color: color,
            //     borderRadius: BorderRadius.circular(8.sr()),
            //   ),
            // ),
            // SizedBox(
            //   width: 11.6.sw(),
            // ),
            Icon(
              icon,
              size: 26.sr(),
              color: color,
            ),
            SizedBox(
              width: 15.sw(),
            ),
            Expanded(
              child: Text(
                message.toString(),
                maxLines: 2,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontWeight: FontWeight.w500, color: color),
              ),
            ),
            Spacer(),
            Icon(
              Icons.close,
              color: CustomTheme.greyColor,
              size: 26.sh(),
            )
          ],
        ),
      ),
    );
  }
}
