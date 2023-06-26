
import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/Components/CustomTheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsInfo extends StatefulWidget {
  final String text;
  final Widget icon;
  final Widget darkModeIcon;
  final Function()? onTap;
  final String? details;
  final EdgeInsets ?padding;
  SettingsInfo({
    required this.text,
    required this.icon,
    this.onTap,
    this.details,
    this.padding,
    required this.darkModeIcon,
  });

  @override
  State<SettingsInfo> createState() => _SettingsInfoState();
}

class _SettingsInfoState extends State<SettingsInfo> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () async {
        if (isLoading == false) {
          setState(() => isLoading = true);
          try {
            if (widget.onTap != null) {
              Future.value(await widget.onTap!())
                  .timeout(const Duration(seconds: 15));
            }
          } on Exception catch (_, e) {
            print("$e $_");
          }
          if (mounted) {
            setState(() => isLoading = false);
          }
        }
      },
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: widget.padding ??const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SpacePalette.spaceMedium,
              Row(
                children: [
                  context.watch<CustomTheme>().isDarkMode
                      ? (widget.darkModeIcon)
                      : widget.icon,
                  const SizedBox(
                    width: 30,
                  ),
                  Text(
                    widget.text,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Expanded(child: Container()),
                  widget.details != null
                      ? Text(
                          widget.details ?? "",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : isLoading
                          ?  SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(color: Theme.of(context).primaryColor,))
                          : Container(),
                ],
              ),
              SpacePalette.spaceMedium
            ],
          ),
        ),
      ),
    );
  }
}
