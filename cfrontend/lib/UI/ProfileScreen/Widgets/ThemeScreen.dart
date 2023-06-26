import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/Components/CustomTheme.dart';
import 'package:ezdelivershop/Components/Widgets/CustomAppBar.dart';
import 'package:ezdelivershop/Components/Widgets/CustomSafeArea.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  List<ThemeMode> themeMode = [
    ThemeMode.system,
    ThemeMode.dark,
    ThemeMode.light
  ];

  @override
  initState() {
    super.initState();
    // Add listeners to this class
  }

  @override
  Widget build(BuildContext context) {
    // List<String> theme = ["System", "Dark", "Light"];

    return CustomSafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const CustomAppBar(
              title: "Theme",
              leftButton: true,
            ),
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.separated(
              itemCount: themeMode.length,
              itemBuilder: (context, i) {
                  return InkWell(
                    onTap: () {
                      setState(() {});
                      context.read<CustomTheme>().switchThemeMode(themeMode[i]);
                      // changeTheme(context, value!);
                    },
                    child: ListTile(
                      title: Text(
                        themeMode[i].name.toCapitalized(),
                      ),
                      trailing: Radio<ThemeMode>(
                        value: themeMode[i],
                        groupValue: context.watch<CustomTheme>().themeMode,
                        onChanged: (ThemeMode? value) {
                          setState(() {});
                          context.read<CustomTheme>().switchThemeMode(value!);
                        },
                      ),
                    ),
                  );
              },
              separatorBuilder: (context, i) => SpacePalette.spaceMedium,
            ),
                ))
          ],
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
