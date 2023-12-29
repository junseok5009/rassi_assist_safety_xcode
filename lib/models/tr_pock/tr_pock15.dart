import 'package:rassi_assist/models/none_tr/stock/stock_pocket_info.dart';
import 'package:rassi_assist/models/pocket.dart';

/// 2020.11.05
/// 포켓 리스트
class TrPock15 {
  final String retCode;
  final String retMsg;
  final List<Pocket> listData;

  TrPock15({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrPock15.fromJson(Map<String, dynamic> json) {
    return TrPock15(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: json['retData'] == null ? [] : (json['retData'] as List).map((i) => Pock15.fromJson(i)).toList(),
    );
  }
}

class Pock15 extends Pocket {
  final String pocketSn;
  final String pocketName;
  final List<StockPocketInfo> stockList;

  Pock15({
    this.pocketSn = '',
    this.pocketName = '',
    this.stockList = const [],
  }) : super.withStockList(pocketSn, pocketName, stockList);

  factory Pock15.fromJson(Map<String, dynamic> json) {
    return Pock15(
      pocketSn: json['pocketSn'],
      pocketName: json['pocketName'],
      stockList: json['stockList'] == null ? [] : (json['stockList'] as List).map((i) => StockPocketInfo.fromJson(i)).toList(),
    );
  }

  @override
  String toString() {
    return '$pocketSn | $pocketName';
  }
}
