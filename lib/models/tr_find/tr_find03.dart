import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_atom.dart';
import 'package:rassi_assist/ui/main/base_page.dart';


/// 2020.10.19
/// 승률 높은 매수 대기 종목
class TrFind03 extends TrAtom {
  final List<Find03> listData;

  TrFind03({String retCode = '', String retMsg = '', this.listData = const []})
      : super(retCode: retCode, retMsg: retMsg);

  factory TrFind03.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    // List<Find03>? rtList;
    // list != null
    //     ? rtList = list.map((i) => Find03.fromJson(i)).toList()
    //     : rtList = null;

    return TrFind03(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        listData: list.map((i) => Find03.fromJson(i)).toList()
    );
  }
}

class Find03 {
  final String stockCode;
  final String stockName;
  final String winningRate;
  final String waitingDays;

  Find03({this.stockCode = '', this.stockName = '', this.winningRate = '', this.waitingDays = ''});

  factory Find03.fromJson(Map<String, dynamic> json) {
    return Find03(
        stockCode: json['stockCode'],
        stockName: json['stockName'],
        winningRate: json['winningRate'],
        waitingDays: json['waitingDays']);
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$winningRate|$waitingDays';
  }
}

//화면구성
class TileFind03 extends StatelessWidget {
  final Find03 item;
  const TileFind03(this.item, {Key? key}) : super(key: key);
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
              //종목정보
              Column(
                children: [
                  Text(
                    TStyle.getLimitString(item.stockName, 8),
                    style: TStyle.subTitle,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
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
                    '적중률',
                    style: TStyle.textSBuy,
                  ),
                  // const SizedBox(height: 4,),
                  Text(
                    item.winningRate + '%',
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
class TileFindV03 extends StatelessWidget {
  final Find03 item;

  TileFindV03(this.item);

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
            '${item.waitingDays}일',
            style: TStyle.commonSTitle,
          )
        ],
      ),
    );
  }
}
