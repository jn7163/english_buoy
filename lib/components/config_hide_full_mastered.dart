import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/article_titles.dart';
import '../models/settings.dart';

class ConfigHideFullMastered extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ArticleTitles articleTitles = Provider.of<ArticleTitles>(context, listen: false);

    return Selector<SettingNews, bool>(
        selector: (context, settings) => settings.isHideFullMastered,
        builder: (context, isHideFullMastered, child) {
          return SwitchListTile(
              value: isHideFullMastered,
              onChanged: articleTitles.filterHideMastered,
              title: Text(
                'Hide 100%',
              ));
        });
  }
}
