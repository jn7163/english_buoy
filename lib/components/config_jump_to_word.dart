import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provide/provide.dart';
import '../models/setting.dart';

class ConfigJumpToWord extends StatelessWidget {
  //const ConfigJumpToWord({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provide<Setting>(builder: (context, child, setting) {
      return SwitchListTile(
          value: setting.isJump,
          onChanged: setting.setIsJump,
          title: Text(
            'jump to word when click twice',
          ));
    });
  }
}
