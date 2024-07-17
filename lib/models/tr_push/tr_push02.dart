

//Json
class TrPush02 {
  final String retCode;
  final String retMsg;
  final Push02? retData;

  TrPush02({this.retCode = '', this.retMsg = '', this.retData});

  factory TrPush02.fromJson(Map<String, dynamic> json) {
    return TrPush02(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: Push02.fromJson(json['retData'])
    );
  }
}


class Push02 {
  final String beginYear;
  final String investAmt;
  final String balanceAmt;
  final List<ChartData>? listChart;

  Push02({
    this.beginYear = '',
    this.investAmt = '',
    this.balanceAmt = '',
    this.listChart});

  factory Push02.fromJson(Map<String, dynamic> json) {
    var list = json['list_SigChart'] as List;
    List<ChartData> listData = list.map((e) => ChartData.fromJson(e)).toList();
    return Push02(
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

  ChartData({this.tradeDate = '', this.tradePrc = '', this.flag = ''});

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
