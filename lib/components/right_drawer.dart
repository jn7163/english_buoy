import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './config_dark_theme.dart';
import './config_autoplay.dart';
import './config_filter_by_percent.dart';
import '../models/settings.dart';
import '../models/article_titles.dart';

// 右边抽屉
class RightDrawer extends StatelessWidget {
  const RightDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ArticleTitles articleTitles =
        Provider.of<ArticleTitles>(context, listen: false);
    Settings settings = Provider.of<Settings>(context, listen: false);
    return Drawer(
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
        //ConfigDarkTheme(),
        ConfigAutoPlay(),
        ConfigFilterByPercent(),
        RaisedButton(
          child: const Text('fliter by percent'),
          onPressed: () {
            articleTitles.filterByPercent(
                settings.fromPercent, settings.toPercent);
            Navigator.of(context).pop();
          },
        )
      ],
    ));
  }
}
