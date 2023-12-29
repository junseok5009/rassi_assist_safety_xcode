/// 2021.02.16
/// QNA 등록
class TrQna01 {
  final String retCode;
  final String retMsg;

  TrQna01({
    this.retCode = '',
    this.retMsg = '',
  });

  factory TrQna01.fromJson(Map<String, dynamic> json) {
    return TrQna01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
    );
  }
}
