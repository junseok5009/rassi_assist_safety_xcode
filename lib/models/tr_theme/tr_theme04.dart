import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_info.dart';
import 'package:rassi_assist/models/tr_atom.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

/// 2022.01.11
/// 테마 상세 조회
class TrTheme04 extends TrAtom {
  final Theme04 retData;

  TrTheme04({
    String retCode = '',
    String retMsg = '',
    this.retData = defaultObj,
  }) : super(retCode: retCode, retMsg: retMsg);

  factory TrTheme04.fromJson(Map<String, dynamic> json) {
    return TrTheme04(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: Theme04.fromJson(json['retData']),
    );
  }
}

const defaultObj = Theme04(
    themeCode: '', themeName: '', totalCount: '',
    buyCount: '', holdCount: '', sellCount: '',
    waitCount: '', increaseRate: '', listData: []
);

class Theme04 {
  final String themeCode;
  final String themeName;
  final String totalCount;
  final String buyCount;
  final String holdCount;
  final String sellCount;
  final String waitCount;
  final String increaseRate;
  final List<StockInfo> listData;

  const Theme04({
    this.themeCode = '',
    this.themeName = '',
    this.totalCount = '',
    this.buyCount = '',
    this.holdCount = '',
    this.sellCount = '',
    this.waitCount = '',
    this.increaseRate = '',
    this.listData = const [],
  });

  factory Theme04.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    // List<StockInfo>? rtList;
    // list == null
    //     ? rtList = null
    //     : rtList = list.map((i) => StockInfo.fromJson(i)).toList();

    return Theme04(
      themeCode: json['themeCode'],
      themeName: json['themeName'],
      totalCount: json['totalCount'],
      buyCount: json['buyCount'],
      holdCount: json['holdCount'],
      sellCount: json['sellCount'],
      waitCount: json['waitCount'],
      increaseRate: json['increaseRate'],
      listData: list.map((i) => StockInfo.fromJson(i)).toList(),
    );
  }
}

//화면구성
class TileTheme04 extends StatelessWidget {
  final appGlobal = AppGlobal();
  final StockInfo item;
  final bool isPremium; //true:모두공개, false:공개안함

  TileTheme04.gen(this.item, this.isPremium);

  // TileTheme04(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: UIStyle.boxRoundLine15(),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: _setTileLayout(item),
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

  Widget _setTileLayout(StockInfo item) {
    String statTxt = '';
    String typeText = '';
    Color statColor = RColor.sigWatching;
    Color rateColor;
    String rateText;
    String dateTime = '';
    String preText = '';
    bool isToday = false;

    if (item.flag == 'B') {
      statTxt = 'TODAY\n매수';
      statColor = RColor.bgBuy;
      isToday = true;
      preText = '매수가';
    } else if (item.flag == 'S') {
      statTxt = 'TODAY\n매도';
      statColor = RColor.bgSell;
      isToday = true;
      preText = '매도가';
    } else if (item.flag == 'H') {
      statTxt = '보유중';
      typeText = '보유';
      statColor = RColor.sigHolding;
      preText = '매수가';
    } else if (item.flag == 'W') {
      statTxt = '관망중';
      typeText = '관망';
      statColor = RColor.sigWatching;
    }

    if (item.profitRate.contains('-')) {
      rateText = item.profitRate;
      rateColor = RColor.bgSell;
    } else {
      rateText = '+' + item.profitRate;
      rateColor = RColor.bgBuy;
    }
    dateTime = '${item.tradeDate}${item.tradeTime}';

    if (!isPremium) {
      //프리미엄 회원이 아닐경우
      statTxt = '?';
      statColor = RColor.lineGrey;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _setCircleText(statTxt, statColor),
                  const SizedBox(
                    width: 10,
                  ),
                  _setStockInfo(),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  //매수/매도 가격
                  Visibility(
                    visible: isPremium && (isToday || item.flag == 'H'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$preText  ',
                          style: TStyle.textGrey15,
                        ),
                        Text(
                          TStyle.getMoneyPoint(item.tradePrc),
                          style: TStyle.commonTitle,
                        ),
                        const Text(
                          '원 ',
                          style: TStyle.textGrey15,
                        ),
                      ],
                    ),
                  ),

                  //오늘 매수/매도 시간
                  Visibility(
                    visible: isPremium && isToday,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(
                          width: 3,
                        ),
                        Text('${TStyle.getDateTdFormat(dateTime)} ')
                      ],
                    ),
                  ),

                  //보유/관망 몇일째
                  Visibility(
                    visible: isPremium && (item.flag == 'W'), //관망일때만 보여줌
                    child: Row(
                      children: [
                        Text(
                          '$typeText ',
                          style: TStyle.textGrey15,
                        ),
                        Text(
                          item.elapsedDays,
                          style: TStyle.commonTitle,
                        ),
                        const Text(
                          '일째 ',
                          style: TStyle.textGrey15,
                        ),
                      ],
                    ),
                  ),

                  //수익률
                  Visibility(
                    visible: isPremium && (item.flag == 'H'), //보유일때만 보여줌
                    child: Row(
                      children: [
                        Visibility(
                          visible: item.flag != 'S',
                          child: const Text(
                            '보유 수익률',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text('$rateText%',
                            style: TextStyle(
                              color: rateColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            )),
                        const SizedBox(
                          width: 3,
                        ),
                      ],
                    ),
                  ),

                  Visibility(
                    visible: !isPremium,
                    child: const Text(
                      '종목홈에서 라씨 매매비서\n신호를 확인해 보세요!',
                      textAlign: TextAlign.end,
                      style: TStyle.contentGrey14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Visibility(
          visible: false,
          child: Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            width: double.infinity,
            decoration: UIStyle.boxWeakGrey10(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  '회원님만을 위한 ',
                ),
                // Text('매도신호 ${TStyle.getMoneyPoint(item.sellPrice)}원',
                //   style: TStyle.commonSTitle,),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _setCircleText(String statTxt, Color statColor) {
    return Container(
      width: 60.0,
      height: 60.0,
      decoration: BoxDecoration(
        color: statColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$statTxt',
          style: TStyle.btnTextWht15,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // 종목명 / 종목코드
  Widget _setStockInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TStyle.getLimitString(item.stockName, 8),
          style: TStyle.commonTitle,
          maxLines: 1,
          overflow: TextOverflow.clip,
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          item.stockCode,
          style: TStyle.textSGrey,
        ),
      ],
    );
  }
}
