import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/settings.dart';

class ConfigAutoPlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, setting, child) {
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
