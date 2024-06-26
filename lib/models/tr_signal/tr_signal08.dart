import 'package:rassi_assist/models/none_tr/chart_data.dart';


///
class TrSignal08 {
  final String retCode;
  final String retMsg;
  final Signal08 retData;

  TrSignal08({this.retCode = '', this.retMsg = '', this.retData = const Signal08()});

  factory TrSignal08.fromJson(Map<String, dynamic> json) {
    return TrSignal08(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null ? const Signal08() : Signal08.fromJson(json['retData'])
    );
  }
}

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
    var jsonList = json['list_SigChart'];
    return Signal08(
        beginYear: json['beginYear'],
        investAmt: json['investAmt'],
        balanceAmt: json['balanceAmt'],
        listChart: jsonList == null ? [] : (jsonList as List).map((e) => ChartData.fromJson(e)).toList()
    );
  }
}
