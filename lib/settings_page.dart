import 'package:flutter/material.dart';
import 'package:good_timer/my_providers.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import 'generated/l10n.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings),
      ),
      body: Padding(
        padding: EdgeInsets.all(5.0),
        child: SettingsList(
          sections: [
            SettingsSection(title: null, tiles: <SettingsTile>[
              SettingsTile.switchTile(
                onToggle: (value) {
                  settingsProvider.save(value);
                },
                initialValue: settingsProvider.isPlaySound,
                leading: const Icon(Icons.surround_sound),
                title: Text(S.of(context).playSound),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  settingsProvider.setAnalogClock(value);
                },
                initialValue: settingsProvider.isAnalogClock,
                leading: const Icon(Icons.alarm),
                title: Text(S.of(context).show_analog_clock),
              )
            ])
          ],
          lightTheme: const SettingsThemeData(
              settingsListBackground: Colors.black,
              titleTextColor: Colors.white,
              leadingIconsColor: Colors.grey,
              settingsTileTextColor: Colors.grey,
              tileDescriptionTextColor: Colors.blue),
        ),
      ),
    );
  }
}
