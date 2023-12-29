import 'package:flutter/cupertino.dart';
import 'package:rassi_assist/common/const.dart';

/// [종목비교] TR_COMPARE02 _ STOCK 클래스
class StockCompare02 {
  final String stockCode;
  final String stockName;
  final String latestQuarter; //최근 반영된 년도/쿼터 >> SCALE, GROWTH에서만 나옴

  // DEFINE COMPARE02 SCALE
  final String marketValue; // 시가 총액
  final String sales; // 매출액
  final String salesProfit; // 영업 이익

  // DEFINE COMPARE02 VALUE
  String per; // per
  final String pbr; // pbr
  final String dividendRate; // 배당 수익률

  // DEFINE COMPARE02 GROWTH
  final String salesRateQuart; // 매출액 증가율 (전년 동기 대비)
  final String profitRateQuart; // 영업이익 증가율 (전년 동기 대비)

  // DEFINE COMPARE02 FLUCT
  final String fluctYear1; // 등락률 - 최근 1년
  final String top52FluctRate; // 52주 최고가 대비 변동률
  final String low52FluctRate; //52주 최저가 대비 변동률

  StockCompare02({
    this.stockCode = '',
    this.stockName = '',
    this.latestQuarter = '',
    this.marketValue = '0',
    this.sales = '0',
    this.salesProfit = '0',
    this.per = '0',
    this.pbr = '0',
    this.dividendRate = '0',
    this.salesRateQuart = '0',
    this.profitRateQuart = '0',
    this.fluctYear1 = '0',
    this.top52FluctRate = '0',
    this.low52FluctRate = '0',
  });

  factory StockCompare02.fromJson(Map<String, dynamic> json) {
    return StockCompare02(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      latestQuarter: json['latestQuarter'] ?? '',
      marketValue: json['marketValue'] ?? '0',
      sales: json['sales'] ?? '0',
      salesProfit: json['salesProfit'] ?? '0',
      per: json['per'] ?? '0',
      pbr: json['pbr'] ?? '0',
      dividendRate: json['dividendRate'] ?? '0',
      salesRateQuart: json['salesRateQuart'] ?? '0',
      profitRateQuart: json['profitRateQuart'] ?? '0',
      fluctYear1: json['fluctYear1'] ?? '0',
      top52FluctRate: json['top52FluctRate'] ?? '0',
      low52FluctRate: json['low52FluctRate'] ?? '0',
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName';
  }
}

class YearQuarterClass {
  String year = '';
  String quarter = '';
  List<String> listStockName = const [];

  YearQuarterClass(String vYear, String vQuarter, List<String> vListStockName) {
    this.year = vYear;
    this.quarter = vQuarter;
    this.listStockName = vListStockName;
  }

  @override
  String toString() {
    return 'year:$year|quarter:$quarter|listStockName:[${listStockName.toString()}]';
  }
}

class TileYearQuarterListView extends StatelessWidget {
  //const TileYearQuarterListView({Key? key}) : super(key: key);
  final List<YearQuarterClass> _listYQC;

  TileYearQuarterListView(this._listYQC);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _listYQC.length,
        itemBuilder: (context, index) {
          String strStockNames = '';
          TextStyle tStyle = const TextStyle(
            //작은 그레이 텍스트
            fontSize: 12,
            color: RColor.new_basic_text_color_strong_grey,
          );
          for (int i = 0; i < _listYQC[index].listStockName.length; i++) {
            if (i != 0) {
              strStockNames += ', ';
            }
            strStockNames += _listYQC[index].listStockName[i];
          }
          if (_listYQC.length > 1 && index == 0) {
            tStyle = const TextStyle(
              fontSize: 12,
              color: RColor.sigBuy,
            );
          }
          return Text(
            '${_listYQC[index].year}/${_listYQC[index].quarter}Q반영 종목 : $strStockNames',
            style: tStyle,
          );
        });
  }
}
