import 'package:rassi_assist/models/none_tr/stock/stock_bell.dart';


/// 2020.11.11
/// 종목 타임라인
class TrSHome02 {
  final String retCode;
  final String retMsg;
  final SHome02? retData;

  TrSHome02({
    this.retCode = '', this.retMsg = '', this.retData});

  factory TrSHome02.fromJson(Map<String, dynamic> json) {
    return TrSHome02(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null ? null : SHome02.fromJson(json['retData']),
    );
  }
}


class SHome02 {
  final InfoCnt infoCnt;
  final List<StockBell>? listData;

  SHome02({this.infoCnt = defInfoCnt, this.listData});

  factory SHome02.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stockbell'] as List?;
    List<StockBell> rtList;
    list == null ? rtList = [] : rtList = list.map((i) => StockBell.fromJson(i)).toList();

    return SHome02(
      infoCnt: InfoCnt.fromJson(json['stkBell']),
      listData: rtList,
    );
  }
}

const defInfoCnt = InfoCnt();

//스톡벨 발생 갯수
class InfoCnt {
  final String siseCount;
  final String investorCount;
  final String infoCount;

  const InfoCnt({
    this.siseCount = '',
    this.investorCount = '',
    this.infoCount = ''
  });

  factory InfoCnt.fromJson(Map<String, dynamic> json) {
    return InfoCnt(
      siseCount: json['siseCount'],
      investorCount: json['investorCount'],
      infoCount: json['infoCount'],
    );
  }

  @override
  String toString() {
    return '$siseCount|$investorCount|$infoCount';
  }
}
