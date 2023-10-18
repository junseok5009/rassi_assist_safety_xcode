import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/stock_info.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

/// 인기 종목 매매신호 리스트 조회 (관심종목 추가 건수 or 네이버 검색 상위)
class TrSearch04 {
  final String retCode;
  final String retMsg;
  final Search04 retData;

  TrSearch04({this.retCode='', this.retMsg='', this.retData = defSearch04});

  factory TrSearch04.fromJson(Map<String, dynamic> json) {
    return TrSearch04(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null
            ? defSearch04
            : Search04.fromJson(json['retData']));
  }
}


const defSearch04 = Search04();

class Search04 {
  final String updateDttm; //YYYYMMDDHH24MISS
  final List<StockInfo> listStock;

  const Search04({this.updateDttm='', this.listStock = const []});

  factory Search04.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    List<StockInfo> listData = list.map((e) => StockInfo.fromJson(e)).toList();
    return Search04(updateDttm: json['updateDttm'], listStock: listData);
  }
}

//화면구성
class TileSearch04 extends StatelessWidget {
  final StockInfo item;

  const TileSearch04(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String strStatus;
    Color statColor;

    if (item.flag == 'B' || item.flag == 'H') {
      strStatus = '보유중';
      statColor = RColor.bgBuy;
    } else {
      strStatus = '관망중';
      statColor = RColor.bgGrey;
    }

    return Container(
      width: double.infinity,
      height: 80,
      margin: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 10.0,
      ),
      alignment: Alignment.centerLeft,
      decoration: UIStyle.boxRoundLine6(),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: double.infinity,
          height: 77,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  //보유/관망 표시
                  _setImageLabel(strStatus, statColor),
                  const SizedBox(
                    width: 15.0,
                  ),

                  //종목정보
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TStyle.getLimitString(item.stockName, 11),
                        style: TStyle.commonTitle,
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        item.stockCode,
                        style: TStyle.textSGrey,
                      ),
                    ],
                  ),
                ],
              ),

              //보유수익률 or 관망 몇일째
              _setSubData(),
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

  // 좌측 보유/관망 표시
  Widget _setImageLabel(String str, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(0.0),
            bottomLeft: Radius.circular(25.0),
            bottomRight: Radius.circular(25.0),
          )),
      child: Center(
        child: Text(
          str,
          style: TStyle.btnTextWht12,
        ),
      ),
    );
  }

  // 우측 매매정보
  Widget _setSubData() {
    if (item.flag == 'B' || item.flag == 'H') {
      //보유
      if (TStyle.getTodayString() == item.tradeDate) {
        return _setTodayBuy();
      } else {
        return _setHoldingInfo();
      }
    } else {
      if (TStyle.getTodayString() == item.tradeDate) {
        //당일 매도
        return _setTodaySell();
      } else {
        //관망
        return _setWatchingInfo();
      }
    }
  }

  //당일매수
  Widget _setTodayBuy() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _setTodayBuyTag(),
        const SizedBox(
          height: 2.0,
        ),
        Row(
          children: [
            const Text('매수가'),
            const SizedBox(
              width: 2.0,
            ),
            Text(
              TStyle.getMoneyPoint(item.tradePrc),
              style: TStyle.commonSTitle,
            ),
            const Text('원'),
          ],
        ),
        Row(
          children: [
            const Text('발생'),
            const SizedBox(
              width: 2.0,
            ),
            Text(
              '${getDateFormat(item.tradeDate)} ${getTimeFormat(item.tradeTime)}',
              style: TStyle.contentSBLK,
            ),
          ],
        ),
      ],
    );
  }

  //보유중
  Widget _setHoldingInfo() {
    Color profitColor;
    String stkProfit;
    if (item.profitRate.contains('-')) {
      stkProfit = '${item.profitRate}%';
      profitColor = RColor.sigSell;
    } else {
      stkProfit = '+${item.profitRate}%';
      profitColor = RColor.sigBuy;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            const Text('매수가'),
            const SizedBox(
              width: 3.0,
            ),
            Text(
              TStyle.getMoneyPoint(item.tradePrc),
              style: TStyle.subTitle,
            ),
            const Text('원'),
          ],
        ),
        Row(
          children: [
            const Text('보유수익률'),
            const SizedBox(
              width: 3.0,
            ),
            Text(
              stkProfit,
              style: TextStyle(
                color: profitColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
      ],
    );
  }

  //관망중
  Widget _setWatchingInfo() {
    return Row(
      children: [
        const Text('관망'),
        Text(
          item.elapsedDays,
          style: TStyle.commonSTitle,
        ),
        const Text('일째'),
      ],
    );
  }

  //당일매도
  Widget _setTodaySell() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _setTodaySellTag(),
        const SizedBox(
          height: 2.0,
        ),
        Row(
          children: [
            const Text('매도가'),
            const SizedBox(
              width: 2.0,
            ),
            Text(
              TStyle.getMoneyPoint(item.tradePrc),
              style: TStyle.subTitle,
            ),
            const Text('원'),
          ],
        ),
        Row(
          children: [
            const Text('발생'),
            const SizedBox(
              width: 2.0,
            ),
            Text(
              '${getDateFormat(item.tradeDate)} ${getTimeFormat(item.tradeTime)}',
              style: TStyle.contentSBLK,
            ),
          ],
        ),
      ],
    );
  }

  //Today 매도
  Widget _setTodaySellTag() {
    return Container(
      width: 50,
      height: 11,
      decoration: const BoxDecoration(
        color: RColor.sigSell,
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
      ),
      child: const Center(
        child: Text(
          'Today 매도',
          style: TStyle.btnSsTextWht,
        ),
      ),
    );
  }

  //Today 매수
  Widget _setTodayBuyTag() {
    return Container(
      width: 50,
      height: 11,
      decoration: const BoxDecoration(
        color: RColor.sigBuy,
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
      ),
      child: const Center(
        child: Text(
          'Today 매수',
          style: TStyle.btnSsTextWht,
        ),
      ),
    );
  }

  //날짜 형식 표시
  String getDateFormat(String date) {
    String rtStr = '';
    if (date.length > 7) {
      rtStr = '${date.substring(4, 6)}/${date.substring(6, 8)}';
      return rtStr;
    }
    return '';
  }

  //시간 형식 표시
  String getTimeFormat(String time) {
    String rtStr = '';
    if (time.length > 3) {
      rtStr = '${time.substring(0, 2)}:${time.substring(2, 4)}';
      return rtStr;
    }
    return '';
  }

//인기종목 관련 트레킹
// void _setWiseTrackerPop(String selStock, String seq) {
//   var event = {};
//   event["event"] = "w_click_item-n-soar_stock";
//   event["page_id"] = "ai_signal";
//   event["item_name"] = selStock;
//   event["placement"] = seq; // string
//   DOT.logEvent(event);
// }
}
