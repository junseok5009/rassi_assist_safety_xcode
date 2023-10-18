import 'package:rassi_assist/models/tr_pock/tr_pock08.dart';

/// MY 포켓 데이터   TODO 미완성
class PocketData {
  String pktSn = '';
  String pktName = '';
  String viewSeq = '';
  String waitCount = '';
  String holdCount = '';
  final List<PtStock> _stkList = [];

  void setPocketData(String pocketSn, String pocketName, String seq, String waitCnt, String holdCnt) {
    pktSn = pocketSn;
    pktName = pocketName;
    viewSeq = seq;
    waitCount = waitCnt;
    holdCount = holdCnt;

    // notifyListeners();
  }

  void addStock(PtStock stock) {
    _stkList.add(stock);
  }

  void removeAll() {
    _stkList.clear();
  }

  @override
  String toString() {
    return '$pktName|$pktSn|$viewSeq';
  }
}


