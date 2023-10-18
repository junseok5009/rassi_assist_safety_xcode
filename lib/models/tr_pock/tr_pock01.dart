
///포켓의 생성/변경/삭제
class TrPock01 {
  final String retCode;
  final String retMsg;

  TrPock01({this.retCode = '', this.retMsg='',});

  factory TrPock01.fromJson(Map<String, dynamic> json) {
    return TrPock01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
    );
  }
}

