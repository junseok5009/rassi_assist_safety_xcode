class TrInvest24 {
  final String retCode;
  final String retMsg;
  final Invest24 retData;
  TrInvest24({this.retCode='', this.retMsg='', this.retData = defInvest24});
  factory TrInvest24.fromJson(Map<String, dynamic> json) {
    return TrInvest24(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null
          ? defInvest24
          : Invest24.fromJson(json['retData']),
    );
  }
}


const defInvest24 = Invest24();
class Invest24 {
  final List<Invest24Lockup> listInvest24Lockup;

  const Invest24({
    this.listInvest24Lockup = const [],
  });

  factory Invest24.fromJson(Map<String, dynamic> json) {
    var list = json['list_Lockup'] as List;
    List<Invest24Lockup> dataList = list == null
        ? []
        : list.map((i) => Invest24Lockup.fromJson(i)).toList();
    return Invest24(
      listInvest24Lockup: dataList,
    );
  }
}

class Invest24Lockup {
  final String stockCode;  // 날짜
  final String stockName; // 가격
  final String workDiv;  // 신규 수량
  final String lockupDate; // 상환 수량
  final String lockupVol; // 잔고 수량
  final String lockupRate; // 잔고 비율
  final String returnDate; // 신용 공여율
  final String returnVol; // 신용 잔고율
  final String returnRate; // 신용 잔고율
  final String reasonName;
  Invest24Lockup({
    this.stockCode='', this.stockName='', this.workDiv='',
    this.lockupDate='', this.lockupVol='', this.lockupRate='',
    this.returnDate='', this.returnVol='', this.returnRate='', this.reasonName=''
  });
  factory Invest24Lockup.fromJson(Map<String, dynamic> json) {
    return Invest24Lockup(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      workDiv: json['workDiv'] ?? '',
      lockupDate: json['lockupDate'] ?? '',
      lockupVol: json['lockupVol'] ?? '',
      lockupRate: json['lockupRate'] ?? '',
      returnDate: json['returnDate'] ?? '',
      returnVol: json['returnVol'] ?? '',
      returnRate: json['returnRate'] ?? '',
      reasonName: json['reasonName'] ?? '',
    );
  }
}
