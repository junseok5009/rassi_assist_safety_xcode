import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_atom.dart';
import 'package:rassi_assist/ui/main/base_page.dart';


/// 2022.01.07
/// 평균 보유 기간이 짧은 종목
class TrFind07 extends TrAtom {
  final List<Find07> listData;

  TrFind07({String retCode = '', String retMsg = '', this.listData = const []})
      : super(retCode: retCode, retMsg: retMsg);

  factory TrFind07.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<Find07> rtList = list.map((i) => Find07.fromJson(i)).toList();

    return TrFind07(
        retCode: json['retCode'], retMsg: json['retMsg'], listData: rtList);
  }
}

class Find07 {
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String tradeDttm;
  final String holdingDays;
  final String elapsedDays;

  Find07({
    this.stockCode = '',
    this.stockName = '',
    this.tradeFlag = '',
    this.tradeDttm = '',
    this.holdingDays = '',
    this.elapsedDays = '',
  });

  factory Find07.fromJson(Map<String, dynamic> json) {
    return Find07(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      tradeFlag: json['tradeFlag'],
      tradeDttm: json['tradeDttm'],
      holdingDays: json['holdingDays'],
      elapsedDays: json['elapsedDays'],
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$tradeFlag|$holdingDays';
  }
}

//화면구성 - 종목캐치메인
class TileFind07 extends StatelessWidget {
  final Find07 item;

  const TileFind07(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10,),
      decoration: UIStyle.boxRoundLine6bgColor(Colors.white,),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '평균 보유기간 ',
                    style: TStyle.textSBuy,
                  ),
                  Text(
                    '${item.holdingDays}일',
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
class TileFindV07 extends StatelessWidget {
  final Find07 item;

  TileFindV07(this.item);

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
              '${item.holdingDays}일',
              style: TStyle.defaultContent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _setListItem3() {
    bool status = false;
    if (item.tradeFlag == 'B')
      status = true;
    else if (item.tradeFlag == 'S') status = false;

    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          status
              ? const Text(
                  '보유중',
                  style: TStyle.commonSTitle,
                )
              : Text(
                  '관망 ${item.elapsedDays}일째',
                  style: TStyle.commonSTitle,
                ),
        ],
      ),
    );
  }
}
