import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

Widget getSpinkitProgressIndicator(BuildContext context) {
  return SpinKitRipple(
    color: Theme.of(context).primaryColorLight,
    size: 340.0,
  );
}
