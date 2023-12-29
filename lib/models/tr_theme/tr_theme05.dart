import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_chart.dart';
import 'package:rassi_assist/models/tr_atom.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

/// 2022.05.12
/// 테마 주도주(종목) 조회
class TrTheme05 extends TrAtom {
  final Theme05 retData;

  TrTheme05({
    String retCode='',
    String retMsg='',
    this.retData = defTheme05,
  }) : super(retCode: retCode, retMsg: retMsg);

  factory TrTheme05.fromJson(Map<String, dynamic> json) {
    return TrTheme05(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: Theme05.fromJson(json['retData']),
    );
  }
}

const defTheme05 = Theme05();

class Theme05 {
  final String selectDiv;
  final List<StockChart> listStock;

  const Theme05({
    this.selectDiv = '',
    this.listStock = const [],
  });

  factory Theme05.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    List<StockChart>? rtList;
    list == null
        ? rtList = []
        : rtList = list.map((i) => StockChart.fromJson(i)).toList();

    return Theme05(
      selectDiv: json['selectDiv'],
      listStock: list.map((i) => StockChart.fromJson(i)).toList(),
    );
  }
}

//화면구성
class TileTheme05 extends StatelessWidget {
  final StockChart item;

  // final String days;
  final String selDiv;

  TileTheme05(this.item, this.selDiv, {Key? key}) : super(key: key);

  //TODO 미리 컬러를 선택된 상태에서  final 로 방는 방식으로 변경 하기
  Color mColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: double.infinity,
        height: 143,
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: UIStyle.boxRoundLine6(),
        child: _setStockContainer(),
      ),
      onTap: () {
        basePageState.goStockHomePage(
          item.stockCode,
          item.stockName,
          Const.STK_INDEX_HOME,
        );
      },
    );
  }

  Widget _setStockContainer() {
    String curSubInfo;

    if (item.fluctuationRate.contains('-')) {
      curSubInfo =
          '▼${TStyle.getMoneyPoint(item.fluctuationAmt.replaceAll('-', ''))}  ${item.fluctuationRate}%';
      mColor = RColor.sigSell;
    } else if (item.fluctuationRate == '0.00') {
      curSubInfo =
          '${TStyle.getMoneyPoint(item.fluctuationAmt)}  ${item.fluctuationRate}%';
    } else {
      curSubInfo =
          '▲${TStyle.getMoneyPoint(item.fluctuationAmt)}  +${item.fluctuationRate}%';
      mColor = RColor.sigBuy;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.stockName,
                      style: TStyle.defaultTitle,
                    ),
                    Text(
                      item.stockCode,
                      style: TStyle.contentGrey14,
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
              Row(
                children: [
                  Text(
                    selDiv == 'SHORT' ? '최근 5일간' : '이번 추세기간', //'최근 $days일간',
                    style: TStyle.textGreyDefault,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  _setTextBox('${TStyle.getFixedNum(item.increaseRate)}%'),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
            width: double.infinity,
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: UIStyle.boxWeakGrey6(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      TStyle.getMoneyPoint(item.currentPrice),
                      style: TStyle.commonTitle,
                    ),
                    const SizedBox(
                      width: 9,
                    ),
                    Text(
                      curSubInfo,
                      style: TextStyle(
                        color: mColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 박스 안에 텍스트
  Widget _setTextBox(String text) {
    Color bColor;
    String sText;
    if (text.contains('-')) {
      sText = text;
      bColor = RColor.sigSell;
    } else {
      sText = '+$text';
      bColor = RColor.sigBuy;
    }
    return Container(
      width: 105,
      height: 30,
      padding: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: bColor,
        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
      ),
      child: Text(
        sText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 17,
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
