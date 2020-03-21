import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/settings.dart';
import '../models/article_titles.dart';

class ConfigFilterByPercent extends StatefulWidget {
  @override
  ConfigFilterByPercentState createState() => ConfigFilterByPercentState();
}

class ConfigFilterByPercentState extends State<ConfigFilterByPercent> {
  SettingNews _settings;
  ArticleTitles articleTitles;
  @override
  void initState() {
    articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    _settings = SettingNews();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _settings.getFromLocal(),
        builder: (BuildContext context, _) {
          return Column(children: [
            _settings.filertPercent > MIN_FILTER_PERCENT
                ? Text("Filter by percent: " + _settings.filertPercent.toStringAsFixed(0) + "%")
                : Text("Filter less than 70% show all articles"),
            Slider(
              label: _settings.filertPercent.toStringAsFixed(0) + "%",
              divisions: (MAX_FILTER_PERCENT - MIN_FILTER_PERCENT).toInt(),
              min: MIN_FILTER_PERCENT,
              max: MAX_FILTER_PERCENT,
              //value: articleTitles.settings.filertPercent,
              value: _settings.filertPercent,
              //onChanged: articleTitles.filterByPercent,
              onChanged: (double newValue) {
                setState(() {
                  _settings.setFilertPercent(newValue);
                });
              },
            ),
            RaisedButton(
              child: const Text('Done'),
              onPressed: () {
                articleTitles.filterByPercent(_settings.filertPercent);
                Navigator.of(context).pop();
              },
            )
          ]);
        });
  }
}
