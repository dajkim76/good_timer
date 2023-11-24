import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Padding(
        padding: EdgeInsets.all(5.0),
        child: SettingsList(
          sections: [
            SettingsSection(title: null, tiles: <SettingsTile>[
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: true,
                leading: Icon(Icons.surround_sound),
                title: Text('Play sound'),
              ),
            ])
          ],
          lightTheme: SettingsThemeData(
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
