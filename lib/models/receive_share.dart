import 'package:flutter/material.dart';

class ReceiveShare with ChangeNotifier {
  bool initialized = false;
  done() {
    initialized = true;
  }
}
