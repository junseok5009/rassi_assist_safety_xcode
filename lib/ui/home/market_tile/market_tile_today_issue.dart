import 'dart:async';
import 'dart:ui' as du_text_direction;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue03.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue09.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/custom/custom_bubble/CustomBubbleNode.dart';
import 'package:rassi_assist/ui/custom/custom_bubble/CustomBubbleRoot.dart';
import 'package:rassi_assist/ui/market/issue_new_viewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class MarketTileTodayIssue extends StatefulWidget {
  const MarketTileTodayIssue({
    super.key,
    required this.issue09,
  });

  final Issue09 issue09;

  @override
  State<MarketTileTodayIssue> createState() => MarketTileTodayIssueState();
}

class MarketTileTodayIssueState extends State<MarketTileTodayIssue> with TickerProviderStateMixin {
  final List<Widget> _bubbleWidgetList = [];
  final List<AnimationController> _bubbleChartAniControllerList = [];
  bool _isStartBubbleAnimation = false;

  // 버블 타임랩스
  int _selectTimeLapseIndex = 0;
  int _timeLapselastDataIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectTimeLapseIndex = widget.issue09.listData.indexWhere((element) => element.lastDataYn == 'Y');
    _timeLapselastDataIndex = _selectTimeLapseIndex;
    if (_selectTimeLapseIndex == -1) {
      _selectTimeLapseIndex = 0;
      _timeLapselastDataIndex = _selectTimeLapseIndex = 0;
    }
    if (widget.issue09.listData.isNotEmpty) {
      _setBubbleNode().then((value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isStartBubbleAnimation && _bubbleWidgetList.isNotEmpty) {
            _isStartBubbleAnimation = true;
            _bubbleChartAniStart().then(
              (_) async {
                _isStartBubbleAnimation = false;
                //await _disposeAniControllerList();
              },
            );
          }
        });
      });
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    for (var element in _bubbleChartAniControllerList) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 홈_마켓뷰
        _div0Title,
        _bubbleChartView,
        widget.issue09.listData.isEmpty ? CommonView.setNoDataTextView(200, '이슈 데이터가 없습니다.') : _bubbleTimeLapseView,
      ],
    );
  }

  /// make Widget
  Widget get _bubbleChartView {
    if (_bubbleWidgetList.isEmpty) return const SizedBox();
    return Container(
      width: double.infinity,
      //height: (AppGlobal().deviceWidth - (AppGlobal().deviceWidth / 10)),
      height: (AppGlobal().deviceWidth),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: _bubbleWidgetList,
      ),
    );
  }

  Widget get _bubbleTimeLapseView {
    if (widget.issue09.listData.isEmpty) return const SizedBox();
    return Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        Image.asset(
          'images/icon_time_lapse_clock_grey.png',
          width: 20,
        ),
        Expanded(
          child: SfSliderTheme(
            data: SfSliderThemeData(
              overlayColor: RColor.greyBox_dcdfe2.withOpacity(0.5),
              overlayRadius: 20,
              activeTrackHeight: 15,
              activeDividerColor: RColor.grey_c8cace,
              activeTrackColor: RColor.greyBox_dcdfe2,
              activeDividerRadius: 2.5,
              thumbColor: Color(0xffABB0BB),
              inactiveTrackHeight: 15,
              //inactiveDividerColor: RColor.bubbleChartGrey,
              inactiveTrackColor: RColor.greyBox_dcdfe2,
              inactiveDividerRadius: 0,
            ),
            child: SfSlider(
              min: 0,
              max: widget.issue09.listData.length - 1,
              value: _selectTimeLapseIndex,
              interval: 1,
              stepSize: 1,
              showDividers: true,
              thumbShape: _SfThumbShape(bubbleTimeLapseList: widget.issue09.listData),
              onChanged: (dynamic newValue) async {
                //DLog.e('newValue : $newValue');
                if (newValue > _timeLapselastDataIndex) {
                  //commonShowToast('미래 데이터 입니다.');
                } else {
                  _selectTimeLapseIndex = (newValue as double).toInt();
                  await _setBubbleNode();
                  setState(() {});
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_isStartBubbleAnimation && _bubbleWidgetList.isNotEmpty) {
                      _isStartBubbleAnimation = true;
                      _bubbleChartAniStart().then((_) async {
                        _isStartBubbleAnimation = false;
                        //await _disposeAniControllerList();
                      });
                    }
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget get _div0Title {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '오늘의 이슈',
            style: TStyle.defaultTitle,
          ),
          Text(
            '${widget.issue09.issueDate.substring(4, 6)}/${widget.issue09.issueDate.substring(6)}기준',
            style: const TextStyle(
              color: RColor.greyMore_999999,
            ),
          ),
        ],
      ),
    );
  }

  /// make function
  Future<void> _setBubbleNode() async {
    for (var element in _bubbleChartAniControllerList) {
      element.dispose();
    }
    _bubbleChartAniControllerList.clear();
    _bubbleWidgetList.clear();

    List<Issue03> issueList = widget.issue09.listData[_selectTimeLapseIndex].listData;

    issueList.sort(
      (a, b) => double.parse(b.avgFluctRate).abs().compareTo(double.parse(a.avgFluctRate).abs()),
    );

    List<CustomBubbleNode> listNodes = [];
    TextStyle tStyle;
    Color? bgColor;
    Color txtColor = Colors.white;
    String name = '';
    double minValue = 0;
    FontWeight fontWeight = FontWeight.bold;
    double padding = 0;

    /* TEST
    issueList.asMap().forEach((key, value) {
      issueList[key].avgFluctRate = '0.1';
    });*/
    bool isAllSameValue = issueList.every((val1) => val1.avgFluctRate == issueList.first.avgFluctRate);

    for (int i = 0; i < issueList.length; i++) {
      txtColor = Colors.white;
      Issue03 item = issueList[i];
      num value = double.parse(item.avgFluctRate);

      //최대값 찾기 > 최대값의 1/15이 최소값임
      if (i == 0) {
        minValue = (double.parse((value.abs() / 15).toStringAsFixed(2)));
      }
      fontWeight = FontWeight.w700;
      padding = 10;
      if (value > 3) {
        bgColor = RColor.bubbleChartStrongRed;
        padding = 2.0 * value;
      } else if (value > 1) {
        bgColor = RColor.bubbleChartRed;
        padding = 3.0 * value;
        fontWeight = FontWeight.w600;
      } else if (value > 0.1) {
        bgColor = RColor.bubbleChartWeakRed;
        padding = 10.0 * value;
        fontWeight = FontWeight.w400;
        txtColor = RColor.bubbleChartTxtColorRed;
      } else if (value > -0.1) {
        bgColor = RColor.bubbleChartGrey;
        value = value.abs();
        padding = 7;
        fontWeight = FontWeight.w400;
        txtColor = const Color(0xff8a8a8a);
      } else if (value > -1) {
        bgColor = RColor.bubbleChartWeakBlue;
        value = value.abs();
        padding = 10.0 * value;
        fontWeight = FontWeight.w400;
        txtColor = RColor.bubbleChartTxtColorBlue;
      } else if (value > -5) {
        bgColor = RColor.bubbleChartBlue;
        value = value.abs();
        padding = 3.0 * value;
        fontWeight = FontWeight.w600;
      } else if (value <= -5) {
        bgColor = RColor.bubbleChartStrongBlue;
        value = value.abs();
        padding = 2.0 * value;
      } else {
        bgColor = RColor.bubbleChartGrey;
        value = value.abs();
        padding = 12;
        fontWeight = FontWeight.w400;
        txtColor = const Color(0xff8a8a8a);
      }
      if (value.abs() < minValue) {
        value = minValue;
      }
      tStyle = TextStyle(
        fontWeight: fontWeight,
        fontSize: 20,
        color: txtColor,
      );
      name = item.keyword.replaceAll(' ', '\n');
      CustomBubbleNode customBubbleNode = CustomBubbleNode.leaf(
        value: value,
        index: i,
        options: CustomBubbleOptions(
          color: bgColor,
          onTap: () {
            CustomFirebaseClass.logEvtTodayIssue(
              item.keyword,
            );
            Navigator.push(
              context,
              CustomNvRouteClass.createRouteData(
                const IssueNewViewer(),
                // const IssueViewer(),
                RouteSettings(
                  arguments: PgData(
                    userId: '',
                    pgSn: item.newsSn,
                    pgData: item.issueSn,
                  ),
                ),
              ),
            );
          },
          child: FittedBox(
            fit: BoxFit.cover,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: AutoSizeText(
                name,
                style: tStyle,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ),
        ),
      );
      listNodes.add(customBubbleNode);
      _bubbleChartAniControllerList.add(
        AnimationController(
          duration: Duration(milliseconds: 2000 + 300 * i),
          vsync: this,
        ),
      );
    }

    List<Widget> bubbleWidgetList = CustomBubbleRoot(
      root: CustomBubbleNode.node(
        children: listNodes,
        padding: 1,
      ),
      size: Size(
        (AppGlobal().deviceWidth),
        (AppGlobal().deviceWidth),
      ),
      stretchFactor: isAllSameValue ? 0.5 : 1,
    ).nodes.fold([], (result, node) {
      return result
        ..add(
          Positioned(
            key: node.key,
            top: node.y! - node.radius!,
            left: node.x! - node.radius!,
            width: node.radius! * 2,
            height: node.radius! * 2,
            child: ScaleTransition(
              scale: Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _bubbleChartAniControllerList[node.index],
                  curve: Curves.elasticOut,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    border: node.options?.border ?? const Border(),
                    color: node.options?.color ?? RColor.purpleBgBasic_dbdbff,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    //highlightColor: Colors.white,
                    borderRadius: BorderRadius.circular(node.radius! * 2),
                    onTap: node.options?.onTap,
                    child: SizedBox(
                      width: node.radius! * 2,
                      height: node.radius! * 2,
                      child: Center(child: node.options?.child ?? Container()),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
    });

    _bubbleWidgetList.addAll(bubbleWidgetList);
    return;
  }

  Future<void> _bubbleChartAniStart() async {
    _bubbleChartAniControllerList.asMap().forEach((key, value) async {
      await Future.delayed(
          const Duration(
            milliseconds: 200,
          ), () async {
        if (mounted) {
          value.forward();
          //_bubbleChartAniControllerList.remove(value);
        }
      });
    });
    return;
  }
}

class _SfThumbShape extends SfThumbShape {
  final List<Issue09TimeLapse> bubbleTimeLapseList;

  _SfThumbShape({required this.bubbleTimeLapseList});

  @override
  void paint(PaintingContext context, Offset center,
      {required RenderBox parentBox,
      required RenderBox? child,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> enableAnimation,
      required du_text_direction.TextDirection textDirection,
      required SfThumb? thumb}) {
    final double radius = getPreferredSize(themeData).width / 2;
    final bool hasThumbStroke = themeData.thumbStrokeColor != null &&
        themeData.thumbStrokeColor != Colors.transparent &&
        themeData.thumbStrokeWidth != null &&
        themeData.thumbStrokeWidth! > 0;

    if (themeData is SfRangeSliderThemeData &&
        !hasThumbStroke &&
        themeData.thumbColor != Colors.transparent &&
        themeData.overlappingThumbStrokeColor != null) {
      context.canvas.drawCircle(
          center,
          radius,
          Paint()
            ..color = themeData.overlappingThumbStrokeColor!
            ..style = PaintingStyle.stroke
            ..isAntiAlias = true
            ..strokeWidth = 1.0);
    }

    if (paint == null) {
      paint = Paint();
      paint.isAntiAlias = true;
      paint.color =
          ColorTween(begin: themeData.disabledThumbColor, end: themeData.thumbColor).evaluate(enableAnimation)!;
    }

    context.canvas.drawCircle(center, radius, paint);
    if (child != null) {
      context.paintChild(child, Offset(center.dx - (child.size.width) / 2, center.dy - (child.size.height) / 2));
    }

    if (themeData.thumbStrokeColor != null && themeData.thumbStrokeWidth != null && themeData.thumbStrokeWidth! > 0) {
      final Paint strokePaint = Paint()
        ..color = themeData.thumbStrokeColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = themeData.thumbStrokeWidth! > radius ? radius : themeData.thumbStrokeWidth!;
      context.canvas.drawCircle(center,
          themeData.thumbStrokeWidth! > radius ? radius / 2 : radius - themeData.thumbStrokeWidth! / 2, strokePaint);
    }

    // "문구영역" 텍스트를 원 아래에 추가
    String time = bubbleTimeLapseList[currentValue as int].timeLapse;
    final TextSpan span = TextSpan(
      text: '${time.substring(0, 2)}:${time.substring(
        2,
      )}',
      style: const TextStyle(
        color: RColor.greyMore_999999,
        fontSize: 14.0,
      ),
    );
    final TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: du_text_direction.TextDirection.ltr,
    );
    tp.layout();
    tp.paint(context.canvas, Offset(center.dx - tp.width / 2, center.dy + radius + 5));
  }
}
