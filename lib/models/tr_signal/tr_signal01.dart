import 'package:flutter/material.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';

///매매신호 상태
class TrSignal01 {
  final String retCode;
  final String retMsg;
  final Signal01 retData;

  TrSignal01({this.retCode = '', this.retMsg = '', this.retData = defSignal01});

  factory TrSignal01.fromJson(Map<String, dynamic> json) {
    Signal01? rtData;
    json['retData'] == null
        ? rtData = defSignal01
        : rtData = Signal01.fromJson(json['retData']);
    return TrSignal01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: rtData,
    );
  }
}

const defSignal01 = Signal01();
class Signal01 {
  final String stkViewable;
  final SignalData signalData;
  final List<Participant> listTrade;

  const Signal01({
    this.stkViewable = '',
    this.signalData = defSignalData,
    this.listTrade = const []
  });

  factory Signal01.fromJson(Map<String, dynamic> json) {
    SignalData signalData = SignalData.fromJson(json['struct_Signal']);
    var listT = json['list_Trade'] as List?;
    List<Participant> rtList = listT != null ? listT.map((e) => Participant.fromJson(e)).toList() : [];
    return Signal01(
      stkViewable: json['stockViewable'],
      signalData: signalData,
      listTrade: rtList,
    );
  }
}

const defSignalData = SignalData();
class SignalData {
  final String dspYn;
  final String isMyStock;
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String tradeDate;
  final String tradeTime;
  final String tradePrc;
  final String profitRate;
  final String elapsedDays;
  final String termOfTrade;
  final String sigStatDesc;
  final String signalAdText;
  final String isForbidden; // 매매금지 종목 여부
  final String forbiddenDesc; // 매매금지 종목 내용
  final String signalTargetYn; // 신호 노출 제한 종목 yn
  final String signalIssueYn; // 신호 발생함, 아직 신호 발생 전

  const SignalData({
    this.dspYn = '',
    this.isMyStock = '',
    this.stockCode = '',
    this.stockName = '',
    this.tradeFlag = '',
    this.tradeDate = '',
    this.tradeTime = '',
    this.tradePrc = '',
    this.profitRate = '',
    this.elapsedDays = '',
    this.termOfTrade = '',
    this.sigStatDesc = '',
    this.signalAdText = '',
    this.isForbidden = '',
    this.forbiddenDesc = '',
    this.signalTargetYn = '',
    this.signalIssueYn = ''
  });

  factory SignalData.fromJson(Map<String, dynamic> json) {
    return SignalData(
      dspYn: json['displayYn'] ?? '',
      isMyStock: json['isMyStock'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      tradeFlag: json['tradeFlag'] ?? '',
      tradeDate: json['tradeDate'] ?? '',
      tradeTime: json['tradeTime'] ?? '',
      tradePrc: json['tradePrice'] ?? '',
      profitRate: json['profitRate'] ?? '',
      elapsedDays: json['elapsedDays'] ?? '',
      termOfTrade: json['termOfTrade'] ?? '',
      sigStatDesc: json['sigStatDesc'] ?? '',
      signalAdText: json['signalAdText'] ?? '',
      isForbidden:  json['isForbidden'] ?? '',
      forbiddenDesc: json['forbiddenDesc'] ?? '',
      signalTargetYn: json['signalTargetYn'] ?? '',
      signalIssueYn: json['signalIssueYn'] ?? '',
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$tradeFlag|$tradeDate';
  }
}

// 시장 참여자 (외국인/기관/개인...)
class Participant {
  final String stockCode;
  final String tradeDate;
  final String trader;
  final String tradeVol;
  final String tradeDays;

  Participant({
    this.stockCode = '',
    this.tradeDate = '',
    this.trader = '',
    this.tradeVol = '',
    this.tradeDays = '',
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      stockCode: json['stockCode'] ?? '',
      tradeDate: json['tradeDate'] ?? '',
      trader: json['trader'] ?? '',
      tradeVol: json['tradeVol'] ?? '',
      tradeDays: json['tradeDays'] ?? '',
    );
  }
}


class TileSignal01Forbidden extends StatelessWidget {
  //const TileSignal01Forbidden({Key? key}) : super(key: key);
  final String _stkName;
  final String _desc;
  const TileSignal01Forbidden(this._stkName, this._desc, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        CommonPopup().showDialogForbidden(context, _stkName, _desc);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: const Text(
                '!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            Flexible(
              child: Text(
                _stkName,
                style: const TextStyle(color: Colors.red),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Text(
              '의 매수신호가 발생되지 않습니다.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(
              width: 8,
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: const Text(
                '?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
