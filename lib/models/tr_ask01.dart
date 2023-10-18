
/// 2020.10.06
/// 매매비서 문의 종목 저장
// (대략 파싱 완료)
class TrAsk01 {
  final String retCode;
  final String retMsg;

  TrAsk01({this.retCode = '', this.retMsg = '', });

  factory TrAsk01.fromJson(Map<String, dynamic> json) {
    return TrAsk01(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
    );
  }
}
