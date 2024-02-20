import 'package:flutter/material.dart';

/// 24.02.20 HJS
/// Syncfusion Custom Renderer Box
class CustomBoxShadowWidget extends BoxShadow {

  //final BlurStyle blurStyle = BlurStyle.outer;

  const CustomBoxShadowWidget({
    super.color,
    super.offset,
    super.blurRadius,
    //this.blurStyle = BlurStyle.normal,
  });

  @override
  Paint toPaint() {
    final Paint result = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, blurSigma);
    assert(() {
      if (debugDisableShadows) {
        result.maskFilter = null;
      }
      return true;
    }());
    return result;
  }
}