import 'package:flutter/material.dart';
import 'package:rassi_assist/common/ui_style.dart';

import '../../../common/const.dart';
import '../../../common/strings.dart';
import '../../../common/tstyle.dart';
import '../../../models/none_tr/stock/stock.dart';
import '../../../models/pg_data.dart';
import '../../../models/tr_issue03.dart';
import '../../main/base_page.dart';
import '../../news/issue_list_page.dart';
import '../../news/issue_viewer.dart';

/// 오늘의 이슈
class HomeTileIssue extends StatelessWidget {
  final List<Issue03> listIssue03;

  const HomeTileIssue({
    Key? key,
    this.listIssue03 = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _setSubTitleIssue(RString.tl_today_issues, listIssue03),
        Container(
          width: double.infinity,
          height: 300,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          margin: const EdgeInsets.only(top: 5),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: listIssue03.length,
            itemBuilder: (context, index) {
              return TileIssue03N(
                listIssue03[index],
                RColor.issueBack[index % 6],
                RColor.issueRelay[index % 6],
              );
            },
          ),
        )
      ],
    );
  }

  //소항목 이슈 타이틀
  Widget _setSubTitleIssue(String subTitle, List<Issue03> dataList) {
    var dayOfWeek = '';
    if (dataList.isNotEmpty) {
      if (dataList[0].issueDttm.isNotEmpty) {
        var dayStr = dataList[0].issueDttm.substring(0, 8);
        dayOfWeek = '${TStyle.getDateDivFormat(dayStr)}  ${TStyle.getWeekdayKor(dayStr)}';
      }
    }

    return Padding(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //오늘의 이슈
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  subTitle,
                  style: TStyle.title18T,
                ),
                InkWell(
                  onTap: () async {
                    basePageState.callPageRoute(
                      const IssueListPage(),
                    );
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: const Text(
                    '더보기',
                    style: TextStyle(
                      color: RColor.greyMore_999999,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 이슈 날짜
                Text(
                  dayOfWeek,
                  style: const TextStyle(
                    color: Color(0xff999999),
                  ),
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  //textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '오늘 선정된 이슈 총 ',
                      style: TextStyle(fontSize: 15,),
                    ),
                    Text(
                      listIssue03.length.toString(),
                      style: TStyle.commonSTitle,
                    ),
                    const Text(
                      '개',
                      style: TextStyle(fontSize: 15,),
                    ),
                  ],
                )
              ],
            ),
          ],
        ));
  }
}

//화면구성
class TileIssue03N extends StatelessWidget {
  final Issue03 item;
  final Color bColor;
  final Color tbColor;

  const TileIssue03N(this.item, this.bColor, this.tbColor, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int listLen;
    item.listStock.length > 3 ? listLen = 4 : listLen = item.listStock.length;

    return InkWell(
      child: Container(
        width: 290,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: UIStyle.boxShadowBasic(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topDesc(),
              const SizedBox(
                height: 15,
              ),
              _bottomItem(context, listLen),
            ],
          ),
        ),
      ),
      onTap: () {
        basePageState.callPageRouteUpData(
            const IssueViewer(),
            PgData(
              userId: '',
              pgSn: item.newsSn,
              pgData: item.issueSn,
            ));
      },
    );
  }

  Widget _topDesc() {
    String statusText = '';
    Color? statusColor;
    num value = double.parse(item.avgFluctRate);
    if (value > 0.1) {
      statusText = '▲ 상승중';
      statusColor = RColor.bubbleChartStrongRed;
    } else if (value > -0.1) {
      statusText = '- 0.00%';
      statusColor = RColor.bubbleChartGrey;
    } else {
      statusText = '▼ 하락중';
      statusColor = RColor.bubbleChartStrongBlue;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.keyword,
              style: TStyle.defaultTitle,
            ),

            // 상승중 / 하락중
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 4,
              ),
              decoration: UIStyle.roundBtnBox(statusColor!),
              child: Text(
                statusText,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 19,
        ),
        Text(
          item.title,
          style: TStyle.subTitle16,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          item.content,
          style: TextStyle(fontSize: 15, color: Color(0xff111111)),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  //관련 종목 부분
  Widget _bottomItem(BuildContext context, int len) {
    return Wrap(
      runAlignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      spacing: 7,
      alignment: WrapAlignment.start,
      children: List.generate(len, (index) => _relayStock(item.listStock[index])),
    );
  }

  //관련 종목
  Widget _relayStock(Stock one) {
    int strLen;
    one.stockName.length > 5 ? strLen = 6 : strLen = one.stockName.length;
    return InkWell(
      child: Text(
        '#${one.stockName.substring(0, strLen)}',
        style: const TextStyle(
          fontSize: 14,
          color: RColor.mainColor,
        ),
      ),
      onTap: () {
        basePageState.goStockHomePage(
          one.stockCode,
          one.stockName,
          Const.STK_INDEX_HOME,
        );
      },
    );
  }
}
