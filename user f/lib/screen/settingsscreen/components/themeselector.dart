import 'package:ezdeliver/screen/holder/components/customAppBar.dart';

import '../../component/helper/exporter.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final themeMode = ref.watch(customThemeServiceProvider).themeMode;
    return Column(
      mainAxisSize:
          ResponsiveLayout.isMobile ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (!ResponsiveLayout.isMobile)
          simpleAppBar(
            context,
            title: "Theme",
            close: false,
          ),
        RadioListTile(
          value: themeMode == ThemeMode.light,
          groupValue: true,
          onChanged: (val) {
            if (ResponsiveLayout.isMobile) {
              Navigator.pop(context);
            }
            ref
                .read(customThemeServiceProvider)
                .switchThemeMode(ThemeMode.light);
          },
          title: const Text("Light"),
        ),
        RadioListTile(
          value: themeMode == ThemeMode.dark,
          groupValue: true,
          onChanged: (val) {
            if (ResponsiveLayout.isMobile) {
              Navigator.pop(context);
            }
            ref
                .read(customThemeServiceProvider)
                .switchThemeMode(ThemeMode.dark);
          },
          title: const Text("Dark"),
        ),
        RadioListTile(
          value: themeMode == ThemeMode.system,
          groupValue: true,
          onChanged: (val) {
            if (ResponsiveLayout.isMobile) {
              Navigator.pop(context);
            }
            ref
                .read(customThemeServiceProvider)
                .switchThemeMode(ThemeMode.system);
          },
          title: const Text("System"),
        ),
      ],
    );
  }
}
