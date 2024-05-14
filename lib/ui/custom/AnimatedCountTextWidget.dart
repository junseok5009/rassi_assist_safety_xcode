import 'package:flutter/material.dart';
import 'package:rassi_assist/common/tstyle.dart';

class AnimatedCountTextWidget extends ImplicitlyAnimatedWidget {
  const AnimatedCountTextWidget({
    Key? key,
    required this.count,
    required this.textStyle,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.fastOutSlowIn,
  }) : super(duration: duration, curve: curve, key: key);

  final double count;
  final TextStyle textStyle;

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() {
    return _AnimatedCountState();
  }
}

class _AnimatedCountState extends AnimatedWidgetBaseState<AnimatedCountTextWidget> {
  Tween<double> _doubleCount = Tween<double>(begin: 0.0, end: 1.0);

  @override
  void initState() {
    super.initState();
    _doubleCount = Tween<double>(begin: 0, end: widget.count.toDouble());
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      TStyle.getMoneyPoint(
        _doubleCount.evaluate(animation).toStringAsFixed(0),
      ),
      style: widget.textStyle,
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _doubleCount = visitor(
      _doubleCount,
      widget.count,
      (dynamic value) => Tween<double>(begin: value),
    ) as Tween<double>;
  }
}
