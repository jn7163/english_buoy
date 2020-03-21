import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/settings.dart';

class ConfigJumpToWord extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<SettingNews, bool>(
      selector: (context, settings) => settings.isJump,
      builder: (context, isJump, child) {
        return SwitchListTile(
            value: isJump, onChanged: Provider.of<SettingNews>(context, listen: false).setIsJump, title: child);
      },
      child: Text(
        'jump to word when click twice',
      ),
    );
  }
}
