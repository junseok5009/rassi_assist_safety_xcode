/// 2020.09.07
/// 앱 버전 정보 확인
///
class TrApp01 {
  final String retCode;
  final String retMsg;
  final App01? resData;

  TrApp01({
    this.retCode = '',
    this.retMsg = '',
    this.resData,
  });

  factory TrApp01.fromJson(Map<String, dynamic> json) {
    return TrApp01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      resData: json['retData'] == null ? null : App01.fromJson(json['retData']),
    );
  }
}


class App01 {
  final String versionMin;
  final String versionLast;
  final String lastUpdated;
  final String redirectUrl;

  App01({
    this.versionMin = '',
    this.versionLast = '',
    this.lastUpdated = '',
    this.redirectUrl = '',
  });

  factory App01.fromJson(Map<String, dynamic> json) {
    return App01(
      versionMin: json['versionMin'] ?? '',
      versionLast: json['versionLast'] ?? '',
      lastUpdated: json['lastUpdated'] ?? '',
      redirectUrl: json['redirectUrl'] ?? '',
    );
  }

  @override
  String toString() {
    return '$versionMin|$versionLast|$lastUpdated';
  }
}


class SignalData {
  final String tradeTime;
  final String tradeFlag;
  final String tradeCount;

  SignalData({
    this.tradeTime = '',
    this.tradeFlag = '',
    this.tradeCount = '',
  });

  factory SignalData.fromJson(Map<String, dynamic> json) {
    return SignalData(tradeTime: json['tradeTime'], tradeFlag: json['tradeFlag'], tradeCount: json['tradeCount']);
  }

  @override
  String toString() {
    return '$tradeTime|$tradeFlag|$tradeCount';
  }
}
