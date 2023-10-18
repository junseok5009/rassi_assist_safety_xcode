
/// 2021.01.05
//카카오 푸시 토큰 등록
class TrPush01 {
  final String retCode;
  final String retMsg;

  TrPush01({this.retCode = '', this.retMsg = '',});

  factory TrPush01.fromJson(Map<String, dynamic> json) {
    return TrPush01(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
    );
  }
}
