import 'package:dotted_border/dotted_border.dart';
import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../StateManagement/SignInManagement.dart';

class UserImage extends StatelessWidget {
  const UserImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: DottedBorder(
        borderType: BorderType.Circle,
        radius: const Radius.circular(20),
        dashPattern: [4, 4],
        color: Theme.of(context).primaryColor,
        strokeWidth: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
                // color: Colors.white,
                border: Border.all(color:ColorPalette.dividerColor, width: 1),
                shape: BoxShape.circle,
                image: context.read<SignInManagement>().loginData?.user.image == null
                    ? null
                    : DecorationImage(
                        image: CachedNetworkImageProvider(
                          context.watch<SignInManagement>().loginData!.user.image!,
                        ),
                        fit: BoxFit.cover)),
            child: context.read<SignInManagement>().loginData?.user.image== null
                ? Center(
                    child: Text(
                      (context.read<SignInManagement>().loginData!.user.name).isEmpty
                          ? ""
                          : context.read<SignInManagement>().loginData!.user.name[0],
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Container(),
          ),
        ),
      ),
    );
  }
}
