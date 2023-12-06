import 'package:flutter/material.dart';
import 'package:good_timer/my_native_plugin.dart';
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
  int _batteryIgnoredStatus = -1;

  @override
  void initState() {
    super.initState();
    queryBatteryIgnoredStatus();
  }

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
              ),
              SettingsTile.navigation(
                title: Text(S.of(context).ignore_battery_optimization),
                leading: const Icon(Icons.battery_5_bar),
                description: Text(_getBatteryIgnoredStatusMsg()),
                onPressed: (context) async {
                  await MyNativePlugin.ignoreBatteryOptimization();
                  queryBatteryIgnoredStatus();
                },
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

  String _getBatteryIgnoredStatusMsg() {
    switch (_batteryIgnoredStatus) {
      case 1:
        return S.of(context).battery_optimization_ignored;
      case 0:
        return S.of(context).battery_optimization_not_ignored;
      default:
        return S.of(context).battery_optimization_unsupported;
    }
  }

  void queryBatteryIgnoredStatus() {
    MyNativePlugin.isIgnoreBatteryOptimization().then((value) {
      if (mounted) {
        setState(() {
          _batteryIgnoredStatus = value;
        });
      }
    });
  }
}
