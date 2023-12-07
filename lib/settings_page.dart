import 'package:flutter/material.dart';
import 'package:good_timer/my_native_plugin.dart';
import 'package:good_timer/my_providers.dart';
import 'package:good_timer/utils.dart';
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
  static const kFontSize = 17.0;

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
        padding: const EdgeInsets.all(3.0),
        child: SettingsList(
          sections: [
            SettingsSection(title: null, tiles: <SettingsTile>[
              SettingsTile.switchTile(
                onToggle: (value) {
                  settingsProvider.save(value);
                },
                initialValue: settingsProvider.isPlaySound,
                leading: const Icon(Icons.surround_sound),
                title: Text(
                  S.of(context).sound_when_pomodoro_done,
                  style: const TextStyle(fontSize: kFontSize),
                ),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  settingsProvider.setVibration(value);
                },
                initialValue: settingsProvider.isVibration,
                leading: const Icon(Icons.vibration),
                title: Text(
                  S.of(context).vibration_when_pomodoro_done,
                  style: const TextStyle(fontSize: kFontSize),
                ),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  settingsProvider.setAnalogClock(value);
                },
                initialValue: settingsProvider.isAnalogClock,
                leading: const Icon(Icons.alarm),
                title: Text(
                  S.of(context).show_analog_clock,
                  style: const TextStyle(fontSize: kFontSize),
                ),
              ),
              SettingsTile.navigation(
                title: Text(
                  S.of(context).ignore_battery_optimization,
                  style: const TextStyle(fontSize: kFontSize),
                ),
                leading: const Icon(Icons.battery_5_bar),
                description: Text(
                  _getBatteryIgnoredMsg(),
                  style: const TextStyle(color: Colors.blue),
                ),
                onPressed: (context) async {
                  int status = await MyNativePlugin.ignoreBatteryOptimization();
                  if (status != 0) {
                    showToast(_getBatteryIgnoredMsgByStatus(status));
                  }
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

  String _getBatteryIgnoredMsgByStatus(int status) {
    switch (status) {
      case 1:
        return S.of(context).battery_optimization_ignored;
      case 0:
        return S.of(context).battery_optimization_not_ignored;
      default:
        return S.of(context).battery_optimization_unsupported;
    }
  }

  String _getBatteryIgnoredMsg() {
    return _getBatteryIgnoredMsgByStatus(_batteryIgnoredStatus);
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
