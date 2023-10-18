import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/main/base_page.dart';


/// 2020.10.19
/// 평균 수익률 높은 종목 - 관망상태 종목
class TrFind05 {
  final String retCode;
  final String retMsg;
  final List<Find05> listData;

  TrFind05({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrFind05.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<Find05> rtList = list.map((i) => Find05.fromJson(i)).toList();

    return TrFind05(
        retCode: json['retCode'], retMsg: json['retMsg'], listData: rtList);
  }
}

class Find05 {
  final String stockCode;
  final String stockName;
  final String avgProfitRate;
  final String waitingDays;

  Find05({
    this.stockCode = '',
    this.stockName = '',
    this.avgProfitRate = '',
    this.waitingDays = ''
  });

  factory Find05.fromJson(Map<String, dynamic> json) {
    return Find05(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      avgProfitRate: json['avgProfitRate'],
      waitingDays: json['waitingDays'],
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$avgProfitRate|$waitingDays';
  }
}

//화면구성
class TileFind05 extends StatelessWidget {
  final Find05 item;

  const TileFind05(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10,),
      decoration: UIStyle.boxRoundLine6(),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: 135,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    TStyle.getLimitString(item.stockName, 8),
                    style: TStyle.subTitle,
                  ),
                  // const SizedBox(height: 5,),
                  Text(
                    item.stockCode,
                    style: TStyle.textSGrey,
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    '평균수익률',
                    style: TStyle.textSBuy,
                  ),
                  // const SizedBox(height: 4,),
                  Text(
                    '+${item.avgProfitRate}%',
                    style: TStyle.textBBuy,
                  ),
                ],
              ),
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
}

//상세리스트 (Vertical list)
class TileFindV05 extends StatelessWidget {
  final Find05 item;

  TileFindV05(this.item);

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
              '+${item.avgProfitRate}%',
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
            '${item.waitingDays}일',
            style: TStyle.commonSTitle,
          )
        ],
      ),
    );
  }
}
