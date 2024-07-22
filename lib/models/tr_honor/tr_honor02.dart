import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

/// 2020.10.29
/// 수익 발생(10% 이상) 횟수 TOP > 수익난 매매 TOP 50
class TrHonor02 {
  final String retCode;
  final String retMsg;
  final List<Honor02> retData;

  TrHonor02({this.retCode = '', this.retMsg = '', this.retData = const []});

  factory TrHonor02.fromJson(Map<String, dynamic> json) {
    var jsonList = json['retData'];
    return TrHonor02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: jsonList == null ? [] : (jsonList as List).map((i) => Honor02.fromJson(i)).toList(),
    );
  }
}

class Honor02 {
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String tradeCount;
  final String holdingDays;

  Honor02({
    this.stockCode = '',
    this.stockName = '',
    this.tradeFlag = '',
    this.tradeCount = '',
    this.holdingDays = '',
  });

  factory Honor02.fromJson(Map<String, dynamic> json) {
    return Honor02(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      tradeFlag: json['tradeFlag'],
      tradeCount: json['tradeCount'],
      holdingDays: json['holdingDays'],
    );
  }

  @override
  String toString() {
    return '$stockName|$stockCode|$tradeFlag|$holdingDays';
  }
}

//화면구성
class TileHonor02 extends StatelessWidget {
  final Honor02 item;

  TileHonor02(this.item);

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
            Const.STK_INDEX_HOME,
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
              '${item.tradeCount}번',
              style: TStyle.commonSTitle,
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
