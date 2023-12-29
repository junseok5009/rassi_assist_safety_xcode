import 'package:rassi_assist/models/none_tr/stock/stock.dart';

/// 2020.11.12
/// 포켓 종목 신호 상태
class TrPock08 {
  final String retCode;
  final String retMsg;
  final Pock08 retData;

  TrPock08({this.retCode='', this.retMsg='', this.retData = defPock08});

  factory TrPock08.fromJson(Map<String, dynamic> json) {
    return TrPock08(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: Pock08.fromJson(json['retData']),
    );
  }
}

const defPock08 = Pock08();

class Pock08 {
  final String tradeTime;
  final String tradeDate;
  final String timeDivTxt;
  final String beforeChart; // 09시 ~ 09시 20분 Y
  final String beforeOpening; // 08시 ~ 09시 Y
  final PocketBrief? pocketBrief;
  final List<PocketSignalStock> stkList;

  const Pock08({
    this.tradeTime='',
    this.tradeDate='',
    this.timeDivTxt='',
    this.beforeChart='',
    this.beforeOpening='',
    this.pocketBrief,
    this.stkList = const [],
  });

  factory Pock08.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    List<PocketSignalStock> rtList;
    list == null
        ? rtList = []
        : rtList = list.map((i) => PocketSignalStock.fromJson(i)).toList();
    return Pock08(
      tradeTime: json['tradeTime'] ?? '',
      tradeDate: json['tradeDate'] ?? '',
      timeDivTxt: json['timeDivTxt'] ?? '',
      beforeChart: json['beforeChart'] ?? '',
      beforeOpening: json['beforeOpening'] ?? '',
      pocketBrief: PocketBrief.fromJson(json['struct_Pocket']),
      stkList: rtList,
    );
  }
}

class PocketBrief {
  final String pocketSn;
  final String pocketName;
  final String viewSeq;
  final String waitCount;
  final String holdCount;

  PocketBrief({
    this.pocketSn='',
    this.pocketName='',
    this.viewSeq='',
    this.waitCount='',
    this.holdCount='',
  });

  factory PocketBrief.fromJson(Map<String, dynamic> json) {
    return PocketBrief(
      pocketSn: json['pocketSn'],
      pocketName: json['pocketName'],
      viewSeq: json['viewSeq'],
      waitCount: json['waitCount'],
      holdCount: json['holdCount'],
    );
  }

  @override
  String toString() {
    return '$pocketName|$pocketSn|$viewSeq|$waitCount|$holdCount';
  }
}

class PocketSignalStock extends Stock {
  final String viewSeq;
  @override
  final String stockCode;
  @override
  final String stockName;
  final String tradeFlag;
  final String myTradeFlag;
  final String tradePrice;
  final String tradeDttm;
  final String currentPrice;
  final String profitRate;
  String fluctuationAmt;
  String fluctuationRate;
  final String elapsedDays;
  final String sellPrice;
  final String termOfTrade;
  final String listingYn; // 신규 상장 여부
  String signalYn; // 3종목 알림 사용자 - 나만의 매도 신호 등록 YN
  final String tradingHaltYn; // Y : 거래정지 / T : 상장폐지

  PocketSignalStock({
    this.viewSeq='',
    this.stockCode='',
    this.stockName='',
    this.tradeFlag='',
    this.myTradeFlag='',
    this.tradePrice='',
    this.tradeDttm='',
    this.currentPrice='',
    this.profitRate='',
    this.fluctuationAmt='',
    this.fluctuationRate='',
    this.elapsedDays='',
    this.sellPrice='',
    this.termOfTrade='',
    this.listingYn='',
    this.signalYn='',
    this.tradingHaltYn='',
  });

  factory PocketSignalStock.fromJson(Map<String, dynamic> json) {
    return PocketSignalStock(
      viewSeq: json['viewSeq'],
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      tradeFlag: json['tradeFlag'] ?? '',
      myTradeFlag: json['myTradeFlag'] ?? '',
      tradePrice: json['tradePrice'] ?? '',
      tradeDttm: json['tradeDttm'] ?? '',
      currentPrice: json['currentPrice'] ?? '',
      profitRate: json['profitRate'] ?? '',
      fluctuationAmt: json['fluctuationAmt'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
      elapsedDays: json['elapsedDays'] ?? '',
      sellPrice: json['sellPrice'] ?? '',
      termOfTrade: json['termOfTrade'] ?? '',
      listingYn: json['listingYn'] ?? 'N',
      signalYn: json['signalYn'] ?? 'N',
      tradingHaltYn: json['tradingHaltYn'] ?? 'N',
    );
  }
}
