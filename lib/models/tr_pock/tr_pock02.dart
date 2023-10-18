
///
class TrPock02 {
  final String retCode;
  final String retMsg;
  final Pock02? retData;

  TrPock02({this.retCode='', this.retMsg='', this.retData});

  factory TrPock02.fromJson(Map<String, dynamic> json) {
    return TrPock02(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: Pock02.fromJson(json['retData'])
    );
  }
}

class Pock02 {
  final String stockCode;
  final String stockName;
  final String isMyStock;     //포켓 등록 여부 Y/N
  final String pocketSn;

  Pock02({this.stockCode='', this.stockName='', this.isMyStock='', this.pocketSn='',});

  factory Pock02.fromJson(Map<String, dynamic> json) {
    return Pock02(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      isMyStock: json['isMyStock'],
      pocketSn: json['pocketSn'],
    );
  }
}

