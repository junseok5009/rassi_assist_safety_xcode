/// 2020.09.07
/// 앱 버전 정보 확인

class TrApp03 {
  final String retCode;
  final String retMsg;
  final App03? retData;

  TrApp03({this.retCode = '', this.retMsg = '', this.retData});

  factory TrApp03.fromJson(Map<String, dynamic> json) {
    return TrApp03(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: App03.fromJson(json['retData']),
    );
  }
}

class App03 {
  final List<App03PaymentGuide> listPaymentGuide;
  final String stdPrice;

  App03({
    this.listPaymentGuide = const [],
    this.stdPrice = '',
  });

  factory App03.fromJson(Map<String, dynamic> json) {
    return App03(
      listPaymentGuide: json['listPaymentGuide'] == null
          ? []
          : (json['listPaymentGuide'] as List).map((i) => App03PaymentGuide.fromJson(i)).toList(),
      stdPrice: json['stdPrice'] ?? '',
    );
  }
}

class App03PaymentGuide {
  final String guideSeq;
  final String guideText;

  App03PaymentGuide({
    this.guideSeq = '',
    this.guideText = '',
  });

  factory App03PaymentGuide.fromJson(Map<String, dynamic> json) {
    return App03PaymentGuide(
      guideSeq: json['guideSeq'] ?? '',
      guideText: json['guideText'] ?? '',
    );
  }

  @override
  String toString() {
    return '$guideSeq|$guideText';
  }
}
