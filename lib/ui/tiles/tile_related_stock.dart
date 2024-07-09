import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_status.dart';
import 'package:rassi_assist/ui/news/issue_viewer.dart';

import '../main/base_page.dart';

///
class TileRelatedStock extends StatelessWidget {
  final StockStatus item;
  bool isIssue = false;

  TileRelatedStock(this.item);

  @override
  Widget build(BuildContext context) {
    if (item.listKeyword.isNotEmpty) {
      isIssue = true;
    }
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
          basePageState.goStockHomePageCheck(
            context,
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
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        item.stockCode,
                        style: TStyle.contentGrey12,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
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
        Visibility(
          visible: isIssue,
          child: Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              Container(
                height: 20,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: item.listKeyword.length > 3 ? 3 : item.listKeyword.length,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (BuildContext bContext, int index) {
                    return const SizedBox(
                      width: 10,
                    );
                  },
                  itemBuilder: (BuildContext bContext, int index) {
                    return InkWell(
                      onTap: () {
                        IssueDetailState parent = context.findAncestorStateOfType<IssueDetailState>()!;
                        parent.cheangeIssue(item.listKeyword[index].newsSn);
                      },
                      child: Text(
                        '#${item.listKeyword[index].keyword}',
                        style: TStyle.commonSPurple,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
