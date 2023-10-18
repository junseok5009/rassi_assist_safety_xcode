
/// 2020.12.21
/// 포켓 종목 등록
//
class TrPock05 {
  final String retCode;
  final String retMsg;

  TrPock05({this.retCode = '', this.retMsg = '',});

  factory TrPock05.fromJson(Map<String, dynamic> json) {
    return TrPock05(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
    );
  }
}



