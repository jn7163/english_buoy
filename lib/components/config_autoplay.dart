import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/setting.dart';

class ConfigAutoPlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Setting>(builder: (context, setting, child) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Autoplay'),
        Switch(
          value: setting.isAutoplay,
          onChanged: setting.setIsAutoplay,
        )
      ]);
    });
  }
}
