import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_sns/tr_sns07.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/sub/social_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 커뮤니티 활동 급상승(소셜지수)
class HomeTileSocial extends StatefulWidget {
  const HomeTileSocial({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeTileSocialState();
}

class HomeTileSocialState extends State<HomeTileSocial>{
  final AppGlobal _appGlobal = AppGlobal();
  late SharedPreferences _prefs;
  String _userId = '';

  final List<Sns07Elapsed> _timelineList = [];
  final List<SnsStock> _socialList = [];
  var _currentSliderValue = 0.0;

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? _appGlobal.userId;
  }

  @override
  void initState() {
    super.initState();
    _loadPrefData().then((_) {
      _requestTr();
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _requestTr() {
    _fetchPosts(
        TR.SNS07,
        jsonEncode(<String, String>{
          'userId': _userId,
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '커뮤니티 활동 급상승',
                style: TStyle.defaultTitle,
              ),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: const Text(
                  '더보기',
                  style: TextStyle(
                    color: RColor.greyMore_999999,
                  ),
                ),
                onTap: () async {
                  Navigator.pushNamed(context, SocialListPage.routeName, arguments: PgData(pgSn: ''));
                },
              ),
            ],
          ),

          Visibility(
            visible: _socialList.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 20,
              ),
              child: SliderTheme(
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
                  //valueIndicatorColor: Colors.white,
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
              ),
            ),
          ),

          // 종목 리스트
          _socialList.isNotEmpty
              ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.zero,
                itemCount: _socialList.length,
                itemBuilder: (context, index) {
                  return TileSns03N(_socialList[index], index);
                },
              )
              : CommonView.setNoDataTextView(130, '현재 커뮤니티 활동이\n평소보다 급상승한 종목이 없습니다.'),
        ],
      ),
    );
  }

  _setSliderValue(double value) {
    if (_timelineList.isNotEmpty && _timelineList.length > value.toInt()) {
      _currentSliderValue = value;
      _socialList.clear();
      _socialList.addAll(_timelineList[value.toInt()].listData);
      setState(() {});
    }
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    DLog.w('$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http
          .post(
            url,
            body: json,
            headers: Net.headers,
          )
          .timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      if (mounted) CommonPopup.instance.showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    if (trStr == TR.SNS07) {
      _timelineList.clear();
      final TrSns07 resData = TrSns07.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        var timeList = resData.retData.listTimeline;
        if (timeList.isNotEmpty) {
          _timelineList.addAll(List.from(timeList.reversed));
          _setSliderValue(timeList.length.toDouble() - 1.0);
        }
        setState(() {});
      }
    }
  }
}

//화면구성
class TileSns03N extends StatelessWidget {
  final SnsStock item;
  final int index;

  const TileSns03N(this.item, this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: index == 0 ? 0 : 12,
      ),
      alignment: Alignment.centerLeft,
      child: InkWell(
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    item.stockName,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  Text(
                    item.stockCode,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xff999999),
                    ),
                  ),
                ],
              ),
              CommonView.setFluctuationRateBox(value: item.fluctuationRate, fontSize: 15,),
            ],
          ),
        ),
        onTap: () {
          // 종목홈
          basePageState.goStockHomePage(
            item.stockCode,
            item.stockName,
            Const.STK_INDEX_HOME,
          );
        },
      ),
    );
  }
}

class CustomSliderThumbCircle extends SliderComponentShape {
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
}
