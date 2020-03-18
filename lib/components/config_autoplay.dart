import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/settings.dart';

class ConfigAutoPlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Settings setting = Provider.of<Settings>(context);
    return SwitchListTile(
        value: setting.isAutoplay,
        onChanged: setting.setIsAutoplay,
        title: Text(
          'Autoplay',
        ));
  }
}
