import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/setting.dart';

class ConfigAutoPlay extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Consumer<Setting>(builder: (context, setting, child) {
      return SwitchListTile(
          value: setting.isAutoplay,
          onChanged: setting.setIsAutoplay,
          title: Text(
            'Autoplay',
          ));
    });
  }
}
