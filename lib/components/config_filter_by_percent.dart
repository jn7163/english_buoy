import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/setting.dart';

class ConfigFilterByPercent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Setting>(builder: (context, setting, child) {
      String from = setting.fromPercent;
      String to = setting.toPercent;
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
    });
  }
}
