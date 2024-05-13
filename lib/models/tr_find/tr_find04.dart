import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

/// 2020.10.19
/// 평균 수익률 높은 종목 - 최근3일내 매수 종목
class TrFind04 {
  final String retCode;
  final String retMsg;
  final List<Find04> listData;

  TrFind04({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrFind04.fromJson(Map<String, dynamic> json) {
    var jsonList = json['retData'];
    return TrFind04(
        retCode: json['retCode'], retMsg: json['retMsg'], listData: jsonList == null ? [] : (jsonList as List).map((i) => Find04.fromJson(i)).toList());
  }
}

class Find04 {
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String tradeDttm;
  final String tradePrice;
  final String avgProfitRate;

  Find04(
      {this.stockCode = '',
      this.stockName = '',
      this.tradeFlag = '',
      this.tradeDttm = '',
      this.tradePrice = '',
      this.avgProfitRate = ''});

  factory Find04.fromJson(Map<String, dynamic> json) {
    return Find04(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      tradeFlag: json['tradeFlag'],
      tradeDttm: json['tradeDttm'],
      tradePrice: json['tradePrice'],
      avgProfitRate: json['avgProfitRate'],
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$tradeFlag|$tradePrice|$avgProfitRate|$tradeDttm';
  }
}

//화면구성
class TileFind04 extends StatelessWidget {
  final Find04 item;
  final int index;

  const TileFind04(this.index, this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 135,
      margin: EdgeInsets.only(
        left: index == 0 ? 0 : 10,
      ),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: UIStyle.boxRoundLine6bgColor(
        Colors.white,
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
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
class TileFindV04 extends StatelessWidget {
  final Find04 item;

  TileFindV04(this.item);

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
            getDateFormat(item.tradeDttm),
            style: TStyle.textSGrey,
          ),
          const SizedBox(
            height: 3.0,
          ),
          Text(
            '${TStyle.getMoneyPoint(item.tradePrice)}원',
            style: TStyle.commonSTitle,
          )
        ],
      ),
    );
  }

  String getDateFormat(String date) {
    String rtStr = '';
    if (date.length > 8) {
      rtStr = '${date.substring(4, 6)}.${date.substring(6, 8)}  ${date.substring(8, 10)}:${date.substring(10, 12)}';
      return rtStr;
    }
    return '';
  }
}
