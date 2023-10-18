
/// 2020.09.03
/// 디바이스 정보 등록
class TrUser03 {
  final String retCode;
  final String retMsg;

  TrUser03({this.retCode = '', this.retMsg = ''});

  factory TrUser03.fromJson(Map<String, dynamic> json) {
    return TrUser03(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
    );
  }
}
