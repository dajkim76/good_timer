import 'package:flutter/material.dart';
import 'package:good_timer/my_native_plugin.dart';
import 'package:good_timer/my_providers.dart';
import 'package:good_timer/utils.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'generated/l10n.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> with WidgetsBindingObserver {
  int _batteryIgnoredStatus = -1;
  int _settingAlarmsStatus = -1;
  final TextEditingController _textFieldController = TextEditingController();
  static const kFontSize = 15.0;

  @override
  void initState() {
    super.initState();
    _queryBatteryIgnoredStatus();
    _querySettingAlarmsStatus();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _queryBatteryIgnoredStatus();
      _querySettingAlarmsStatus();
    }
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(3.0),
        child: SettingsList(
          sections: [
            SettingsSection(
                title: Text(S.of(context).pomodoro,
                    style: const TextStyle(fontSize: 17, color: Colors.orange, fontWeight: FontWeight.bold)),
                tiles: <SettingsTile>[
                  SettingsTile(
                      leading: const Icon(Icons.alarm),
                      title: buildSliderTile(
                          title: S.of(context).focus_time,
                          value: settings.focusTime.toDouble(),
                          activeColor: Colors.red,
                          min: 5.0,
                          max: 60.0,
                          onChanged: (newValue) {
                            settings.setFocusTime(newValue.round());
                          })),
                  SettingsTile(
                      leading: const Icon(Icons.alarm),
                      title: buildSliderTile(
                          title: S.of(context).short_break,
                          value: settings.shortBreakTime.toDouble(),
                          activeColor: Colors.green,
                          min: 5,
                          max: 30,
                          onChanged: (newValue) {
                            settings.setShortBreakTime(newValue.round());
                          })),
                  SettingsTile(
                      leading: const Icon(Icons.alarm),
                      title: buildSliderTile(
                          title: S.of(context).long_break,
                          value: settings.longBreakTime.toDouble(),
                          activeColor: Colors.greenAccent,
                          min: 5,
                          max: 30,
                          onChanged: (newValue) {
                            settings.setLongBreakTime(newValue.round());
                          }))
                ]),
            SettingsSection(
                title: Text(S.of(context).general,
                    style: const TextStyle(fontSize: 17, color: Colors.orange, fontWeight: FontWeight.bold)),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    title: Text(
                      S.of(context).allow_setting_alarms,
                      style: const TextStyle(fontSize: kFontSize),
                    ),
                    leading: const Icon(Icons.alarm_on),
                    description: Text(
                      _getSettingAlarmsMsgByStatus(),
                      style: const TextStyle(color: Colors.blue),
                    ),
                    onPressed: (context) async {
                      if (_settingAlarmsStatus == -1) {
                        showToast(_getSettingAlarmsMsgByStatus());
                      } else {
                        await MyNativePlugin.openSettingAlarms();
                      }
                    },
                  ),
                  SettingsTile.switchTile(
                    activeSwitchColor: Colors.blue,
                    onToggle: (value) {
                      settings.save(value);
                    },
                    initialValue: settings.isPlaySound,
                    leading: const Icon(Icons.surround_sound),
                    title: Text(
                      S.of(context).sound_when_pomodoro_done,
                      style: const TextStyle(fontSize: kFontSize),
                    ),
                  ),
                  SettingsTile.switchTile(
                    activeSwitchColor: Colors.blue,
                    onToggle: (value) {
                      settings.setVibration(value);
                    },
                    initialValue: settings.isVibration,
                    leading: const Icon(Icons.vibration),
                    title: Text(
                      S.of(context).vibration_when_pomodoro_done,
                      style: const TextStyle(fontSize: kFontSize),
                    ),
                  ),
                  SettingsTile.switchTile(
                    activeSwitchColor: Colors.blue,
                    onToggle: (value) {
                      settings.setAnalogClock(value);
                    },
                    initialValue: settings.isAnalogClock,
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
                      int result = await MyNativePlugin.ignoreBatteryOptimization();
                      if (result != 0) {
                        showToast(_getBatteryIgnoredMsgByStatus(result));
                      }
                      _queryBatteryIgnoredStatus();
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text(
                      S.of(context).rate_this_app,
                      style: const TextStyle(fontSize: kFontSize),
                    ),
                    leading: const Icon(Icons.store),
                    description: FutureBuilder<String>(
                        future: MyNativePlugin.getAppVersionName(),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.requireData,
                            style: const TextStyle(color: Colors.blue),
                          );
                        }),
                    onPressed: (context) async {
                      MyNativePlugin.openAppMarketPage();
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text(
                      S.of(context).app_icon,
                      style: const TextStyle(fontSize: kFontSize),
                    ),
                    leading: const Icon(Icons.open_in_browser),
                    description: Text(
                      "Pomodoro icons created by Flat Finance Icons",
                      style: const TextStyle(color: Colors.blue)),
                    onPressed: (context) async {
                      await launchUrl(Uri.parse("https://www.iconarchive.com/show/flat-finance-icons-by-graphicloads/timer-icon.html"));
                    },
                  )
                ])
          ],
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

  void _queryBatteryIgnoredStatus() {
    MyNativePlugin.isIgnoreBatteryOptimization().then((value) {
      if (mounted) {
        setState(() {
          _batteryIgnoredStatus = value;
        });
      }
    });
  }

  String _getSettingAlarmsMsgByStatus() {
    switch(_settingAlarmsStatus) {
      case 1: return S.of(context).allowed;
      case 0: return S.of(context).not_allowed;
      default: return S.of(context).always_allowed; // when SDK_INT < 31
    }
  }

  void _querySettingAlarmsStatus() {
    MyNativePlugin.querySettingAlarms().then((value) {
      if (mounted) {
        setState(() {
          _settingAlarmsStatus = value;
        });
      }
    });
  }

  Widget buildSliderTile(
      {required String title,
      required double value,
      required ValueChanged<double> onChanged,
      required Color activeColor,
      required double min,
      required double max}) {
    int divisions = (max - min) ~/ 5;
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontSize: kFontSize)),
          OutlinedButton(
              child: Text(
                S.of(context).minutes_fmt(value.round()),
                style: const TextStyle(color: Colors.blue),
              ),
              onPressed: () async {
                String rangeErrorMsg = S.of(context).check_the_range;
                String? result = await _showTextInputDialog(context, title, value.round().toString());
                if (result?.isNotEmpty == true) {
                  int? newValue = int.tryParse(result!);
                  if (newValue != null && newValue >= min && newValue <= max) {
                    onChanged(newValue.toDouble());
                  } else {
                    showToast(rangeErrorMsg);
                  }
                }
              }),
        ]),
        Slider(
            min: min,
            max: max,
            divisions: divisions,
            activeColor: activeColor,
            inactiveColor: Colors.grey,
            label: value.round().toString(),
            value: value.toDouble(),
            onChanged: onChanged),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
                divisions + 1,
                (index) => Text(
                      "${(index + 1) * 5}",
                      style: const TextStyle(fontSize: 13),
                    )),
          ),
        )
      ],
    );
  }

  Future<String?> _showTextInputDialog(BuildContext context, String title, String value) async {
    _textFieldController.text = value;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: _textFieldController,
              autofocus: true,
            ),
            actions: <Widget>[
              TextButton(
                child: Text(S.of(context).cancel),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(S.of(context).ok),
                onPressed: () => Navigator.pop(context, _textFieldController.text),
              ),
            ],
          );
        });
  }
}
