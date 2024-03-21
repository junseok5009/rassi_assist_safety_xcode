
/// 2021.01.22
/// Thinkpool SNS Login
class ThinkLoginSns {
  final int? resultCode;
  final String userId;
  final String nickName;
  final String encHpNo; // 암호화된 휴대폰 번호

  ThinkLoginSns({this.resultCode, this.userId = '', this.nickName = '', this.encHpNo = ''});

  factory ThinkLoginSns.fromJson(Map<String, dynamic> json) {
    return ThinkLoginSns(
      resultCode: json['resultCode'],
      userId: json['userid'],
      nickName: json['nick'],
      encHpNo: json['encHpNo'],
    );
  }
}
