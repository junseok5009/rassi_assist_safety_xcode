import 'package:rassi_assist/models/none_tr/stock/stock_compare02.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_group.dart';

/// [종목비교] TR_COMPARE02 _ 파싱 클래스
class TrCompare02 {
  final String retCode;
  final String retMsg;
  final Compare02 retData;

  TrCompare02({
    this.retCode = '',
    this.retMsg = '',
    this.retData = constCompare02,
  });

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
  final String baseDate; // 구분에 따라 있기도 없기도
  final String year; // 기업규모, 성장성
  final String quarter; // 기업규모, 성장성

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
    var jsonList1 = json['list_StockGroup'];
    var jsonList2 = json['list_Stock'];
    return Compare02(
      selectDiv: json['selectDiv'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockGrpCd: json['stockGrpCd'] ?? '',
      stockGrpNm: json['stockGrpNm'] ?? '',
      listStockGroup: jsonList1 == null ? [] : (jsonList1 as List).map((i) => StockGroup.fromJson(i)).toList(),
      listStock: jsonList2 == null ? [] : (jsonList2 as List).map((i) => StockCompare02.fromJson(i)).toList(),
      baseDate: json['baseDate'] ?? '',
      year: json['year'] ?? '',
      quarter: json['quarter'] ?? '',
    );
  }
}
