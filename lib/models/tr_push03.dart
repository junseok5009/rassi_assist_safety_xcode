

//Json
class TrPush03 {
  final String retCode;
  final String retMsg;
  final Push03? retData;

  TrPush03({this.retCode = '', this.retMsg = '', this.retData});

  factory TrPush03.fromJson(Map<String, dynamic> json) {
    return TrPush03(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null ? null : Push03.fromJson(json['retData'])
    );
  }
}


class Push03 {
  final String beginYear;
  final String investAmt;
  final String balanceAmt;
  final List<ChartData>? listChart;

  Push03({this.beginYear = '', this.investAmt = '', this.balanceAmt = '', this.listChart});

  factory Push03.fromJson(Map<String, dynamic> json) {
    var list = json['list_SigChart'] as List;
    List<ChartData> listData = list.map((e) => ChartData.fromJson(e)).toList();
    return Push03(
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
