import 'package:rassi_assist/models/chart_data.dart';


///
class TrSignal08 {
  final String retCode;
  final String retMsg;
  final Signal08 retData;

  TrSignal08({this.retCode = '', this.retMsg = '', this.retData = defSignal08});

  factory TrSignal08.fromJson(Map<String, dynamic> json) {
    return TrSignal08(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null ? defSignal08 : Signal08.fromJson(json['retData'])
    );
  }
}

const defSignal08 = Signal08();

class Signal08 {
  final String beginYear;
  final String investAmt;
  final String balanceAmt;
  final List<ChartData> listChart;

  const Signal08({
    this.beginYear = '',
    this.investAmt = '',
    this.balanceAmt = '',
    this.listChart= const [],
  });

  factory Signal08.fromJson(Map<String, dynamic> json) {
    var list = json['list_SigChart'] as List;
    List<ChartData> listData = list.map((e) => ChartData.fromJson(e)).toList();
    return Signal08(
        beginYear: json['beginYear'],
        investAmt: json['investAmt'],
        balanceAmt: json['balanceAmt'],
        listChart: listData
    );
  }
}
