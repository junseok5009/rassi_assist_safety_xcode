
/// 2021.01.05
/// 인앱 결제 검증
class TrInApp01 {
  final String retCode;
  final String retMsg;

  TrInApp01({this.retCode = '', this.retMsg = '',});

  factory TrInApp01.fromJson(Map<String, dynamic> json) {
    return TrInApp01(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
    );
  }
}


