import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provide/provide.dart';
import '../models/setting.dart';

class ConfigDarkTheme extends StatelessWidget {
  const ConfigDarkTheme({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provide<Setting>(builder: (context, child, setting) {
      return SwitchListTile(
          value: setting.isDark,
          onChanged: setting.setIsDark,
          title: Text(
            'On Dark Theme',
          ));
    });
  }
}
