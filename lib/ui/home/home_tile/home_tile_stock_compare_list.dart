import 'package:flutter/material.dart';
import 'package:rassi_assist/models/stock_group.dart';

import '../../../common/const.dart';
import '../../../common/tstyle.dart';
import '../../../common/ui_style.dart';
import '../../../models/pg_data.dart';
import '../../../models/tr_compare/tr_compare01.dart';
import '../../main/base_page.dart';
import '../../stock_home/page/stock_compare_page.dart';


/// 비교해서 더 좋은 찾기 (종목비교)
class HomeTileStockCompareList extends StatelessWidget {
  final Compare01 compare01;

  const HomeTileStockCompareList(this.compare01, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: RColor.new_basic_grey,
          height: 15.0,
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(15, 25, 15, 10),
          alignment: Alignment.centerLeft,
          child: const Text(
            '비교해서 더 좋은 찾기',
            style: TStyle.commonTitle,
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(15, 15, 15, 10),
          decoration: UIStyle.boxWithOpacityNew(),
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: compare01.listData.length,
            itemBuilder: (BuildContext context, int index) {
              return TileCompareItem(
                  compare01.listData[index],
                  index + 1 == compare01.listData.length
              );
            },
          ),
        ),
      ],
    );
  }
}


//화면구성
class TileCompareItem extends StatelessWidget {
  final StockGroup stockGroup;
  final bool isLast;

  const TileCompareItem(this.stockGroup, this.isLast, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: double.infinity,
        // height: 71,
        alignment: Alignment.centerLeft,
        // margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0,),
        // decoration: UIStyle.boxWithOpacityNew(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              // height: 65,
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stockGroup.stockGrpNm,
                    style: TStyle.listItem,
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      //TODO 종목수가 없을 경우 표시
                      Text(
                        '${stockGroup.groupStockCnt}종목',
                        style: TStyle.listItem,
                      ),
                      const SizedBox(width: 10,),

                      Container(
                        width: 75,
                        height: 27,
                        alignment: Alignment.center,
                        decoration: UIStyle.boxRoundFullColor6c(
                          TStyle.getMinusPlusColor(stockGroup.groupfluctRate),
                        ),
                        child: Text(
                          TStyle.getPercentString(stockGroup.groupfluctRate),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),

            isLast ? Container() :
            Container(
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              color: RColor.new_basic_grey,
              height: 1.5,
            ),
          ],
        ),
      ),
      onTap: () {
        // 종목비교 상세
        basePageState.callPageRouteData(
          StockComparePage(),
          PgData(
            stockName: stockGroup.listStock[0].stockName,
            stockCode: stockGroup.listStock[0].stockCode,
          ),
        );
      },
    );
  }
}