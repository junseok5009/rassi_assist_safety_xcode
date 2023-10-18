
/// 2023.07.31 - JS
// TR 기본 형태
class TrBasic {
  final String retCode;
  final String retMsg;

  TrBasic({this.retCode = '', this.retMsg = '',});

  factory TrBasic.fromJson(Map<String, dynamic> json) {
    return TrBasic(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
    );
  }
}
