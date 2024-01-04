/// 2020.09.03
/// 회원 정보 조회
class TrUser02 {
  final String retCode;
  final String retMsg;
  final User02 retData;

  TrUser02({
    this.retCode = '',
    this.retMsg = '',
    this.retData = defUser02,
  });

  factory TrUser02.fromJson(Map<String, dynamic> json) {
    User02 rtData;
    json['retData'] == null ? rtData = defUser02 : rtData = User02.fromJson(json['retData']);
    return TrUser02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: rtData,
    );
  }
}

const defUser02 = User02();

class User02 {
  final String userId;
  final String userStatus; //회원상태 N:정상, C:해지
  final String userName;
  final String userNick;
  final String userEmail;
  final String userHp;
  final String pushValid; //Y값이 아니면 푸시 토큰 재등록

  const User02({
    this.userId = '',
    this.userStatus = '',
    this.userName = '',
    this.userNick = '',
    this.userEmail = '',
    this.userHp = '',
    this.pushValid = '',
  });

  factory User02.fromJson(Map<String, dynamic> json) {
    return User02(
      userId: json['userId'] = '',
      userStatus: json['userStatus'] = '',
      userName: json['userName'] = '',
      userNick: json['userNick'] = '',
      userEmail: json['userEmail'] = '',
      userHp: json['userHp'] = '',
      pushValid: json['pushTokenValid'] = '',
    );
  }

  @override
  String toString() {
    return '$userId|$userStatus|$userName|$userHp|$pushValid';
  }
}
