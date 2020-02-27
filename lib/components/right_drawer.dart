import 'package:flutter/material.dart';
import './config_autoplay.dart';
import './config_dark_theme.dart';
import './config_filter_by_percent.dart';
import 'config_hide_full_mastered.dart';

// 右边抽屉
class RightDrawer extends StatelessWidget {
  const RightDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: SingleChildScrollView(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppBar(
            backgroundColor: Theme.of(context).primaryColorDark,
            automaticallyImplyLeading: false,
            actions: <Widget>[Container()],
            centerTitle: true,
            title: Text(
              "Settings",
            )),
        ConfigDarkTheme(),
        ConfigAutoPlay(),
        ConfigHideFullMastered(),
        ConfigFilterByPercent(),
        RaisedButton(
          child: const Text('Done'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    )));
  }
}
