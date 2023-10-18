import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/ui/main/base_page.dart';


/// 2020.10.06
/// 매매비서 문의 종목 조회
class TrAsk02 {
  final String retCode;
  final String retMsg;
  final List<StockAsk>? retData;

  TrAsk02({this.retCode = '', this.retMsg = '', this.retData});

  factory TrAsk02.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<StockAsk> rtList;
    list == null
        ? rtList = []
        : rtList = list.map((i) => StockAsk.fromJson(i)).toList();

    return TrAsk02(
        retCode: json['retCode'], retMsg: json['retMsg'], retData: rtList);
  }
}

class StockAsk {
  final String stockCode;
  final String stockName;
  final String hasNews;

  StockAsk({this.stockCode = '', this.stockName = '', this.hasNews = ''});

  factory StockAsk.fromJson(Map<String, dynamic> json) {
    return StockAsk(
        stockCode: json['stockCode'],
        stockName: json['stockName'],
        hasNews: json['hasNews']);
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$hasNews';
  }
}

//화면구성
class TileAsk02 extends StatelessWidget {
  final StockAsk item;
  final Color bColor;

  TileAsk02(this.item, this.bColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(
        left: 10,
        right: 8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      decoration: BoxDecoration(
        color: bColor,
        shape: BoxShape.circle,
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Stack(
          children: [
            SizedBox(
              width: 90,
              child: Center(
                child: Text(
                  item.stockName,
                  style: TStyle.subTitle,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Positioned(
              right: 2.0,
              top: 12.0,
              child: Visibility(
                visible: item.hasNews == 'Y' ? true : false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'N',
                      style: TStyle.btnTextWht15,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
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
