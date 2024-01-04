import 'package:flutter/material.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_data.dart';

/// [종목비교] _ 특정 종목이 가진 그룹과 그룹안에 해당하는 종목들 STOCK 클래스
class StockGroup {
  String stockGrpCd = '';
  String stockGrpNm = '';
  String groupfluctRate = '';
  String groupStockCnt = '';
  List<StockData> listStock = [];

  StockGroup({
    this.stockGrpCd = '',
    this.stockGrpNm = '',
    this.groupfluctRate = '',
    this.groupStockCnt = '',
    this.listStock = const [],
  });

  StockGroup.withoutListStock({
    this.stockGrpCd = '',
    this.stockGrpNm = '',
    this.groupfluctRate = '',
    this.groupStockCnt = '',
  }) : listStock = [];

  StockGroup.empty() {
    stockGrpCd = '';
    stockGrpNm = '';
    groupfluctRate = '';
    groupStockCnt = '';
    listStock = [];
  }

  factory StockGroup.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List<dynamic>?;
    List<StockData> rtList;
    if (list != null) {
      rtList = list.map((i) => StockData.fromJson(i)).toList();
    } else {
      rtList = [];
    }

    return StockGroup(
      stockGrpCd: json['stockGrpCd'] ?? '',
      stockGrpNm: json['stockGrpNm'] ?? '',
      groupfluctRate: json['groupfluctRate'] ?? '',
      groupStockCnt: json['groupStockCnt'] ?? '',
      listStock: rtList,
    );
  }

  @override
  String toString() {
    return '$stockGrpCd|$stockGrpNm|$groupfluctRate|$groupStockCnt|${listStock.toString()}}';
  }
}

//화면구성 - [홈_홈_이 시간 핫 종목비교 / 종목홈_종목비교_그룹없을때 핫그룹 리스트]
class TileStockGroup extends StatelessWidget {
  // final appGlobal = AppGlobal();
  final StockGroup item;

  TileStockGroup(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
      decoration: UIStyle.boxRoundLine6bgColor(
        Colors.white,
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              TStyle.getLimitString(item.stockGrpNm, 8),
              style: TStyle.title19T,
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: Column(
              children: [
                const Text(
                  '상승률 1위',
                  style: TStyle.content14,
                ),
                Row(
                  children: [
                    Text(
                      TStyle.getLimitString(item.listStock[0].stockName, 8),
                      style: TStyle.commonTitle15,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      child: Text(
                        TStyle.getPercentString(item.listStock[0].fluctuationRate),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: TStyle.getMinusPlusColor(item.listStock[0].fluctuationRate),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
