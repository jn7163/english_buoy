import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/settings.dart';

class ConfigScrollWithPlaying extends StatelessWidget {
  //const ConfigJumpToWord({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<SettingNews, bool>(
        selector: (context, settings) => settings.isScrollWithPlay,
        builder: (context, isScrollWithPlay, child) {
          return SwitchListTile(
              value: isScrollWithPlay,
              onChanged: Provider.of<SettingNews>(context, listen: false).setIsScrollWithPlay,
              title: child);
        },
        child: Text('Scroll with playing'));
  }
}
