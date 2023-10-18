
/// 2020.10.06
/// 관리자 추천 상품
class TrProm01 {
  final String retCode;
  final String retMsg;
  final List<Prom01>? retData;

  TrProm01({this.retCode = '', this.retMsg = '', this.retData});

  factory TrProm01.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<Prom01> rtList = list.map((i) => Prom01.fromJson(i)).toList();

    return TrProm01(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: rtList
    );
  }
}


class Prom01 {
  final String catchSn;
  final String issueTmTx;
  final String title;

  Prom01({this.catchSn = '', this.issueTmTx = '', this.title = '', });

  factory Prom01.fromJson(Map<String, dynamic> json) {
    return Prom01(
      catchSn: json['catchSn'],
      issueTmTx: json['issueTmTx'],
      title: json['title'],
    );
  }

  @override
  String toString() {
    return '$catchSn|$issueTmTx|$title';
  }
}

