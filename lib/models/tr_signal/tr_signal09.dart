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
      resData: json['retData'] != null ? Signal09.fromJson(json['retData']) : defSignal09,
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
  final String lottiePath;
  final List<String> listNotice;
  final List<SignalCount> listSignal;

  const Signal09({
    this.noticeCode = '',
    this.noticeText = '',
    this.processText = '',
    this.remainTime = '',
    this.updateDttm = '',
    this.buyCount = '',
    this.sellCount = '',
    this.lottiePath = 'assets/41561-machine-learning.json',
    this.listNotice = const [],
    this.listSignal = const [],
  });

  bool isEmpty() {
    if (noticeCode.isEmpty && noticeText.isEmpty && listNotice.isEmpty && listSignal.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  factory Signal09.fromJson(Map<String, dynamic> json) {
    String noticeCode = json['noticeCode'] ?? '';
    String lottiePath = 'assets/41561-machine-learning.json';

    if (noticeCode == 'TIME_BEFORE') {
      lottiePath = 'assets/9678-colorfull-loading.json';
    } else if (noticeCode == 'TIME_OPEN') {
      lottiePath = 'assets/8796-dashboard-motion.json';
    } else if (noticeCode == 'TIME_TERM') {
      lottiePath = 'assets/985-phonological.json';
    } else if (noticeCode == 'TIME_WAIT') {
      lottiePath = 'assets/9925-check-purple.json';
    } else {
      lottiePath = 'assets/41561-machine-learning.json';
    }

    return Signal09(
      noticeCode: noticeCode,
      noticeText: json['noticeText'] ?? '',
      processText: json['processText'] ?? '',
      remainTime: json['remainTime'] ?? '',
      updateDttm: json['updateDttm'] ?? '',
      buyCount: json['buyCount'] ?? '0',
      sellCount: json['sellCount'] ?? '0',
      lottiePath: lottiePath,
      listNotice: (json['listNotice'] == null) ? [] : (json['listNotice'] as List).map((i) => i.toString()).toList(),
      listSignal: (json['list_Signal'] == null)
          ? []
          : (json['list_Signal'] as List).map((i) => SignalCount.fromJson(i)).toList(),
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
