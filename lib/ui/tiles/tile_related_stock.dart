import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_status.dart';
import 'package:rassi_assist/ui/market/issue_new_viewer.dart';

import '../main/base_page.dart';

///
class TileRelatedStock extends StatelessWidget {
  final StockStatus item;

  const TileRelatedStock(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: UIStyle.boxWithOpacity16(),
      child: InkWell(
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: _makeCardView(context),
        ),
        onTap: () {
          basePageState.goStockHomePage(
            item.stockCode,
            item.stockName,
            Const.STK_INDEX_HOME,
          );
        },
      ),
    );
  }

  Widget _makeCardView(BuildContext context) {
    String priceSubInfo = TStyle.getPercentString(item.fluctuationRate);
    Color priceSubInfoColor = Colors.grey;
    if (item.fluctuationRate.contains('-')) {
      priceSubInfoColor = RColor.sigSell;
    } else if (item.fluctuationRate == '0.00') {
      priceSubInfoColor = Colors.grey;
    } else {
      priceSubInfoColor = RColor.sigBuy;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.stockName,
                        style: TStyle.commonTitle,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.stockCode,
                        style: TStyle.contentGrey12,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.bizOverview,
                    style: const TextStyle(
                      //본문 내용
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xff777777),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
              decoration: BoxDecoration(
                color: priceSubInfoColor,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: Text(
                priceSubInfo,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Visibility(
          visible: item.listKeyword.isNotEmpty,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            width: double.infinity,
            child: Wrap(
              spacing: 7.0,
              alignment: WrapAlignment.start,
              children: List.generate(
                item.listKeyword.length > 3 ? 3 : item.listKeyword.length,
                (index) => InkWell(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(7, 3, 7, 3),
                    decoration: UIStyle.boxRoundLine25c(const Color(0xffD2D2D2)),
                    child: Text(
                      '#${item.listKeyword[index].keyword}',
                      style: TStyle.content14,
                    ),
                  ),
                  onTap: () {
                    IssueNewViewerState parent = context.findAncestorStateOfType<IssueNewViewerState>()!;
                    parent.changeIssue(item.listKeyword[index].newsSn);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
