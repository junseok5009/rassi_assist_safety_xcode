

class TrSignal023 {
  final String retCode;
  final String retMsg;
  final List<SignalObj>? listData;

  TrSignal023({this.retCode = '', this.retMsg = '', this.listData});

  factory TrSignal023.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    print(list.runtimeType);
    List<SignalObj> rtList = list.map((i) => SignalObj.fromJson(i)).toList();

    return TrSignal023(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        listData: rtList
    );
  }
}


class SignalObj {
  final String title;
  final String stockCode;
  final String stockName;
  final String tradeDate;
  final String tradeTime;

  SignalObj({this.title = '', this.stockCode = '', this.stockName = '', this.tradeDate = '', this.tradeTime = ''});

  factory SignalObj.fromJson(Map<String, dynamic> json) {
    return SignalObj(
        title: json['title'],
        stockCode: json['stockCode'],
        stockName: json['stockName'],
        tradeDate: json['tradeDate'],
        tradeTime: json['tradeTime']
    );
  }
}
