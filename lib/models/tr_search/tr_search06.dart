

//Json
class TrSearch06 {
  final String retCode;
  final String retMsg;
  final Search06? retData;

  TrSearch06({this.retCode='', this.retMsg='', this.retData});

  factory TrSearch06.fromJson(Map<String, dynamic> json) {
    return TrSearch06(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null ? null : Search06.fromJson(json['retData'])
    );
  }
}


class Search06 {
  final String beginYear;
  final String investAmt;
  final String balanceAmt;
  final List<ChartData>? listChart;

  Search06({this.beginYear='', this.investAmt='', this.balanceAmt='', this.listChart});

  factory Search06.fromJson(Map<String, dynamic> json) {
    var list = json['list_SigChart'] as List;
    List<ChartData> listData = list.map((e) => ChartData.fromJson(e)).toList();
    return Search06(
        beginYear: json['beginYear'],
        investAmt: json['investAmt'],
        balanceAmt: json['balanceAmt'],
        listChart: listData
    );
  }
}


class ChartData {
  final String tradeDate;
  final String tradePrc;
  final String flag;

  ChartData({this.tradeDate='', this.tradePrc='', this.flag=''});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      tradeDate: json['td'],
      tradePrc: json['tp'],
      flag: json['tf']
    );
  }

  @override
  String toString() {
    return '$tradeDate|$tradePrc|$flag';
  }
}
