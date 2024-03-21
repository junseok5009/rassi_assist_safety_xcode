import 'package:flutter/material.dart';
import 'package:rassi_assist/common/tstyle.dart';

class AnimatedCountTextWidget extends ImplicitlyAnimatedWidget {
  const AnimatedCountTextWidget({
    Key? key,
    this.count = 0,
    this.textStyle,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.fastOutSlowIn,
  }) : super(duration: duration, curve: curve, key: key);

  final double count;
  final TextStyle? textStyle;

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() {
    return _AnimatedCountState();
  }
}

class _AnimatedCountState
    extends AnimatedWidgetBaseState<AnimatedCountTextWidget> {
  Tween<double> _doubleCount = Tween<double>(begin: 0.0, end: 0.0);

  @override
  Widget build(BuildContext context) {
    return Text(
        _doubleCount.begin == null ? TStyle.getMoneyPoint(widget.count.toStringAsFixed(0)) :
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
