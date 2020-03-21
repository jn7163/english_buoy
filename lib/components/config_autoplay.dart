import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/settings.dart';

class ConfigAutoPlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<SettingNews, bool>(
      selector: (context, settings) => settings.isAutoplay,
      builder: (context, isAutoplay, child) {
        return SwitchListTile(
            value: isAutoplay, onChanged: Provider.of<SettingNews>(context, listen: false).setIsAutoplay, title: child);
      },
      child: Text(
        'Autoplay',
      ),
    );
  }
}
