import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/ui/main/base_page.dart';


/// 2020.10.29
/// 최대 수익률 TOP
class TrHonor04 {
  final String retCode;
  final String retMsg;
  final List<Honor04> retData;

  TrHonor04({this.retCode = '', this.retMsg = '', this.retData = const []});

  factory TrHonor04.fromJson(Map<String, dynamic> json) {
    // List<Honor04>? rtList;
    var list = json['retData'] as List;
    // list == null
    //     ? rtList = null
    //     : rtList = list.map((i) => Honor04.fromJson(i)).toList();

    return TrHonor04(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: list.map((i) => Honor04.fromJson(i)).toList(),
    );
  }
}

class Honor04 {
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String maxProfitRate;
  final String holdingDays;

  Honor04({
    this.stockCode = '',
    this.stockName = '',
    this.tradeFlag = '',
    this.maxProfitRate = '',
    this.holdingDays = '',
  });

  factory Honor04.fromJson(Map<String, dynamic> json) {
    return Honor04(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      tradeFlag: json['tradeFlag'],
      maxProfitRate: json['maxProfitRate'],
      holdingDays: json['holdingDays'],
    );
  }

  @override
  String toString() {
    return '$stockName|$stockCode|$tradeFlag|$maxProfitRate';
  }
}

//화면구성
class TileHonor04 extends StatelessWidget {
  final Honor04 item;

  TileHonor04(this.item);

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
          Navigator.pop(context);
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
              '+${item.maxProfitRate}%',
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
            '${item.holdingDays}일',
            style: TStyle.commonSTitle,
          ),
        ],
      ),
    );
  }
}
