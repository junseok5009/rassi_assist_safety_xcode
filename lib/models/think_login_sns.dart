
/// 2021.01.22
/// Thinkpool SNS Login
class ThinkLoginSns {
  final int? resultCode;
  final String userId;
  final String nickName;

  ThinkLoginSns({this.resultCode, this.userId = '', this.nickName = '', });

  factory ThinkLoginSns.fromJson(Map<String, dynamic> json) {
    return ThinkLoginSns(
      resultCode: json['resultCode'],
      userId: json['userid'],
      nickName: json['nick'],
    );
  }
}
