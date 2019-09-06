import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/setting.dart';

class ConfigDarkTheme extends StatelessWidget {
  // const ConfigDarkTheme({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Setting>(builder: (context, setting, child) {
      return SwitchListTile(
          value: setting.isDark,
          onChanged: setting.setIsDark,
          title: Text(
            'Dark Mode',
          ));
    });
  }
}
