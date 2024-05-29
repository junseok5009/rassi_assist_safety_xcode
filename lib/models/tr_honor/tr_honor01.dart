import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

/// 2020.10.29
/// 승률(적중률) TOP
class TrHonor01 {
  final String retCode;
  final String retMsg;
  final List<Honor01> retData;

  TrHonor01({this.retCode='', this.retMsg='', this.retData = const []});

  factory TrHonor01.fromJson(Map<String, dynamic> json) {
    var jsonList = json['retData'];
    return TrHonor01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: jsonList == null ? [] : (jsonList as List).map((i) => Honor01.fromJson(i)).toList(),
    );
  }
}

class Honor01 {
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String winningRate;
  final String tradeCount;

  Honor01({
    this.stockCode='',
    this.stockName='',
    this.tradeFlag='',
    this.winningRate='',
    this.tradeCount='',
  });

  factory Honor01.fromJson(Map<String, dynamic> json) {
    return Honor01(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      tradeFlag: json['tradeFlag'],
      winningRate: json['winningRate'],
      tradeCount: json['tradeCount'],
    );
  }

  @override
  String toString() {
    return '$stockName|$stockCode|$tradeFlag';
  }
}

//화면구성
class TileHonor01 extends StatelessWidget {
  final Honor01 item;

  const TileHonor01(this.item, {super.key});

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
        child: SizedBox(
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
          border: Border(
              right: BorderSide(
                  color: Colors.grey,
                  width: 1)
          ),
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
              '+${item.winningRate}%',
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
          )
        ],
      ),
    );
  }
}
