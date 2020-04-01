import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class IncreasePercentNumber extends StatefulWidget {
  IncreasePercentNumber({Key key, @required this.number}) : super(key: key);
  final double number;

  @override
  IncreasePercentNumberState createState() => IncreasePercentNumberState();
}

class IncreasePercentNumberState extends State<IncreasePercentNumber>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  Animation _animation;
  AnimationController _animationController;
  String _percent = '0';
  int _duration = 4444;
  @override
  bool get wantKeepAlive => true;
  @override
  initState() {
    print("initState $this");
    super.initState();
    _animationController = AnimationController(duration: Duration(milliseconds: _duration), vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.number)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut))
          ..addListener(() {
            setState(() {
              _percent = _animation.value.toStringAsFixed(1);
            });
          });
    _animationController.forward();
  }

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(IncreasePercentNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) {
      if (_animationController != null) {
        //_animationController.duration = Duration(milliseconds: _duration);
        _animation = Tween(begin: 0, end: widget.number).animate(_animationController);
        _animationController.forward(from: 0.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CircularPercentIndicator(
      animationDuration: _duration,
      animation: true,
      radius: 40.0,
      lineWidth: 3.0,
      percent: widget.number / 100,
      center: Text("$_percent%", style: TextStyle(fontSize: 10, color: Colors.white)),
      progressColor: Colors.white,
      backgroundColor: Colors.transparent,
    );
  }
}
