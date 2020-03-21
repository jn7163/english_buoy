import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/settings.dart';

class ConfigScrollWithPlaying extends StatelessWidget {
  //const ConfigJumpToWord({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingNews>(builder: (context, setting, child) {
      return SwitchListTile(
          value: setting.isScrollWithPlay,
          onChanged: setting.setIsScrollWithPlay,
          title: Text(
            'Scroll with playing',
          ));
    });
  }
}
