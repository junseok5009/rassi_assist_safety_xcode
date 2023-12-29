/// 2023.12.15
/// 나의 포켓 종목의 현황 개수 조회
class TrPock11 {
  final String retCode;
  final String retMsg;
  final Pock11? retData;

  TrPock11({this.retCode = '', this.retMsg = '', this.retData});

  factory TrPock11.fromJson(Map<String, dynamic> json) {
    return TrPock11(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? null : Pock11.fromJson(json['retData']),
    );
  }
}

class Pock11 {
  final String beforeOpening;
  final String upCnt;
  final String downCnt;
  final String sigBuyCnt;
  final String sigSellCnt;
  final String issueCnt;
  final String supplyCnt;
  final String chartCnt;

  Pock11({
    this.beforeOpening = '',
    this.upCnt = '0',
    this.downCnt = '0',
    this.sigBuyCnt = '0',
    this.sigSellCnt = '0',
    this.issueCnt = '0',
    this.supplyCnt = '0',
    this.chartCnt = '0',
  });

  factory Pock11.fromJson(Map<String, dynamic> json) {
    return Pock11(
      beforeOpening: json['beforeOpening'] ?? '',
      upCnt: json['upCnt'] ?? '0',
      downCnt: json['downCnt'] ?? '0',
      sigBuyCnt: json['sigBuyCnt'] ?? '0',
      sigSellCnt: json['sigSellCnt'] ?? '0',
      issueCnt: json['issueCnt'] ?? '0',
      supplyCnt: json['supplyCnt'] ?? '0',
      chartCnt: json['chartCnt'] ?? '0',
    );
  }
}
