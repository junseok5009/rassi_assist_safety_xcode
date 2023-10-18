import 'package:rassi_assist/models/stock_compare02.dart';
import 'package:rassi_assist/models/stock_group.dart';


/// [종목비교] TR_COMPARE02 _ 파싱 클래스
class TrCompare02 {
  final String retCode;
  final String retMsg;
  final Compare02 retData;

  TrCompare02({this.retCode = '', this.retMsg = '', this.retData = constCompare02});

  factory TrCompare02.fromJson(Map<String, dynamic> json) {
    return TrCompare02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? constCompare02 : Compare02.fromJson(json['retData']),
    );
  }
}

const constCompare02 = Compare02();

class Compare02 {
  final String selectDiv;
  final String stockCode;
  final String stockGrpCd;
  final String stockGrpNm;
  final List<StockGroup> listStockGroup;
  final List<StockCompare02> listStock;
  final String baseDate;    // 구분에 따라 있기도 없기도
  final String year;      // 기업규모, 성장성
  final String quarter;   // 기업규모, 성장성

  const Compare02({
    this.selectDiv = '',
    this.stockCode = '',
    this.stockGrpCd = '',
    this.stockGrpNm = '',
    this.listStockGroup = const [],
    this.listStock = const [],
    this.baseDate = '',
    this.year = '',
    this.quarter = '',
  });

  // Compare02.empty(){
  //   selectDiv = '';
  //   stockCode = '';
  //   stockGrpCd = '';
  //   stockGrpNm = '';
  //   listStockGroup = [];
  //   listStock = [];
  //   baseDate = '';
  //   year = '';
  //   quarter = '';
  // }

  factory Compare02.fromJson(Map<String, dynamic> json) {
    var list1 = json['list_StockGroup'] as List;
    List<StockGroup>? stockGroupList;
    if(list1 != null) stockGroupList = list1.map((i) => StockGroup.fromJson(i)).toList();

    var list2 = json['list_Stock'] as List;
    List<StockCompare02>? stockList;
    if(list2 != null) stockList = list2.map((i) => StockCompare02.fromJson(i)).toList();

    return Compare02(
      selectDiv: json['selectDiv'],
      stockCode: json['stockCode'],
      stockGrpCd: json['stockGrpCd'],
      stockGrpNm: json['stockGrpNm'],
      listStockGroup: list1.map((i) => StockGroup.fromJson(i)).toList(),
      listStock: list2.map((i) => StockCompare02.fromJson(i)).toList(),
      baseDate: json['baseDate'] ?? '',
      year: json['year'] ?? '',
      quarter: json['quarter'] ?? '',
    );
  }
}

