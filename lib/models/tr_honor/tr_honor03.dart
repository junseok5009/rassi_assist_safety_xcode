import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/ui/main/base_page.dart';


/// 2020.10.29
/// 누적 수익률 TOP
class TrHonor03 {
  final String retCode;
  final String retMsg;
  final List<Honor03> retData;

  TrHonor03({this.retCode = '', this.retMsg = '', this.retData = const []});

  factory TrHonor03.fromJson(Map<String, dynamic> json) {
    var jsonList = json['retData'];
    return TrHonor03(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: jsonList == null ? [] : (jsonList as List).map((i) => Honor03.fromJson(i)).toList(),
    );
  }
}

class Honor03 {
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String sumProfitRate;
  final String tradeCount;

  Honor03({
    this.stockCode = '',
    this.stockName = '',
    this.tradeFlag = '',
    this.sumProfitRate = '',
    this.tradeCount = '',
  });

  factory Honor03.fromJson(Map<String, dynamic> json) {
    return Honor03(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      tradeFlag: json['tradeFlag'],
      sumProfitRate: json['sumProfitRate'],
      tradeCount: json['tradeCount'],
    );
  }

  @override
  String toString() {
    return '$stockName|$stockCode|$tradeFlag|$sumProfitRate';
  }
}

//화면구성
class TileHonor03 extends StatelessWidget {
  final Honor03 item;

  TileHonor03(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
      ),
      decoration: const BoxDecoration(
        color: RColor.bgWeakGrey,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _setListItem1(),
              _setListItem2(),
              _setListItem3(),
            ],
          ),
        ),
        onTap: () {
          basePageState.goStockHomePage(
            item.stockCode,
            item.stockName,
            Const.STK_INDEX_SIGNAL,
          );
        },
      ),
    );
  }

  Widget _setListItem1() {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.stockName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TStyle.commonSTitle,
            ),
            Text(
              item.stockCode,
              style: TStyle.textSGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _setListItem2() {
    return Expanded(
      flex: 2,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '+${item.sumProfitRate}%',
              style: TStyle.textMBuy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _setListItem3() {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${item.tradeCount}번',
            style: TStyle.commonSTitle,
          ),
        ],
      ),
    );
  }
}
