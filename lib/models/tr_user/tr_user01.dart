/// 2021.01.05
//회원 계정 생성/탈퇴
class TrUser01 {
  final String retCode;
  final String retMsg;

  TrUser01({
    this.retCode = '',
    this.retMsg = '',
  });

  factory TrUser01.fromJson(Map<String, dynamic> json) {
    return TrUser01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
    );
  }
}
