import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/settings.dart';
import '../models/article_titles.dart';

class ConfigFilterByPercent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ArticleTitles articleTitles =
        Provider.of<ArticleTitles>(context, listen: false);
    return Consumer<Settings>(builder: (context, setting, child) {
      return Column(children: [
        setting.filertPercent > 70
            ? Text("Filter by percent: " +
                setting.filertPercent.toStringAsFixed(0) +
                "%")
            : Text("Filter less than 70% show all articles"),
        Slider(
          label: setting.filertPercent.toStringAsFixed(0) + "%",
          divisions: 30,
          min: 70,
          max: 100,
          value: setting.filertPercent,
          onChanged: articleTitles.filterByPercent,
        ),
      ]);
      /*
      return Row(children: [
        Flexible(
            child: Padding(
                padding: EdgeInsets.all(30),
                child: TextField(
                  controller: TextEditingController(text: from),
                  onChanged: setting.setFromPercent,
                  decoration: new InputDecoration(labelText: "From"),
                  keyboardType: TextInputType.number,
                ))),
        Text("Percent"),
        Flexible(
            child: Padding(
                padding: EdgeInsets.all(30),
                child: TextField(
                  controller: TextEditingController(text: to),
                  onChanged: setting.setToPercent,
                  decoration: new InputDecoration(labelText: "To"),
                  keyboardType: TextInputType.number,
                ))),
      ]);
      */
    });
  }
}
