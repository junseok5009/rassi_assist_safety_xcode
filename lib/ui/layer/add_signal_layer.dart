import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/tr_search/tr_search01.dart';
import 'package:rassi_assist/provider/add_signal_layer_slider_provider.dart';
import 'package:rassi_assist/provider/signal_provider.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_stock_info_provider.dart';
import 'package:rassi_assist/ui/custom/AnimatedCountTextWidget.dart';

class AddSignalLayer extends StatelessWidget {
  //const AddSignalLayer({super.key});
  final Stock? stock;

  const AddSignalLayer({Key? key, this.stock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SignalLayerSliderProvider()),
      ],
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                color: Colors.black,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 24,
                onPressed: () {
                  if (context != null && context.mounted) {
                    Navigator.pop(context, CustomNvRouteResult.cancel);
                  }
                },
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              '나만의 매도 신호 만들기',
              style: TStyle.title18T,
            ),
            const SizedBox(
              height: 20,
            ),
            AddSignalLayerView(stock: stock),
          ],
        ),
      ),
    );
  }
}

class AddSignalLayerView extends StatefulWidget {
  final Stock? stock;

  const AddSignalLayerView({Key? key, this.stock}) : super(key: key);

  @override
  State<AddSignalLayerView> createState() => _AddSignalLayerViewState();
}

class _AddSignalLayerViewState extends State<AddSignalLayerView> {
  late StockInfoProvider _stockInfoProvider;
  late SignalLayerSliderProvider _signalLayerSliderProvider;
  bool _isSelectPrice = true; // 슬라이더로 매수가 선택, flase : 직접 입력
  final _textEditingController = TextEditingController();
  int _directEditPrice = 0; // 직업 입력한 값
  bool _isWrong = false; //
  bool _isSelectPriceTouchOnce = false;
  final GlobalKey _containerKey = GlobalKey();

  double _directPriceKeyboardHeight = 0;
  double _directPriceEmptyBoxheight = 0; // 매수가 직접설정의 빈 박스 높이
  double _selectPriceViewHeight = 0; // 매수가 직접설정 넘어가면서 빈 박스 만들어서 부드럽게 띄워지게

  @override
  void initState() {
    super.initState();
    _stockInfoProvider = Provider.of<StockInfoProvider>(context, listen: false);
    _signalLayerSliderProvider = Provider.of<SignalLayerSliderProvider>(context, listen: false);
    _stockInfoProvider.addListener(_stockInfoProviderListener);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _stockInfoProvider.postRequest(widget.stock!.stockCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSelectPrice) {
      double keyBoardHeight = MediaQuery.of(context).viewInsets.bottom;

      if (181 + keyBoardHeight > _selectPriceViewHeight) {
        _directPriceEmptyBoxheight = 0;
        //DLog.d('','_directPriceKeyboardHeight : $_directPriceKeyboardHeight');
      } else {
        if (Platform.isAndroid) {
          _directPriceEmptyBoxheight = _selectPriceViewHeight - 181 - keyBoardHeight;
        } else {
          _directPriceEmptyBoxheight = _selectPriceViewHeight - 181 - keyBoardHeight;
        }
      }

      if (keyBoardHeight > _directPriceKeyboardHeight) {
        _directPriceKeyboardHeight = keyBoardHeight;
      } else if (keyBoardHeight < _directPriceKeyboardHeight) {
        if (Platform.isIOS) {
          _directPriceEmptyBoxheight = _directPriceKeyboardHeight - keyBoardHeight + 40;
        }
      }
    }
    return KeyboardVisibilityBuilder(
      builder: (p0, isKeyboardVisible) => SingleChildScrollView(
        child: Container(
          key: _containerKey,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (!_isSelectPrice) {
                          if (isKeyboardVisible) {
                            FocusScope.of(context).unfocus();
                            Future.delayed(const Duration(milliseconds: 160), () {
                              SchedulerBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  _isSelectPrice = true;
                                });
                              });
                            });
                          } else {
                            setState(() {
                              //_directPriceEmptyBoxheight =
                              _isSelectPrice = true;
                            });
                          }
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        decoration: UIStyle.boxRoundLine25c(
                          _isSelectPrice ? Colors.black : RColor.greyBasic_8c8c8c,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '매수가 선택',
                          style: TextStyle(
                            fontWeight: _isSelectPrice ? FontWeight.bold : FontWeight.normal,
                            color: _isSelectPrice ? Colors.black : RColor.greyBasic_8c8c8c,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (_isSelectPrice) {
                          setState(() {
                            _directPriceKeyboardHeight = 0;
                            _isSelectPrice = false;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        decoration: UIStyle.boxRoundLine25c(
                          !_isSelectPrice ? Colors.black : RColor.greyBasic_8c8c8c,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '매수가 직접설정',
                          style: TextStyle(
                            fontWeight: !_isSelectPrice ? FontWeight.bold : FontWeight.normal,
                            color: !_isSelectPrice ? Colors.black : RColor.greyBasic_8c8c8c,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _isSelectPrice ? _setSelectPriceViews : _setDirectPriceViews,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stockInfoProvider.removeListener(_stockInfoProviderListener);
    super.dispose();
  }

  _stockInfoProviderListener() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _signalLayerSliderProvider.setValues(
          _stockInfoProvider.getStockCode,
          (double.tryParse(_stockInfoProvider.getCurrentPrice) ?? 0),
          (double.tryParse(_stockInfoProvider.getListBuyPrice
                  .firstWhere(
                    (element) => element.resultDiv == 'minPrice',
                    orElse: () => Search01BuyPrice(
                      setPrice: '0',
                      resultDiv: 'minPrice',
                    ),
                  )
                  .setPrice) ??
              0),
          (double.tryParse(_stockInfoProvider.getListBuyPrice
                  .firstWhere(
                    (element) => element.resultDiv == 'maxPrice',
                    orElse: () => Search01BuyPrice(
                      setPrice: (double.tryParse(_stockInfoProvider.getCurrentPrice) ?? '0').toString(),
                      resultDiv: 'maxPrice',
                    ),
                  )
                  .setPrice) ??
              0),
          (double.tryParse(_stockInfoProvider.getListBuyPrice
                  .firstWhere(
                    (element) => element.resultDiv == 'hogaPrice',
                    orElse: () => Search01BuyPrice(
                      setPrice: (double.tryParse(_stockInfoProvider.getCurrentPrice) ?? '0').toString(),
                      resultDiv: 'hogaPrice',
                    ),
                  )
                  .setPrice) ??
              0));
    });
  }

  List<Widget> get _setSelectPriceViews => <Widget>[
        Consumer<StockInfoProvider>(
          builder: (context, stockInfoProvider, child) {
            if (stockInfoProvider.getIsLoading) {
              return const SizedBox(
                  //height: 50,
                  );
            } else {
              return Consumer<SignalLayerSliderProvider>(
                builder: (_, provider, __) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    _selectPriceViewHeight = _getSize().height;
                  });
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedCountTextWidget(
                            count: provider.getCurrentPrice.toDouble(),
                            duration: const Duration(
                              milliseconds: 200,
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: RColor.purpleBasic_6565ff,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: Stack(
                          children: [
                            Container(
                              alignment: Alignment.topCenter,
                              //color: Colors.red,
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 9,
                                  /*trackShape: const RectangularSliderTrackShape(),
                                  overlayShape: SliderComponentShape.noThumb,*/
                                  //trackHeight: 3.0,
                                  overlayShape: SliderComponentShape.noThumb,
                                  trackShape: const RoundSliderTrackShape(),
                                ),
                                child: Slider(
                                  value: provider.getCurrentPrice,
                                  min: provider.getMinPrice,
                                  max: provider.getMaxPrice,
                                  divisions: provider.getDivision,
                                  //label: provider.getCurrentPrice.toStringAsFixed(0),
                                  activeColor: RColor.greySliderBar_ebebeb,
                                  inactiveColor: RColor.greySliderBar_ebebeb,
                                  thumbColor: RColor.purpleBasic_6565ff,
                                  onChanged: (double newValue) {
                                    provider.setCurrentPrice(newValue);
                                    if (!_isSelectPriceTouchOnce) {
                                      setState(() {
                                        _isSelectPriceTouchOnce = true;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: UIStyle.boxRoundFullColor25c(
                                          RColor.greyBox_dcdfe2,
                                        ),
                                        child: const Text(
                                          '-15%',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        TStyle.getMoneyPoint(
                                          provider.getMinPrice.toStringAsFixed(0),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        TStyle.getMoneyPoint(
                                          provider.getMaxPrice.toStringAsFixed(0),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: UIStyle.boxRoundFullColor25c(
                                          RColor.greyBox_dcdfe2,
                                        ),
                                        child: const Text(
                                          '+9%',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
        const SizedBox(
          height: 30,
        ),
        const Text(
          '나만의 매도신호 만들기는?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge,
            children: const [
              TextSpan(
                text: '① 입력하신 매수 가격에 맞춰 회원님만을 위한 매도 알고리즘이 설정됩니다.\n',
                style: TextStyle(
                  fontSize: 13,
                  color: RColor.greyMore_999999,
                ),
              ),
              TextSpan(
                text: '\n',
                style: TextStyle(
                  fontSize: 5,
                  color: RColor.greyMore_999999,
                ),
              ),
              TextSpan(
                text: '② 매수가는 ‘현재가 기준 +9%’이내 가격으로만 등록이 가능합니다.\n',
                style: TextStyle(
                  fontSize: 13,
                  color: RColor.greyMore_999999,
                ),
              ),
              TextSpan(
                text: '\n',
                style: TextStyle(
                  fontSize: 5,
                  color: RColor.greyMore_999999,
                ),
              ),
              TextSpan(
                text: '③ 매도 신호의 경우 손절 구간이 있기 때문에 매수가 대비 -12% 이하에서는 알고리즘이 적극적으로 손절 신호를 발생시킵니다. '
                    '따라서 매수가 입력 시점에서 수익률이 마이너스인 경우 손절 신호가 빨리 발생될 수 있습니다. 손절을 원치 않으시는 경우, '
                    '이 부분을 고려하여 참고해 주시기 바랍니다.\n',
                style: TextStyle(
                  fontSize: 13,
                  color: RColor.greyMore_999999,
                ),
              ),
            ],
          ),
        ),
        _setMakeSignalBtn,
      ];

  List<Widget> get _setDirectPriceViews => <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(
            top: 10,
          ),
          decoration: _isWrong ? UIStyle.boxRoundLine6LineColor(Colors.red) : UIStyle.boxRoundLine6(),
          child: TextField(
            controller: _textEditingController,
            autofocus: true,
            textAlign: TextAlign.center,
            cursorWidth: 1.6,
            cursorHeight: 24,
            minLines: 1,
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter(RegExp('[0-9]'), allow: true),
            ],
            style: const TextStyle(
              fontSize: 18,
              height: 1.4,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            decoration: InputDecoration(
              fillColor: Colors.black,
              focusColor: Colors.black,
              //border: InputBorder(borderSide: BorderSide()),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                  width: 0,
                ),
              ),
              //enabledBorder: null,
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                  width: 0,
                ),
              ),
              counterText: '',
              hintText: _isWrong ? '올바른 매수가를 입력해 주십시오.' : TStyle.getMoneyPoint(_stockInfoProvider.getCurrentPrice),
              hintStyle: TextStyle(
                fontSize: _isWrong ? 14 : 18,
                height: 1.4,
                fontWeight: FontWeight.w400,
                color: _isWrong ? Colors.red : RColor.greyTitle_cdcdcd,
                letterSpacing: 0.3,
              ),
            ),
            //scrollPadding: const EdgeInsets.only(bottom: 80),
            onChanged: (value) {
              if (_isWrong) {
                setState(() {
                  _isWrong = false;
                });
              }
              _directEditPrice = int.tryParse(value.replaceAll(',', '')) ?? 0;
              String commaValue = TStyle.getMoneyPoint(value.replaceAll(',', ''));
              _textEditingController.value = TextEditingValue(
                text: commaValue,
                selection: TextSelection.collapsed(offset: commaValue.length),
              );
              setState(() {});
            },
            maxLines: 1,
            //maxLength: 13,
            textInputAction: TextInputAction.done,
            cursorColor: Colors.black,
            keyboardType: TextInputType.number,
            /*inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ], */ // On
          ),
        ),
        SizedBox(
          height: _directPriceEmptyBoxheight > 0 ? _directPriceEmptyBoxheight : 0,
        ),
        _setMakeSignalBtn,
      ];

  Widget get _setMakeSignalBtn => InkWell(
        onTap: () async {
          if (_isSelectPrice && _isSelectPriceTouchOnce) {
            String result = await Provider.of<SignalProvider>(context, listen: false).addSignal(
              _stockInfoProvider.getStockCode,
              Provider.of<SignalLayerSliderProvider>(context, listen: false).getCurrentPrice.toStringAsFixed(0),
            );
            if (mounted && result != null) {
              Navigator.pop(context, result);
            }
          } else if (!_isSelectPrice) {
            if (_directEditPrice < 1 || _directEditPrice.toString().contains('.') || _isWrong) {
              setState(() {
                _isWrong = true;
                _directEditPrice = 0;
                _textEditingController.value = const TextEditingValue(
                  text: '',
                );
              });
            } else {
              String result = await Provider.of<SignalProvider>(context, listen: false).addSignal(
                _stockInfoProvider.getStockCode,
                _directEditPrice.toStringAsFixed(0),
              );
              if (mounted && result != null) {
                Navigator.pop(context, result);
              }
            }
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          margin: const EdgeInsets.only(
            top: 20,
          ),
          decoration: UIStyle.boxRoundFullColor25c(
            (_isSelectPrice && _isSelectPriceTouchOnce) || (!_isSelectPrice && _directEditPrice != 0 && !_isWrong)
                ? RColor.mainColor
                : RColor.greyBox_dcdfe2,
          ),
          alignment: Alignment.center,
          child: const Text(
            '매도 신호 만들기',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

  Size _getSize() {
    if (_containerKey.currentContext != null) {
      final RenderBox renderBox = _containerKey.currentContext!.findRenderObject() as RenderBox;
      Size size = renderBox.size;
      return size;
    } else {
      return const Size(0, 0);
    }
  }
}

class RoundSliderTrackShape extends SliderTrackShape {
  /// Create a slider track that draws 2 rectangles.
  const RoundSliderTrackShape({this.disabledThumbGapWidth = 2.0});

  /// Horizontal spacing, or gap, between the disabled thumb and the track.
  ///
  /// This is only used when the slider is disabled. There is no gap around
  /// the thumb and any part of the track when the slider is enabled. The
  /// Material spec defaults this gap width 2, which is half of the disabled
  /// thumb radius.
  final double disabledThumbGapWidth;

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double overlayWidth = sliderTheme.overlayShape!.getPreferredSize(isEnabled, isDiscrete).width;
    final double trackHeight = sliderTheme.trackHeight!;
    assert(overlayWidth >= 0);
    assert(trackHeight >= 0);
    assert(parentBox.size.width >= overlayWidth);
    assert(parentBox.size.height >= trackHeight);

    final double trackLeft = offset.dx + overlayWidth / 2;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 4;
    // TODO(clocksmith): Although this works for a material, perhaps the default
    // rectangular track should be padded not just by the overlay, but by the
    // max of the thumb and the overlay, in case there is no overlay.
    final double trackWidth = parentBox.size.width - overlayWidth;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    // If the slider track height is 0, then it makes no difference whether the
    // track is painted or not, therefore the painting can be a no-op.
    if (sliderTheme.trackHeight == 0) {
      return;
    }

    // Assign the track segment paints, which are left: active, right: inactive,
    // but reversed for right to left text.
    final ColorTween activeTrackColorTween = ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    late Paint leftTrackPaint;
    late Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    // Used to create a gap around the thumb iff the slider is disabled.
    // If the slider is enabled, the track can be drawn beneath the thumb
    // without a gap. But when the slider is disabled, the track is shortened
    // and this gap helps determine how much shorter it should be.
    // TODO(clocksmith): The new Material spec has a gray circle in place of this gap.
    double horizontalAdjustment = 0.0;
    if (!isEnabled) {
      final double disabledThumbRadius = sliderTheme.thumbShape!.getPreferredSize(false, isDiscrete).width / 2.0;
      final double gap = disabledThumbGapWidth * (1.0 - enableAnimation.value);
      horizontalAdjustment = disabledThumbRadius + gap;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final Rect leftTrackSegment = Rect.fromLTRB(trackRect.left, trackRect.top, thumbCenter.dx - horizontalAdjustment, trackRect.bottom);

    // Left Arc
    context.canvas.drawArc(
        Rect.fromCircle(center: Offset(trackRect.left, trackRect.top + sliderTheme.trackHeight! * 1 / 2), radius: sliderTheme.trackHeight! * 1 / 2),
        -180 * 3 / 2, // -270 degrees
        180, // 180 degrees
        false,
        trackRect.left - thumbCenter.dx == 0.0 ? rightTrackPaint : leftTrackPaint);

// Right Arc
    context.canvas.drawArc(
        Rect.fromCircle(center: Offset(trackRect.right, trackRect.top + sliderTheme.trackHeight! * 1 / 2), radius: sliderTheme.trackHeight! * 1 / 2),
        -180 / 2, // -90 degrees
        180, // 180 degrees
        false,
        trackRect.right - thumbCenter.dx == 0.0 ? leftTrackPaint : rightTrackPaint);

    context.canvas.drawRect(leftTrackSegment, leftTrackPaint);
    final Rect rightTrackSegment = Rect.fromLTRB(thumbCenter.dx + horizontalAdjustment, trackRect.top, trackRect.right, trackRect.bottom);
    context.canvas.drawRect(rightTrackSegment, rightTrackPaint);
  }
}
