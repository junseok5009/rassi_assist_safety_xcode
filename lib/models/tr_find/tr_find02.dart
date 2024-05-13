import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_atom.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

/// 2020.10.19
/// 최근 매수한 승률 높은 종목
class TrFind02 extends TrAtom {
  // final String retCode;
  // final String retMsg;
  final List<Find02> listData;

  TrFind02({String retCode = '', String retMsg = '', this.listData = const []})
      : super(retCode: retCode, retMsg: retMsg);

  factory TrFind02.fromJson(Map<String, dynamic> json) {
    var jsonList = json['retData'];
    return TrFind02(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        listData: jsonList == null ? [] : (jsonList as List).map((i) => Find02.fromJson(i)).toList());
  }
}

class Find02 {
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String tradeDttm;
  final String tradePrice;
  final String winningRate;

  Find02(
      {this.stockCode = '',
      this.stockName = '',
      this.tradeFlag = '',
      this.tradeDttm = '',
      this.tradePrice = '',
      this.winningRate = ''});

  factory Find02.fromJson(Map<String, dynamic> json) {
    return Find02(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      tradeFlag: json['tradeFlag'],
      tradeDttm: json['tradeDttm'],
      tradePrice: json['tradePrice'],
      winningRate: json['winningRate'],
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$tradeFlag|$tradePrice|$winningRate|$tradeDttm';
  }
}

//화면구성
class TileFind02 extends StatelessWidget {
  final int index;
  final Find02 item;

  const TileFind02(this.index, this.item, {Key? key}) : super(key: key);

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
            //종목정보
            Column(
              children: [
                Text(
                  TStyle.getLimitString(item.stockName, 8),
                  style: TStyle.subTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

// void _regWiseOnClick(String mapCode) {
//   var event = {};
//   event["event"] = mapCode;
//   event["page_id"] = "ai_signal";
//   DOT.logEvent(event);
// }
}

//상세리스트 (Vertical list)
class TileFindV02 extends StatelessWidget {
  final Find02 item;

  const TileFindV02(this.item, {super.key});

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

  //매수일
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
