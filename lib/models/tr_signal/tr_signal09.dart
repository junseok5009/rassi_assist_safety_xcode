import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';

/// 2021.02.03
/// 현재의 매매신호 현황
class TrSignal09 {
  final String retCode;
  final String retMsg;
  final Signal09 resData;

  TrSignal09({this.retCode = '', this.retMsg = '', this.resData = defSignal09});

  factory TrSignal09.fromJson(Map<String, dynamic> json) {
    return TrSignal09(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        resData: json['retData'] != null
            ? Signal09.fromJson(json['retData'])
            : defSignal09,
    );
  }
}

const defSignal09 = Signal09();

class Signal09 {
  final String noticeCode;
  final String noticeText;
  final String processText;
  final String remainTime;
  final String updateDttm;
  final String buyCount;
  final String sellCount;
  final List<SignalCount> listData;

  const Signal09({
    this.noticeCode = '',
    this.noticeText = '',
    this.processText = '',
    this.remainTime = '',
    this.updateDttm = '',
    this.buyCount = '',
    this.sellCount = '',
    this.listData = const [],
  });

  bool isEmpty() {
    if (noticeCode.isEmpty && noticeText.isEmpty && listData.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

/*  Signal09.empty() {
    noticeCode = '';
    noticeText = '';
    processText = '';
    remainTime = '';
    updateDttm = '';
    buyCount = '0';
    sellCount = '0';
    listData = [];
  }*/

  factory Signal09.fromJson(Map<String, dynamic> json) {
    return Signal09(
      noticeCode: json['noticeCode'] ?? '',
      noticeText: json['noticeText'] ?? '',
      processText: json['processText'] ?? '',
      remainTime: json['remainTime'] ?? '',
      updateDttm: json['updateDttm'] ?? '',
      buyCount: json['buyCount'] ?? '0',
      sellCount: json['sellCount'] ?? '0',
      listData: (json['list_Signal'] == null)
          ? []
          : (json['list_Signal'] as List)
              .map((i) => SignalCount.fromJson(i))
              .toList(),
    );
  }
}

class SignalCount {
  // 장 종료 전
  final String tradeFlag;
  final String tradeTime;
  final String tradeCount;
  final String honorDiv;

  // 장 종료 후
  final String stockCode;
  final String stockName;
  final String profitRate;
  final String holdingDays;

  SignalCount({
    this.tradeFlag = '',
    this.tradeTime = '',
    this.tradeCount = '',
    this.honorDiv = '',
    this.stockCode = '',
    this.stockName = '',
    this.profitRate = '',
    this.holdingDays = '',
  });

  factory SignalCount.fromJson(Map<String, dynamic> json) {
    return SignalCount(
      tradeFlag: json['tradeFlag'] ?? '',
      tradeTime: json['tradeTime'] ?? '',
      tradeCount: json['tradeCount'] ?? '',
      honorDiv: json['honorDiv'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      profitRate: json['profitRate'] ?? '0',
      holdingDays: json['holdingDays'] ?? '0',
    );
  }

  @override
  String toString() {
    return '$tradeTime| $tradeFlag| $tradeCount';
  }
}

//화면구성
class TileSigString extends StatelessWidget {
  final SignalCount item;

  TileSigString(this.item);

  @override
  Widget build(BuildContext context) {
    String _timeStr = getTimeFormat(item.tradeTime);
    String honor;
    String endStr;
    String cnt = '';
    if (item.tradeCount != null) cnt = item.tradeCount;

    if (item.honorDiv.isNotEmpty) {
      if (item.honorDiv == 'WIN_RATE') {
        honor = '적중률 TOP 종목';
      } else if (item.honorDiv == 'PROFIT_10P') {
        honor = '수익난 매매 TOP 종목';
      } else if (item.honorDiv == 'SUM_PROFIT') {
        honor = '누적수익률 TOP 종목';
      } else if (item.honorDiv == 'MAX_PROFIT') {
        honor = '최대수익률 TOP 종목';
      } else {
        honor = '평균수익률 TOP 종목';
      }

      if (item.tradeFlag == 'B') {
        endStr = '에서 새로운 매수 신호 발생';
      } else {
        endStr = '에서 새로운 매도 신호 발생';
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _timeStr,
            style: TStyle.textMGrey,
          ),
          const SizedBox(
            width: 7,
          ),
          Text(
            honor,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(endStr),
        ],
      );
    } else {
      String preStr = '';
      Color stColor;
      if (item.tradeFlag == 'B') {
        preStr = '매수신호';
        stColor = RColor.sigBuy;
      } else {
        preStr = '매도신호';
        stColor = RColor.sigSell;
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _timeStr,
            style: TStyle.textMGrey,
          ),
          const SizedBox(
            width: 7,
          ),
          const Text('새로운 '),
          Text(
            preStr,
            style: TextStyle(color: stColor, fontWeight: FontWeight.bold),
          ),
          const Text('가 '),
          Text(
            '$cnt종목',
            style: TStyle.subTitle,
          ),
          const Text('에서 발생')
        ],
      );
    }
  }

  String getTimeFormat(String tm) {
    String rtStr = '';
    if (tm.length > 3) {
      rtStr = '${tm.substring(0, 2)}:${tm.substring(2, 4)}';
      return rtStr;
    }
    return '';
  }
}
