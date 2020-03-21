import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/settings.dart';

class ConfigDarkTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<SettingNews, bool>(
        selector: (context, settings) => settings.isDark,
        builder: (context, isDark, child) {
          return SwitchListTile(
              value: isDark,
              onChanged: Provider.of<SettingNews>(context, listen: false).setIsDark,
              title: Text(
                'Dark Mode',
              ));
        });
  }
}
