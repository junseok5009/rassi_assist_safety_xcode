import 'package:flutter/material.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_group.dart';
import 'package:rassi_assist/ui/common/common_view.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '비교해서 더 좋은 찾기',
            style: TStyle.defaultTitle,
          ),
          const SizedBox(height: 25,),
          Container(
            decoration: UIStyle.boxShadowBasic(16),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: compare01.listData.length,
              itemBuilder: (BuildContext context, int index) {
                return TileCompareItem(compare01.listData[index],
                    index + 1 == compare01.listData.length);
              },
            ),
          ),
          const SizedBox(height: 10,),
        ],
      ),
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
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stockGroup.stockGrpNm,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xff111111),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      //TODO 종목수가 없을 경우 표시 >> 24.05.28 HJS 종목을 비교하는 컨텐츠인데, 종목이 없는거면 에러 아닌가요...?
                      Text(
                        '${stockGroup.groupStockCnt}종목',
                        style: TStyle.listItem,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      CommonView.setFluctuationRateBox(value: stockGroup.groupfluctRate),
                    ],
                  ),
                ],
              ),
            ),
            isLast
                ? Container()
                : Container(
                    margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    color: Colors.black12,
                    height: 1.2,
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
