// 회원가입할때 아직 회원가입 전에 필요한 유저 정보
class UserJoinInfo {
  String userId = '';   // 휴대폰:암호화 휴대폰 번호 / 카카오,네이버,구글,애플 : 인증 키 / 라씨 : id
  String email = '';    //이메일 또는 비밀번호(라씨)
  String name = '';     //이름 또는 전화번호(라씨)
  String phone = '';
  String pgType = '';

  UserJoinInfo({
    this.userId = '',
    this.email = '',
    this.name = '',
    this.phone = '',
    this.pgType = '',
  });

  @override
  String toString() {
    return 'userId:$userId/email:$email/name:$name/phone:$phone/pgType:$pgType';
  }
}
