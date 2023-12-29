import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

import '../stock_home/stock_home_tab.dart';

// 뉴스 하단 종목
class TileStock extends StatelessWidget {
  final Stock item;

  const TileStock(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.deepPurpleAccent.withAlpha(30),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: RColor.lineGrey,
            width: 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(6.0)),
        ),
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.stockCode,
              style: TStyle.textSGrey,
            ),
            Text(
              item.stockName,
              style: TStyle.subTitle,
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          ],
        ),
      ),
      onTap: () {
        if(StockHomeTab.globalKey.currentState == null){
          // 앞에 StockAiBreakingNewsPage 페이지 냅두기
          //Navigator.pop(context, false);
        } else{
          // 앞에 StockAiBreakingNewsPage, NewsTagPage 페이지 까지 다 닫기
          Navigator.pop(context, true);
        }
        basePageState.goStockHomePage(
          item.stockCode,
          item.stockName,
          Const.STK_INDEX_HOME,
        );
      },
    );
  }
}
