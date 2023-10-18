
/// 2020.09.09
/// 종목 소셜지수 조회
class TrSns01 {
  final String retCode;
  final String retMsg;
  final String retData;

  TrSns01({this.retCode = '', this.retMsg = '', this.retData = ''});

  factory TrSns01.fromJson(Map<String, dynamic> json) {
    return TrSns01(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null ? null : json['retData']['concernGrade'],
    );
  }
}


