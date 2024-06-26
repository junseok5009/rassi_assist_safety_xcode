import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class Test1Page extends StatefulWidget {
  const Test1Page({super.key});

  @override
  State<Test1Page> createState() => _Test1PageState();
}

class _Test1PageState extends State<Test1Page> {
  final _testServerTimeData = <String>[
    '0900',
    '0930',
    '1000',
    '1030',
    '1100',
    '1130',
    '1200',
    '1230',
    '1300',
    '1330',
    '1400',
    '1430',
    '1444',
    '1500',
    '1530',
  ];

  final List<DateTime> _chartDateTimeData = <DateTime>[];
  DateTime _value = DateTime.now();

  double _value1 = 12;

  @override
  void initState() {
    super.initState();
    _dateInit().then(
      (value) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.simpleNoTitleWithExit(
        context,
        RColor.bgBasic_fdfdfd,
        Colors.black,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /*SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: RColor.yonbora,
                  inactiveTrackColor: RColor.greySliderBar_ebebeb,
                  inactiveTickMarkColor: Colors.transparent,
                  trackHeight: 9.0,
                  thumbShape: CustomSliderThumbCircle(
                    thumbRadius: 20,
                    min: 0,
                    max: 3,
                    listTitle: _timelineList.map((e) => e.elapsedTmTx).toList(),
                  ),
                  overlayColor: Colors.white.withOpacity(.4),
                  activeTickMarkColor: Colors.white,
                  valueIndicatorShape: SliderComponentShape.noThumb,
                ),
                child: Slider(
                  value: _currentSliderValue,
                  min: 0.0,
                  max: 3.0,
                  divisions: 3,
                  label: _currentSliderValue.round().toString(),
                  onChanged: (double value) {
                    _setSliderValue(value);
                  },
                ),
              ),*/
              /*if (_chartDateTimeData.isNotEmpty)
                Center(
                  child: SfSlider(
                    min: _chartDateTimeData.first,
                    max: _chartDateTimeData.last,
                    value: _value,
                    tooltipTextFormatterCallback: (actualValue, formattedText) => formattedText,
                    //dateIntervalType: DateIntervalType.minutes,
                    //interval: 30,
                    showLabels: true,
                    dateFormat: DateFormat.Hm(),
                    stepDuration: SliderStepDuration(minutes: 30),
                    enableTooltip: true,
                    onChanged: (dynamic newValue) {
                      if(newValue == _chartDateTimeData[13] || newValue == _chartDateTimeData[14]){

                      }else{
                        setState(() {
                          _value = newValue;
                        });
                      }
                    },
                  ),
                ),*/
              if (_chartDateTimeData.isNotEmpty)
                Center(
                  child: SfSliderTheme(
                    data: SfSliderThemeData(
                      activeTrackHeight: 8,
                      activeDividerColor: RColor.bubbleChartGrey,
                      activeTrackColor: Colors.red,
                      inactiveTrackHeight: 8,
                      inactiveDividerColor: RColor.bubbleChartGrey,

                    ),
                    child: SfSlider(
                      min: 0,
                      max: _testServerTimeData.length - 1,
                      value: _value1,
                      interval: 1,
                      stepSize: 1,
                      showDividers: true,
                      onChanged: (dynamic newValue) {
                        DLog.e('newValue : $newValue');
                        if (newValue == 13 || newValue == 14) {

                        } else {
                          setState(() {
                            _value1 = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _dateInit() async {
    DateTime now = DateTime.now();
    _chartDateTimeData.clear();
    _testServerTimeData.asMap().forEach((key, value) {
      _chartDateTimeData.add(
        DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(value.substring(0, 2)),
          int.parse(value.substring(
            3,
          )),
        ),
      );
    });
    _value = _chartDateTimeData[12];
    _chartDateTimeData.forEach((element) {
      DLog.e('element : $element');
    });
  }
}

/*class CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final int min;
  final int max;
  final List<String> listTitle;

  CustomSliderThumbCircle({
    required this.thumbRadius,
    this.min = 0,
    this.max = 10,
    required this.listTitle,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = RColor.purpleBasic_6565ff //Thumb Background Color
      ..style = PaintingStyle.fill;

    TextSpan span = TextSpan(
      style: const TextStyle(
        fontSize: 14,
        //fontWeight: FontWeight.w500,
        color: Colors.white, //Text Color of Value on Thumb
      ),
      text: listTitle[getValue(value)],
    );

    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    Offset textCenter =
        //Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    RRect fullRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, center.dy), width: tp.width + 24, height: tp.height + 16),
      Radius.circular(thumbRadius),
    );
    canvas.drawRRect(fullRect, paint);
    //canvas.drawCircle(center, thumbRadius * .9, paint);
    tp.paint(canvas, textCenter);
  }

  int getValue(double value) {
    return (min + (max - min) * value).round();
  }
}*/
