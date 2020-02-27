import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/article_titles.dart';

class ConfigHideFullMastered extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ArticleTitles articleTitles =
        Provider.of<ArticleTitles>(context, listen: false);

    return SwitchListTile(
        value: articleTitles.settings.isHideFullMastered,
        onChanged: articleTitles.filterHideMastered,
        title: Text(
          'Hide Mastered',
        ));
  }
}
