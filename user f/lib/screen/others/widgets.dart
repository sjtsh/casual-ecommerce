// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:equatable/equatable.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/shop.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';

const double minButtonHeight = 45;
const double buttonHeight = 55;
EdgeInsets buttonDimension =
    EdgeInsets.symmetric(horizontal: 16.sw(), vertical: 18.sh());

Widget customCachedImage(
    {required String imageUrl, Key? key, double scale = 1, String? alternate}) {
  return CachedNetworkImage(
    key: key,
    imageUrl: imageUrl.contains("localhost")
        ? imageUrl.replaceAll("localhost", Api.localUrl)
        : imageUrl,
    placeholder: (context, s) {
      return LayoutBuilder(builder: (context, c) {
        return customShimmer(
          width: c.maxWidth,
          height: c.maxHeight,
        );
      });
    },
    errorWidget: (context, url, error) {
      return Transform.scale(
        scale: scale,
        child: CachedNetworkImage(
          imageUrl: alternate != null
              ? alternate.contains("localhost")
                  ? alternate.replaceAll("localhost", Api.localUrl)
                  : alternate
              : 'https://faasto.co/uploads/load_0.png',
          errorWidget: (context, url, error) {
            return Placeholder();
          },
        ),
      );
      // return Container();
    },
  );
}

class WebLinkButton extends StatelessWidget {
  const WebLinkButton(this.text,
      {Key? key, required this.style, this.color, this.onPressed})
      : super(key: key);
  final Color? color;
  final TextStyle? style;
  final Function? onPressed;
  final String text;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
          textStyle: MaterialStateProperty.resolveWith((states) =>
              style ??
              Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: CustomTheme.getBlackColor())),
          overlayColor:
              MaterialStateColor.resolveWith((states) => Colors.transparent),
          foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.hovered)) {
              return color ?? CustomTheme.primaryColor;
            }

            return CustomTheme.getBlackColor();
          })),
      onPressed: onPressed != null
          ? () {
              onPressed!();
            }
          : null,
      child: Text(
        text,
        // style: style,
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomOutlinedButton extends StatelessWidget {
  CustomOutlinedButton(
      {Key? key,
      this.onPressedOutlined,
      required this.outlinedButtonText,
      this.width,
      this.height,
      this.borderColor,
      this.custom = false})
      : super(key: key);
  final bool custom;
  final Function? onPressedOutlined;
  final String outlinedButtonText;
  double? width, height;
  Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressedOutlined == null ? false : true;
    return Container(
      // width: width ?? 126.sw(),
      // height: height ?? 46.sh(),

      decoration: BoxDecoration(
        // color: Colors.amber,
        borderRadius: BorderRadius.circular(4.sr()),
        border:
            Border.all(color: borderColor ?? Theme.of(context).primaryColor),
      ),
      child: Consumer(builder: (context, ref, c) {
        return TextButton(
            style: TextButton.styleFrom(
              tapTargetSize: custom ? MaterialTapTargetSize.shrinkWrap : null,
              padding: custom
                  ? EdgeInsets.symmetric(horizontal: 3.sw(), vertical: 0)
                  : buttonDimension,
              minimumSize: custom ? Size(40.sw(), 30.sh()) : null,
            ),
            onPressed: enabled
                ? () {
                    onPressedOutlined!();
                  }
                : null,
            child: Text(
              outlinedButtonText,
              style:
                  // elevatedButtonTextStyle ??
                  Theme.of(context).textTheme.headline5!.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: custom ? 12.ssp() : null,
                        // fontSize: 17.ssp(),
                      ),
            ));
      }),
    );
  }
}

class CustomElevatedButton extends ConsumerWidget {
  CustomElevatedButton(
      {Key? key,
      required this.onPressedElevated,
      required this.elevatedButtonText,
      this.width,
      this.height,
      this.elevatedButtonTextStyle,
      this.elevatedButtonPadding,
      this.color,
      this.icon,
      this.suffixIcon})
      : super(key: key);
  final progressProvider = StateProvider<bool>((ref) {
    return false;
  });
  final Function? onPressedElevated;
  final String elevatedButtonText;
  double? width, height;
  TextStyle? elevatedButtonTextStyle;
  EdgeInsetsGeometry? elevatedButtonPadding;
  Color? color;
  IconData? icon, suffixIcon;

  @override
  Widget build(BuildContext context, ref) {
    final enabled = onPressedElevated == null ? false : true;
    final progress = ref.watch(progressProvider);

    return SizedBox(
      // width: width,
      // height: height ?? 46.sh(),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: elevatedButtonPadding ?? buttonDimension,
            backgroundColor: enabled && !progress
                ? color ?? Theme.of(context).primaryColor
                : color != null
                    ? color!.withOpacity(0.5)
                    : Theme.of(context).primaryColor.withOpacity(0.5)),
        onPressed: enabled
            ? progress
                ? null
                : () async {
                    ref.read(progressProvider.state).state = true;
                    await onPressedElevated!();
                    ref.read(progressProvider.state).state = false;
                  }
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: Colors.white,
                size: 15.ssp(),
              ),
            progress
                ? SizedBox(
                    height: elevatedButtonTextStyle ??
                        Theme.of(context).textTheme.headline5!.fontSize!.ssp(),
                    width: elevatedButtonTextStyle ??
                        Theme.of(context).textTheme.headline5!.fontSize!.ssp(),
                    child: const FittedBox(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  )
                : Row(children: [
                    Text(
                      elevatedButtonText,
                      style: elevatedButtonTextStyle ??
                          Theme.of(context).textTheme.headline5!.copyWith(
                                color: CustomTheme.whiteColor,
                                fontWeight: FontWeight.w600,
                                // fontSize: 15.ssp(),
                              ),
                    ),
                    if (suffixIcon != null) ...[
                      SizedBox(
                        width: 5.sw(),
                      ),
                      Icon(
                        suffixIcon,
                        color: Colors.white,
                        size: 15.ssp(),
                      ),
                    ]
                  ])
          ],
        ),
      ),
    );
  }
}

class OutlinedElevatedButtonCombo extends StatelessWidget {
  OutlinedElevatedButtonCombo({
    Key? key,
    required this.outlinedButtonText,
    required this.elevatedButtonText,
    required this.onPressedOutlined,
    this.onPressedElevated,
    this.width,
    this.height,
    this.spacing,
    this.elevatedButtonStyle,
    this.center = false,
  }) : super(key: key);

  final String outlinedButtonText, elevatedButtonText;
  final Function onPressedOutlined;
  final Function? onPressedElevated;
  double? width, height, spacing;
  TextStyle? elevatedButtonStyle;
  bool center;
  double defaultHeight = 46.sh();
  double defaultWidth = 126.sh();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        CustomOutlinedButton(
          width: width ?? defaultWidth,
          //96.sw(),
          height: height ?? defaultHeight,
          // 32.sh(),
          outlinedButtonText: outlinedButtonText,
          onPressedOutlined: () {
            onPressedOutlined();
          },
        ),
        SizedBox(
          width: spacing ?? 60.sw(),
        ),
        CustomElevatedButton(
            width: width ?? defaultWidth,
            // 96.sw(),
            height: height ?? defaultHeight,
            // 32.sh(),
            onPressedElevated: onPressedElevated == null
                ? null
                : () {
                    onPressedElevated!();
                  },
            elevatedButtonText: elevatedButtonText,
            elevatedButtonTextStyle: elevatedButtonStyle)
        //   ??
        //       kTextStyleIbmRegular.copyWith(
        //         fontSize: 17.ssp(),
        //         color: Colors.white,
        //       ),
        // ),
      ],
    );
  }
}

class CustomRating extends StatelessWidget {
  const CustomRating(
      {Key? key,
      required this.rating,
      this.onRatingUpdate,
      required this.itemSize,
      this.count = 0,
      this.showLabel = true,
      this.ignoreGestures = false,
      this.allowHalfRating = false,
      this.highlight = false,
      this.shop,
      this.short = false,
      this.align,
      this.margin})
      : super(key: key);

  final double rating;
  final int count;
  final double itemSize;
  final bool showLabel;
  final Function(double)? onRatingUpdate;
  final bool ignoreGestures;
  final bool allowHalfRating, highlight;
  final Shop? shop;
  final bool short;
  final MainAxisAlignment? align;
  final EdgeInsets? margin;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Row(
        mainAxisAlignment: align ?? MainAxisAlignment.start,
        children: [
          RatingBar(
              ignoreGestures: ignoreGestures,
              itemSize: itemSize,
              initialRating: rating,
              direction: Axis.horizontal,
              allowHalfRating: allowHalfRating,
              itemCount: short ? 1 : 5,
              ratingWidget: RatingWidget(
                  full: Icon(
                    Icons.star,
                    color: Colors.orange,
                    size: 8.ssp(),
                  ),
                  half: const HalfStar(),
                  // const HalfStar(),
                  empty: Icon(
                    Icons.star,
                    color: CustomTheme.emptyStarColor,
                    size: 8.ssp(),
                  )),
              onRatingUpdate: (value) {
                onRatingUpdate!(value);
              }),
          if (showLabel && rating > 0) ...[
            SizedBox(
              width: 5.sw(),
            ),
            Text(
              "${clapRatinValue(rating).toString().substring(0, 3)} ${count > 0 ? "($count)" : ""} ",
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                  color: highlight ? Colors.white : CustomTheme.greyColor,
                  fontWeight: FontWeight.w500),
            ),
          ]
        ],
      ),
    );
  }
}

class HalfStar extends StatelessWidget {
  const HalfStar({
    this.activeColor,
    this.emptyColor,
    Key? key,
  }) : super(key: key);
  final Color? activeColor, emptyColor;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(
          Icons.star,
          color: activeColor ?? Colors.orange,
          size: 8.ssp(),
        ),
        ClipPath(
          clipper: StarClipper(),
          child: Icon(
            Icons.star,
            color: emptyColor ?? CustomTheme.emptyStarColor,
            size: 8.ssp(),
          ),
        ),
      ],
    );
  }
}

class CustomMenuDropDown extends ConsumerWidget {
  CustomMenuDropDown({
    required this.hint,
    Key? key,
    required this.value,
    required this.onChanged,
    required this.values,
    this.icon,
  }) : super(key: key);
  final CustomMenuItem value;
  late final valueProvider = StateProvider<CustomMenuItem?>((ref) {
    return value;
  });
  final Function(CustomMenuItem val) onChanged;
  final List<CustomMenuItem> values;
  final String hint;

  final Icon? icon;
  late var initState = init();

  init() {
    onChanged(value);
  }

  @override
  Widget build(BuildContext context, ref) {
    final selectedValue = ref.watch(valueProvider.state).state;

    return Container(
      height: 55.sh(),
      // width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          4.sr(),
        ),
        border: Border.all(
          color: Theme.of(context)
              .inputDecorationTheme
              .focusedBorder!
              .borderSide
              .color,
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: DropdownButton<CustomMenuItem>(
          // dropdownColor: Theme.of(context).colorScheme.background,
          selectedItemBuilder: (context) {
            return values.map((e) {
              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 15.sw(), vertical: 12.sh()),
                child: Text(
                  "${e.label} ",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontSize: 16.ssp()),
                ),
              );
            }).toList();
          },
          hint: Text(
            "  $hint",
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(color: CustomTheme.greyColor),
          ),
          isExpanded: true,
          underline: Container(),
          value: selectedValue,
          icon: Padding(
            padding: EdgeInsets.only(right: 24.sw()),
            child: icon ??
                Icon(
                  Icons.expand_more,
                  size: 8.5.sr(),
                  color: Colors.black,
                ),
          ),
          items: values.map<DropdownMenuItem<CustomMenuItem>>((vall) {
            return DropdownMenuItem<CustomMenuItem>(
              value: vall,
              child: Text(vall.label),
            );
          }).toList(),
          onChanged: (val) {
            ref.read(valueProvider.notifier).state = val as CustomMenuItem;

            onChanged(val);
          }),
    );
  }
}

class CustomMenuItem extends Equatable {
  const CustomMenuItem({
    required this.label,
    required this.value,
  });
  final String label;
  final String value;

  @override
  // TODO: implement props
  List<Object?> get props => [label, value];
}

class StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.addRect(Rect.fromLTWH(size.width / 1.7, 0, size.width, size.height));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
// class CustomRatingBarIndicator extends StatelessWidget {
//   const CustomRatingBarIndicator({
//     Key? key,
//     required this.rating,
//     required this.itemSize,
//   }) : super(key: key);

//   final double rating;
//   final double itemSize;

//   @override
//   Widget build(BuildContext context) {
//     return RatingBarIndicator(
//         itemSize: itemSize,
//         rating: rating,
//         direction: Axis.horizontal,
//         itemCount: 5,
//         unratedColor: Colors.orange.withOpacity(0.5),
//         itemBuilder: (context, index) {
//           return Icon(
//             Icons.star,
//             color: Colors.orange,
//             size: 8.ssp(),
//           );
//         });
//   }
// }

class Button extends StatelessWidget {
  Button({
    Key? key,
    required this.onPressed,
    required this.label,
    this.primary = true,
    this.kLabelTextStyle,
    this.color,
    this.width,
  }) : super(key: key);
  double? width;
  final Function onPressed;
  final String label;

  final bool primary;
  TextStyle? kLabelTextStyle;
  Color? color;
  @override
  Widget build(BuildContext context) {
    return Container(
        //constraints: BoxConstraints(minHeight: minButtonHeight),
        decoration: primary
            ? BoxDecoration(boxShadow: [
                BoxShadow(
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                    blurRadius: 16,
                    color: Colors.white.withOpacity(0.25))
              ])
            : BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                )),
        width: width ?? double.infinity,
        height: buttonHeight.h,

        //.h,
        child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                    (states) => primary ? const Color(0xff40667D) : color!)),
            onPressed: onPressed != null
                ? () {
                    onPressed();
                  }
                : () {},
            child: Text(
              label,
              //textScaleFactor: textScaleFactor,

              // style: kLabelTextStyle ??
              //     kTextStyleIbmRegular.copyWith(
              //         fontSize: 17.ssp(), color: Colors.white),

              //textScaleFactor: textScaleFactor,
            )));
  }
}

String getImage(String name) {
  String nameShort = "";
  var names = name.split(" ");
  for (int i = 0; i < names.length; i++) {
    if (!names[i].startsWith(RegExp(r'[A-Z][a-z][0-9]'))) {
      try {
        nameShort += names[i].substring(0, 1).toUpperCase();
      } catch (e) {
        //
      }
    }
  }
  return nameShort;
}

class InputTextField extends StatefulWidget {
  final String title;
  String? suffixText;
  String? prefixText;
  Color? fillColor = Colors.transparent;
  bool isVisible;
  final String? Function(String? val)? validator;
  final Function()? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  TextStyle? hintStyle, suffixStyle, prefixStyle;
  final TextStyle? style;
  final String value;
  final Function(String) onChanged;
  final Function(String)? onSubmit;
  bool isdigits;
  bool limit;
  bool obscureText;
  int limitNumber;
  final bool enabled;
  final TextInputAction inputAction;
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? countrySelected;
  InputTextField(
      {Key? key,
      required this.title,
      this.value = '',
      this.hintStyle,
      this.validator,
      this.isVisible = true,
      this.fillColor,
      this.prefixIcon,
      this.suffixIcon,
      this.style,
      this.onTap,
      this.isdigits = false,
      this.limit = false,
      this.obscureText = false,
      this.limitNumber = 10,
      this.suffixText,
      this.prefixText,
      this.suffixStyle,
      this.prefixStyle,
      required this.onChanged,
      this.enabled = true,
      this.inputAction = TextInputAction.next,
      this.controller,
      this.hintText,
      this.onSubmit,
      this.countrySelected})
      : super(key: key);

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  late TextEditingController controller =
      TextEditingController(text: widget.value);
  String countryCode = "+977";
  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      controller = widget.controller!;
    }
    if (widget.countrySelected != null) {
      widget.countrySelected!(countryCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle defaultTextStyle =
        Theme.of(context).textTheme.headline5!.copyWith(
              color: CustomTheme.getBlackColor(),
            );
    // print(controller.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          enabled: widget.enabled,
          keyboardType: widget.isdigits
              ? TextInputType.phone
              : TextInputType.emailAddress,
          textInputAction: widget.inputAction,
          // onEditingComplete: () {},
          onFieldSubmitted: widget.onSubmit != null
              ? (val) {
                  widget.onSubmit!(val);
                }
              : null,
          maxLines: widget.title == 'Remarks' || widget.title == "" ? 2 : 1,
          controller: controller,

          inputFormatters: [
            if (widget.limit)
              LengthLimitingTextInputFormatter(widget.limitNumber),
            widget.isdigits
                ? FilteringTextInputFormatter.digitsOnly
                : FilteringTextInputFormatter.singleLineFormatter
          ],
          style: widget.style ?? defaultTextStyle,

          onTap: widget.onTap,
          //controller: TextEditingController(text: ''),
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.disabled,
          onChanged: (val) {
            widget.onChanged(val);
          },
          obscureText: widget.obscureText,
          decoration: InputDecoration(
              prefixIcon: widget.countrySelected != null
                  ? GestureDetector(
                      onTap: () async {
                        const countryPickerWithParams = FlCountryCodePicker(
                          favorites: ["NP"],

                          // filteredCountries: _yourFilters,

                          showDialCode: true,

                          showSearchBar: true,
                        );
                        var code = await countryPickerWithParams.showPicker(
                            context: context);
                        if (code != null) {
                          setState(() {
                            countryCode = code.dialCode;
                          });
                          widget.countrySelected!(code.dialCode);
                        }
                      },
                      child: Container(
                        width: 65.sw(),
                        padding: EdgeInsets.zero,

                        // color: Colors.red,
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    color:
                                        CustomTheme.getFilledPrimaryColor()))),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(right: 10.sw()),
                        child: Text(
                          countryCode,
                          textAlign: TextAlign.center,
                          style: widget.style ?? defaultTextStyle,
                        ),
                      ),
                    )
                  : widget.prefixIcon,
              // prefixIcon: widget.prefixIcon,
              suffixText: widget.suffixText,
              // prefixText: widget.isdigits ? "+977  " : "",
              suffixIcon: widget.suffixIcon,
              suffixStyle: widget.suffixStyle ?? defaultTextStyle,
              prefixStyle: widget.prefixStyle ??
                  defaultTextStyle.copyWith(color: CustomTheme.greyColor),
              fillColor: widget.fillColor,
              labelText: widget.isVisible ? widget.title : null,
              // isCollapsed: true,
              labelStyle: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: CustomTheme.greyColor),
              // filled: true,

              contentPadding: EdgeInsets.only(
                left: 17.sw(),
                top: 22.sh(),
                bottom: 16.sh(),
                right: 12.sw(),
              ),
              hintText: widget.hintText ??
                  (widget.title == 'Remarks'
                      ? 'Write remarks if any'
                      : widget.isVisible
                          ? 'Enter ${widget.title.toLowerCase()}'
                          : widget.title),
              hintStyle: widget.hintStyle),
        ),
      ],
    );
  }
}

Widget customShimmer(
    {double width = 50,
    double height = 12,
    BoxShape shape = BoxShape.rectangle,
    double? radius,
    double? borderRadius = 6}) {
  final baseColor = CustomTheme.primaryColor.withAlpha(127);
  return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor:
          CustomTheme.darkMode ? CustomTheme.greyColor : Colors.white,
      child: Container(
        width: radius ?? width,
        height: radius ?? height,
        decoration: BoxDecoration(
            color: baseColor,
            shape: shape,
            borderRadius: shape != BoxShape.circle
                ? borderRadius != null
                    ? BorderRadius.circular(borderRadius.sr())
                    : null
                : null),
      ));
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar(
      {Key? key,
      this.name,
      this.shop,
      this.size = 30,
      this.fontSize,
      this.padding = 20})
      : super(key: key);

  final String? name;
  final Shop? shop;
  final double padding;
  final double size;
  final double? fontSize;

  // final String? image;

  @override
  Widget build(BuildContext context) {
    final textImage = Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Theme.of(context).primaryColor),
        child: Center(
            child: Padding(
          padding: EdgeInsets.all(padding.sr()),
          child: Text(
            getImage(shop != null
                ? shop!.name
                : name == null
                    ? ''
                    : name!),
            style: Theme.of(context)
                .textTheme
                .headline1!
                .copyWith(color: CustomTheme.whiteColor, fontSize: fontSize),
          ),
        )));

    return Stack(
      children: [
        shop != null
            ? shop!.image.isEmpty
                ? textImage
                : Container(
                    width: size.sr(),
                    height: size.sr(),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(shop!.image.first
                                .replaceAll("localhost", Api.localUrl)))),
                  )
            : textImage,
      ],
    );
  }
}
