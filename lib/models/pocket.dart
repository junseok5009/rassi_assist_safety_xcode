import 'package:rassi_assist/models/none_tr/stock/stock.dart';

/// MY 포켓 데이터
/// 23.11.23 HJS
class Pocket {
  String pktSn = '';
  String pktName = '';
  bool isDelete = false;
  final List<Stock> stkList = [];

  Pocket(String pocketSn, String pocketName,) {
    pktSn = pocketSn;
    pktName = pocketName;
  }

  Pocket.withStockList(String pocketSn, String pocketName, List<Stock> stockList) {
    pktSn = pocketSn;
    pktName = pocketName;
    stkList.addAll(stockList);
  }

  Pocket.change(String pocketSn, String pocketName, bool isDelete){
    pktSn = pocketSn;
    pktName = pocketName;
    isDelete = isDelete;
  }

  @override
  String toString() {
    return '$pktName|$pktSn';
  }
}


