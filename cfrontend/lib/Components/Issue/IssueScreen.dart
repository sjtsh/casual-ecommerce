import 'package:flutter/material.dart';

class IssueScreen  extends StatelessWidget {
  final String image;
  final String ? title;
  final String ? subTitle;
  const IssueScreen({ required this.image, this.title, this.subTitle, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Image.asset(image, height: 200, width: 200,),
            ),
            const SizedBox(
              height: 32,
            ),
            Text(
              title??" ",
              textAlign: TextAlign.center,
              maxLines: 3,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  ?.copyWith(fontWeight: FontWeight.w600,fontSize: 20),
            ),
            const SizedBox(
              height: 14,
            ),
            Text(
              subTitle??"",
              textAlign: TextAlign.center,
              maxLines: 3,
              style: Theme.of(context).textTheme.headline4?.copyWith(
                  fontWeight: FontWeight.w600, color: const Color(0xffBABABA)),
            ),
            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}
