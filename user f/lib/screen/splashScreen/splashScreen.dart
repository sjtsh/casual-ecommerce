// import 'dart:ui';

//  // import 'package:ezdeliver/screen/component/helper/exporter.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'dart:math' as math;

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Column(
//           children: [
//             Container(
//               height: 620.sh(),
//               width: MediaQuery.of(context).size.width,
//               child: Stack(
//                   // clipBehavior: Clip.none,
//                   children: List.generate(
//                 5,
//                 (index) => SplashComponent(
//                     image: "ellipse${index + 1}", height: 620.sh()),
//               )),
//             ),
//             Text(
//               "PASALKO",
//               style: Theme.of(context).textTheme.headline1!.copyWith(
//                   color: Theme.of(context).primaryColor,
//                   fontWeight: FontWeight.w500),
//             ),
//             SizedBox(
//               height: 150.sh(),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SplashComponent extends HookConsumerWidget {
//   const SplashComponent({Key? key, required this.height, required this.image})
//       : super(key: key);
//   final double height;
//   final String image;
//   @override
//   Widget build(BuildContext context, ref) {
//     final controller =
//         useAnimationController(duration: Duration(milliseconds: 1000));
//     controller.repeat(reverse: true);
//     // controller.forward();
//     return Positioned(
//       key: UniqueKey(),
//       left: lerpDouble(12.sw(), (MediaQuery.of(context).size.width - 118.sr()),
//           math.Random().nextDouble()),
//       top: lerpDouble(18.sh(), (MediaQuery.of(context).size.width - 118.sr()),
//           math.Random().nextDouble()),
//       child: AnimatedBuilder(
//           animation: controller,
//           builder: (context, c) {
//             return Transform.scale(
//               scale: lerpDouble(1, 1.1, controller.value),
//               child: Container(
//                 constraints: BoxConstraints(                                                                                                                  
//                   minWidth: 96.sr(),
//                   minHeight: 99.sr(),
//                   maxHeight: 118.sr(),
//                   maxWidth: 118.sr(),
//                 ),
//                 decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     image: DecorationImage(
//                       image: AssetImage("assets/images/$image.png"),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                           offset: Offset(0, 1),
//                           color: CustomTheme.greyColor.withOpacity(0.2),
//                           spreadRadius: 1.sr(),
//                           blurRadius: 2
//                           .sr())
//                     ]),
//               ),
//             );
//           }),
//     );
//   }
// }
