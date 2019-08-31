import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/setting.dart';

class ConfigJumpToWord extends StatelessWidget {
  //const ConfigJumpToWord({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Setting>(builder: (context, setting, child) {
      return SwitchListTile(
          value: setting.isJump,
          onChanged: setting.setIsJump,
          title: Text(
            'jump to word when click twice',
          ));
    });
  }
}
