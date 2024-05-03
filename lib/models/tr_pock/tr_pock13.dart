import 'package:rassi_assist/models/stock_pkt_signal.dart';

///포켓 나만의 매도신호 조회
class TrPock13 {
  final String retCode;
  final String retMsg;
  final Pocket13? retData;

  TrPock13({
    this.retCode = '',
    this.retMsg = '',
    this.retData,
  });

  factory TrPock13.fromJson(Map<String, dynamic> json) {
    return TrPock13(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? null : Pocket13.fromJson(json['retData']),
    );
  }
}

class Pocket13 {
  String tradeTime = '';
  String tradeDate = '';
  String timeDivTxt = '';
  List<StockPktSignal> stkList = [];

  Pocket13({
    this.tradeTime = '',
    this.tradeDate = '',
    this.timeDivTxt = '',
    this.stkList = const [],
  });

  Pocket13.empty() {
    tradeTime = '';
    tradeDate = '';
    timeDivTxt = '';
    stkList = [];
  }

  bool get isEmpty {
    if(tradeTime.isEmpty && tradeDate.isEmpty && timeDivTxt.isEmpty && stkList.isEmpty){
      return true;
    }else{
      return false;
    }
  }

  factory Pocket13.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Stock'];
    List<StockPktSignal> listData = jsonList == null ? [] : (jsonList as List).map((e) => StockPktSignal.fromJson(e)).toList();
    return Pocket13(
      tradeTime: json['tradeTime'] ?? '',
      tradeDate: json['tradeDate'] ?? '',
      timeDivTxt: json['timeDivTxt'] ?? '',
      stkList: listData,
    );
  }

  @override
  String toString() {
    return '$tradeTime|$tradeDate|$timeDivTxt|list.length:${stkList.length}';
  }
}
