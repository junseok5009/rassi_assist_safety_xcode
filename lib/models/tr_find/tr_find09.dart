import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_atom.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

/// 2022.01.07
/// 주간 토픽 중 최근 매수 종목
class TrFind09 extends TrAtom {
  final List<Find09> listData;

  TrFind09({String retCode = '', String retMsg = '', this.listData = const []})
      : super(retCode: retCode, retMsg: retMsg);

  factory TrFind09.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<Find09> rtList = list.map((i) => Find09.fromJson(i)).toList();

    return TrFind09(
        retCode: json['retCode'], retMsg: json['retMsg'], listData: rtList);
  }
}

class Find09 {
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String tradePrice;
  final String tradeDate;
  final String tradeTime;
  final String issueTmTx;
  final String regDttm;

  Find09({
    this.stockCode = '',
      this.stockName = '',
      this.tradeFlag = '',
      this.tradePrice = '',
      this.tradeDate = '',
      this.tradeTime = '',
      this.issueTmTx = '',
      this.regDttm = ''
  });

  factory Find09.fromJson(Map<String, dynamic> json) {
    return Find09(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      tradeFlag: json['tradeFlag'],
      tradePrice: json['tradePrice'],
      tradeDate: json['tradeDate'],
      tradeTime: json['tradeTime'],
      issueTmTx: json['issueTmTx'],
      regDttm: json['regDttm'],
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$tradeFlag|$tradePrice';
  }
}

//화면구성
class TileFind09 extends StatelessWidget {
  final Find09 item;

  const TileFind09(this.item, {Key? key}) : super(key: key);

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
                children: [
                  const Text(
                    '매수가',
                    style: TStyle.textSBuy,
                  ),
                  // const SizedBox(height: 4,),
                  Text(
                    '${TStyle.getMoneyPoint(item.tradePrice)}원',
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
class TileFindV09 extends StatelessWidget {
  final Find09 item;

  TileFindV09(this.item);

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
    String dateTime = item.tradeDate + item.tradeTime;
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
              '${TStyle.getDateTdFormat(dateTime)}',
              style: TStyle.contentGrey14,
            ),
            Text(
              '${TStyle.getMoneyPoint(item.tradePrice)}원',
              style: TStyle.defaultContent,
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
            '${item.issueTmTx}',
            style: TStyle.commonSTitle,
          )
        ],
      ),
    );
  }
}
