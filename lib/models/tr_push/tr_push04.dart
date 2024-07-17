
/// 2021.01.08
/// 푸시 설정 조회
class TrPush04 {
  final String retCode;
  final String retMsg;
  final Push04 retData;

  TrPush04({this.retCode = '', this.retMsg = '', this.retData = defPush04});

  factory TrPush04.fromJson(Map<String, dynamic> json) {
    return TrPush04(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: Push04.fromJson(json['retData'])
    );
  }
}

const defPush04 = Push04();

class Push04 {
  final String rcvAssentYn;
  final String rcvAssentDttm;
  final String tradeSignalYn;
  final String rassiroNewsYn;
  final String snsConcernYn;
  final String stockNewsYn;
  final String buySignalYn;
  final String catchBriefYn;
  final String issueYn;
  final String catchSubsYn;
  final String catchBighandYn;
  final String catchThemeYn;
  final String catchTopYn;
  final String noticeYn;

  const Push04({
    this.rcvAssentYn = '', this.rcvAssentDttm = '',
    this.tradeSignalYn = '', this.rassiroNewsYn = '',
    this.snsConcernYn = '', this.stockNewsYn = '',
    this.buySignalYn = '', this.catchBriefYn = '',
    this.issueYn = '', this.catchSubsYn = '',
    this.catchBighandYn = '', this.catchThemeYn = '',
    this.catchTopYn = '', this.noticeYn = '',
  });

  factory Push04.fromJson(Map<String, dynamic> json) {
    return Push04(
      rcvAssentYn: json['rcvAssentYn'] ?? '',
      rcvAssentDttm: json['rcvAssentDttm'] ?? '',
      tradeSignalYn: json['tradeSignalYn'] ?? '',
      rassiroNewsYn: json['rassiroNewsYn'] ?? '',
      snsConcernYn: json['snsConcernYn'] ?? '',
      stockNewsYn: json['stockNewsYn'] ?? '',
      buySignalYn: json['buySignalYn'] ?? '',
      catchBriefYn: json['catchBriefYn'] ?? '',
      issueYn: json['issueYn'] ?? '',
      catchSubsYn: json['catchSubsYn'] ?? '',
      catchBighandYn: json['catchBighandYn'] ?? '',
      catchThemeYn: json['catchThemeYn'] ?? '',
      catchTopYn: json['catchTopYn'] ?? '',
      noticeYn: json['noticeYn'] ?? '',
    );
  }
}

