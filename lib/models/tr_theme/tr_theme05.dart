import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/models/tr_atom.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

/// 2022.05.12
/// 테마 주도주(종목) 조회
class TrTheme05 extends TrAtom {
  final Theme05 retData;

  TrTheme05({
    String retCode = '',
    String retMsg = '',
    this.retData = defTheme05,
  }) : super(retCode: retCode, retMsg: retMsg);

  factory TrTheme05.fromJson(Map<String, dynamic> json) {
    return TrTheme05(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: Theme05.fromJson(json['retData']),
    );
  }
}

const defTheme05 = Theme05();

class Theme05 {
  final String selectDiv;
  final String elapsedDays;
  final List<Theme05StockChart> listStock;

  const Theme05({
    this.selectDiv = '',
    this.elapsedDays = '',
    this.listStock = const [],
  });

  factory Theme05.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Stock'];
    return Theme05(
      selectDiv: json['selectDiv'],
      elapsedDays: json['elapsedDays'],
      listStock: jsonList == null ? [] : (jsonList as List).map((i) => Theme05StockChart.fromJson(i)).toList(),
    );
  }
}

class Theme05StockChart {
  final String stockCode;
  final String stockName;
  final String currentPrice;
  final String fluctuationRate;
  final String fluctuationAmt;
  final String increaseRate;
  final String candleDiv;
  final List<Theme05ChartData> listChart;

  Theme05StockChart({
    this.stockCode = '',
    this.stockName = '',
    this.currentPrice = '',
    this.fluctuationRate = '',
    this.fluctuationAmt = '',
    this.increaseRate = '',
    this.candleDiv = '',
    this.listChart = const [],
  });

  factory Theme05StockChart.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Chart'];
    return Theme05StockChart(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      currentPrice: json['currentPrice'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
      fluctuationAmt: json['fluctuationAmt'] ?? '',
      increaseRate: json['increaseRate'] ?? '',
      candleDiv: json['candleDiv'] ?? '',
      listChart: jsonList == null ? [] : (jsonList as List).map((i) => Theme05ChartData.fromJson(i)).toList(),
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$currentPrice|$fluctuationRate|$fluctuationAmt';
  }
}

class Theme05ChartData {
  final String td;
  final String tp;
  final String tt; // 거래시간 (candleDiv == MIN 일 때만)

  Theme05ChartData({this.td = '', this.tp = '', this.tt = ''});

  factory Theme05ChartData.fromJson(Map<String, dynamic> json) {
    return Theme05ChartData(
      td: json['td'] ?? '',
      tp: json['tp'] ?? '0',
      tt: json['tt'] ?? '',
    );
  }

  @override
  String toString() {
    return '$td|$tp|$tt';
  }
}

//화면구성
class TileTheme05 extends StatelessWidget {
  final Theme05StockChart item;
  final String selDiv;
  final int index;

  const TileTheme05(this.index, this.item, this.selDiv, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        //height: 150,
        margin: const EdgeInsets.only(
          top: 15,
        ),
        //decoration: UIStyle.boxRoundLine6(),
        child: _setStockContainer(),
      ),
      onTap: () {
        basePageState.goStockHomePage(
          item.stockCode,
          item.stockName,
          Const.STK_INDEX_HOME,
        );
      },
    );
  }

  Widget _setStockContainer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            '${index + 1}  ${item.stockName}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          selDiv == 'SHORT' ? '최근 5일간' : '이번 추세기간', //'최근 $days일간',
          style: const TextStyle(
            fontSize: 15,
            color: RColor.greyBasic_8c8c8c,
          ),
        ),
        CommonView.setFluctuationRateBox(
          marginEdgeInsetsGeometry: const EdgeInsets.only(
            left: 15,
          ),
          value: item.increaseRate,
        ),
      ],
    );
  }
}
