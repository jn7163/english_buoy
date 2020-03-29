import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class IncreasePercentNumber extends StatefulWidget {
  IncreasePercentNumber({Key key, @required this.number}) : super(key: key);
  final double number;

  @override
  IncreasePercentNumberState createState() => IncreasePercentNumberState();
}

class IncreasePercentNumberState extends State<IncreasePercentNumber> with SingleTickerProviderStateMixin {
  Animation _animation;
  AnimationController _animationController;
  String _percent = '0';
  int _duration = 4444;
  double _number;
  @override
  initState() {
    super.initState();
    _number = widget.number;
    print("initState $this ${widget.key} $_number");
    _animationController = AnimationController(duration: Duration(milliseconds: _duration), vsync: this);
    _animation =
        Tween<double>(begin: 0, end: _number).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut))
          ..addListener(() {
            setState(() {
              _percent = _animation.value.toStringAsFixed(1);
            });
          });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      animationDuration: _duration,
      animation: true,
      radius: 40.0,
      lineWidth: 3.0,
      percent: _number / 100,
      center: Text("$_percent%", style: TextStyle(fontSize: 10, color: Colors.white)),
      progressColor: Colors.white,
      backgroundColor: Colors.transparent,
    );
  }
}
