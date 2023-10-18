import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';


/// 2020.10.06 - JY
/// 종목 과거 매매신호 타임라인
class TrSignal07 {
  final String retCode;
  final String retMsg;
  final Signal07? retData;

  TrSignal07({this.retCode = '', this.retMsg = '', this.retData});

  factory TrSignal07.fromJson(Map<String, dynamic> json) {
    return TrSignal07(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null ? null : Signal07.fromJson(json['retData'])
    );
  }
}


class Signal07 {
  final String stockCode;
  final String stockName;
  final String beginDate;
  final String endDate;
  final String tradeCount;
  final String winCount;
  final String holdingDays;
  final List<ChartDataR> listData;

  Signal07({
    this.stockCode = '', this.stockName = '',
    this.beginDate = '', this.endDate = '',
    this.tradeCount = '', this.winCount = '',
    this.holdingDays = '', this.listData = const [],
  });

  factory Signal07.fromJson(Map<String, dynamic> json) {
    var list = json['list_SigChart'] as List;
    List<ChartDataR> listChart = list.map((e) => ChartDataR.fromJson(e)).toList();

    return Signal07(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      beginDate: json['beginDate'] ?? '',
      endDate: json['endDate'] ?? '',
      tradeCount: json['tradeCount'] ?? '',
      winCount: json['winCount'] ?? '',
      holdingDays: json['holdingDays'] ?? '',
      listData: listChart,
    );
  }
}


class ChartDataR {
  final String tradeDate;
  final String tradePrc;
  final String flag;
  final String profitRate;

  ChartDataR({
    this.tradeDate = '', this.tradePrc = '',
    this.flag = '', this.profitRate = ''
  });

  factory ChartDataR.fromJson(Map<String, dynamic> json) {
    return ChartDataR(
      tradeDate: json['td'],
      tradePrc: json['tp'],
      flag: json['tf'],
      profitRate: json['pr'],
    );
  }

  @override
  String toString() {
    return '$tradeDate|$tradePrc|$flag|$profitRate';
  }
}


//화면구성 - AI 매매신호 내역
class TileSignal07 extends StatelessWidget {
  final ChartDataR item;
  TileSignal07(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0, right: 10.0,),
      decoration: const BoxDecoration(
        color: RColor.bgWeakGrey,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
      ),
      child: Container(
        width: double.infinity,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _setListItem1(),
            _setListItem2(),
            _setListItem3(),
            _setListItem4(),
          ],
        ),
      ),
    );
  }

  //날짜
  Widget _setListItem1() {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(getDateFormat(item.tradeDate),
              style: TStyle.contentSBLK,),
            // Text(item.stockCode, style: TStyle.textSGrey,),
          ],
        ),
      ),
    );
  }

  //구분
  Widget _setListItem2() {
    return Expanded(
      flex: 2,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${_getFlagString(item.flag)}', style: _getFlagStyle(item.flag),),
          ],
        ),
      ),
    );
  }

  //가격
  Widget _setListItem3() {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(TStyle.getMoneyPoint(item.tradePrc),
              style: TStyle.contentSBLK,)
          ],
        ),
      ),
    );
  }

  //수익률
  Widget _setListItem4() {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _getProfit(item.profitRate),
        ],
      ),
    );
  }



  //날짜 형식 표시
  String getDateFormat(String date) {
    String rtStr = '';
    if(date.length > 7) {
      rtStr = '${date.substring(0, 4)}.${date.substring(4, 6)}.${date.substring(6, 8)}';
      return rtStr;
    }
    return '';
  }

  String _getFlagString(String flag) {
    if(flag == 'B') return '매수';
    else if(flag == 'S') return '매도';
    return '';
  }

  TextStyle _getFlagStyle(String flag) {
    if(flag == 'B') return TStyle.textMBuy;
    else if(flag == 'S') return TStyle.textMSell;
    return TStyle.contentMGrey;
  }

  Widget _getProfit(String orgStr) {
    if(orgStr != null && orgStr.length > 0) {
      if(orgStr.contains('-'))
        return Text('$orgStr%', style: TStyle.textMSell,);
      else
        return Text('+$orgStr%', style: TStyle.textMBuy,);
    } else {
      return Text('');
    }
  }
}
