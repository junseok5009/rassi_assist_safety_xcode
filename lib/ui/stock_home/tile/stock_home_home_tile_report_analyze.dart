import 'dart:math';

import 'package:rassi_assist/custom_lib/charts_common/common.dart' as charts_common;
import 'package:rassi_assist/custom_lib/charts_flutter_new/flutter.dart' as charts;
import 'package:rassi_assist/custom_lib/charts_flutter_new/text_element.dart'
    as charts_text_element;
import 'package:rassi_assist/custom_lib/charts_flutter_new/text_style.dart' as charts_text_style;
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_invest/tr_invest01.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

import '../../../../common/const.dart';
import '../page/stock_recent_report_list_page.dart';
import '../report_analyze_charts/report_analyze_chart1_page.dart';
import '../report_analyze_charts/report_analyze_chart2_page.dart';
import '../report_analyze_charts/report_analyze_chart3_page.dart';

/// 2023.02.14_HJS
/// 종목홈(개편)_홈_외국인/기관 매매동향

class StockHomeHomeTileReportAnalyze extends StatefulWidget {
  static final GlobalKey<StockHomeHomeTileReportAnalyzeState> globalKey =
      GlobalKey();
  StockHomeHomeTileReportAnalyze() : super(key: globalKey);
  @override
  State<StockHomeHomeTileReportAnalyze> createState() =>
      StockHomeHomeTileReportAnalyzeState();
}

class StockHomeHomeTileReportAnalyzeState
    extends State<StockHomeHomeTileReportAnalyze>
    with AutomaticKeepAliveClientMixin<StockHomeHomeTileReportAnalyze> {
  int _divIndex = 0; // 0 : 목표가 / 1 : 발생트렌드 / 2 : 발행증권사

  // 종목 바뀌면 다른화면에서도 이거 호출해서 갱신해줘야함

  initPage() {
    if (_divIndex == 0 &&
        ReportAnalyzeChart1Page.globalKey.currentState != null) {
      ReportAnalyzeChart1Page.globalKey.currentState?.initPage();
    } else {
      setState(() {
        _divIndex = 0;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    initPage();
  }

  @override
  void setState(VoidCallback fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '리포트 분석',
                style: TStyle.title18T,
              ),
              const SizedBox(
                height: 20,
              ),
              _setDivButtons(),
              _divIndex == 0
                  ? ReportAnalyzeChart1Page()
                  : _divIndex == 1
                      ? const ReportAnalyzeChart2Page()
                      : const ReportAnalyzeChart3Page(),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  // 최신 종목 리포트 리스트 페이지
                  basePageState.callPageRouteData(
                    const StockRecentReportListPage(),
                    PgData(
                      stockName: AppGlobal().stkName,
                      stockCode: AppGlobal().stkCode,
                    ),
                  );
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 15),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: UIStyle.boxRoundLine6(),
                  alignment: Alignment.center,
                  child: const Text(
                    '최신 리포트 더보기',
                    style: TStyle.subTitle16,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: RColor.new_basic_grey,
          height: 15.0,
        ),
      ],
    );
  }

  Widget _setDivButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: InkWell(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 1.4,
                  color: _divIndex == 0 ? Colors.black : RColor.lineGrey,
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(
                    5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '목표가',
                  style: _divIndex == 0
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (_divIndex != 0) {
                setState(() {
                  _divIndex = 0;
                });
              }
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: InkWell(
            child: Container(
              //margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.symmetric(
                  horizontal: BorderSide(
                    width: 1.4,
                    color: _divIndex == 1 ? Colors.black : RColor.lineGrey,
                  ),
                  vertical: BorderSide(
                    width: _divIndex == 1 ? 1.4 : 0,
                    color: _divIndex == 1 ? Colors.black : Colors.transparent,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '발생트렌드',
                  style: _divIndex == 1
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (_divIndex != 1) {
                setState(() {
                  _divIndex = 1;
                });
              }
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: InkWell(
            child: Container(
              //margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 1.4,
                  color: _divIndex == 2 ? Colors.black : RColor.lineGrey,
                ),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(
                    5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '발행 증권사',
                  style: _divIndex == 2
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (_divIndex != 2) {
                setState(() {
                  _divIndex = 2;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}

class CustomCircleSymbolRenderer extends charts_common.CircleSymbolRenderer {
  static late Invest01ChartData invest01ChartData;
  static late bool isForeign;
  bool _isShow = false;

  @override
  void paint(charts_common.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int>? dashPattern,
      charts.Color? fillColor,
      charts.FillPatternType? fillPattern,
      charts.Color? strokeColor,
      double? strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);

    if (_isShow) {
      _isShow = false;
    } else {
      _isShow = true;

      canvas.drawRect(
        Rectangle(bounds.left + 12, 0, bounds.width + 80, bounds.height + 62),
        fill: const charts.Color(
          r: 102,
          g: 102,
          b: 102,
          a: 200,
        ),
      );
      var textStyle = charts_text_style.TextStyle();
      textStyle.color = charts.Color.white;
      textStyle.fontSize = 12;

      String color = '#FC525B';
      String strTp = '${TStyle.getMoneyPoint(invest01ChartData.tp)}원';
      String strValue = '';

      if (isForeign) {
        if (int.parse(invest01ChartData.fv) < 0) {
          color = '#6A86E7';
        }
        strValue = '${TStyle.getMoneyPoint(invest01ChartData.fv)}K';
      } else {
        if (int.parse(invest01ChartData.ov) < 0) {
          color = '#6A86E7';
        }
        strValue = '${TStyle.getMoneyPoint(invest01ChartData.ov)}K';
      }

      // 날짜
      canvas.drawText(
        charts_text_element.TextElement(
            TStyle.getDateSFormat(invest01ChartData.td),
            style: textStyle),
        (bounds.left + 20).round(),
        12.round(),
      );

      canvas.drawPoint(
        point: Point((bounds.left + 23), 34),
        radius: 4,
        fill: charts.Color.fromHex(code: color),
        stroke: charts.Color.white,
        strokeWidthPx: 1,
      );

      canvas.drawText(
        charts_text_element.TextElement(strValue, style: textStyle),
        (bounds.left + 30).round(),
        29.round(),
      );

      canvas.drawPoint(
        point: Point((bounds.left + 23), 54),
        radius: 4,
        fill: charts.Color.fromHex(code: '#94b2ff'),
        stroke: charts.Color.white,
        strokeWidthPx: 1,
      );

      canvas.drawText(
        charts_text_element.TextElement(strTp, style: textStyle),
        (bounds.left + 30).round(),
        50.round(),
      );
    }
  }
}
