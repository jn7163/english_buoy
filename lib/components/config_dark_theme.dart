import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/settings.dart';

class ConfigDarkTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingNews>(builder: (context, setting, child) {
      return SwitchListTile(
          value: setting.isDark,
          onChanged: setting.setIsDark,
          title: Text(
            'Dark Mode',
          ));
    });
  }
}
