import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_data.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

import '../../common/ui_style.dart';
import '../stock_home/stock_home_tab.dart';

// 뉴스 하단 종목
class TileStock extends StatelessWidget {
  final StockData item;

  const TileStock(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: Ink(
        width: double.infinity,
        decoration: UIStyle.boxShadowBasic(16),
        child: InkWell(
          highlightColor: Colors.black.withOpacity(0.05),
          splashColor: Colors.black.withOpacity(0.07),
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
          child: Container(
            height: 86,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //종목명, 종목코드
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.stockName,
                        style: TStyle.commonTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        item.stockCode,
                        style: const TextStyle(
                          fontSize: 12,
                          color: RColor.greyBasic_8c8c8c,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 5),

                CommonView.setFluctuationRateBox(
                  marginEdgeInsetsGeometry: const EdgeInsets.only(
                    left: 15,
                  ),
                  value: item.fluctuationRate,
                ),
              ],
            ),
          ),
          onTap: () {
            if (StockHomeTab.globalKey.currentState == null) {
              // 앞에 StockAiBreakingNewsPage 페이지 냅두기
              //Navigator.pop(context, false);
            } else {
              // 앞에 StockAiBreakingNewsPage, NewsTagPage 페이지 까지 다 닫기
              Navigator.pop(context, true);
            }
            basePageState.goStockHomePage(
              item.stockCode,
              item.stockName,
              Const.STK_INDEX_HOME,
            );
          },
        ),
      ),
    );

/*      InkWell(
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
    );*/
  }
}
