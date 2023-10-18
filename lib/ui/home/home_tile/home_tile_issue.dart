import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rassi_assist/common/ui_style.dart';

import '../../../common/const.dart';
import '../../../common/d_log.dart';
import '../../../common/strings.dart';
import '../../../common/tstyle.dart';
import '../../../models/pg_data.dart';
import '../../../models/stock.dart';
import '../../../models/tr_issue03.dart';
import '../../main/base_page.dart';
import '../../news/issue_list_page.dart';
import '../../news/issue_viewer.dart';


/// 오늘의 이슈
class HomeTileIssue extends StatelessWidget {
  List<Issue03> listIssue03 = [];

  HomeTileIssue(this.listIssue03, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _setSubTitleIssue(RString.tl_today_issues, listIssue03),

        Container(
          width: double.infinity,
          height: 330,
          // color: Colors.grey.shade50,
          margin: const EdgeInsets.only(top: 15),
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
    if(dataList.isNotEmpty) {
      if(dataList[0].issueDttm.isNotEmpty){
        var dayStr = dataList[0].issueDttm.substring(0, 8);
        dayOfWeek = '${TStyle.getDateDivFormat(dayStr)}  ${TStyle.getWeekdayEng(dayStr)}';
      }
    }

    return Padding(
        padding: const EdgeInsets.only(top: 25, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //오늘의 이슈
            Text(
              subTitle,
              style: TStyle.commonTitle,
            ),
            const SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 이슈 날짜
                Text(
                  dayOfWeek,
                  style: TStyle.textGrey14,
                ),

                Row(
                  children: [
                    const Text(
                      '오늘 선정된 이슈 총 ',
                      style: TStyle.content15,
                    ),
                    Text(
                      listIssue03.length.toString(),
                      style: TStyle.subTitle,
                    ),
                    const Text(
                      '개',
                      style: TStyle.content15,
                    ),
                  ],
                )
              ],
            ),
          ],
        )
    );
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
        // height: 170,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        padding: const EdgeInsets.all(15.0),
        decoration: UIStyle.boxWithOpacityNew(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topDesc(),
                const SizedBox(height: 12,),
                _bottomItem(context, listLen),
              ],
            ),

            Column(
              children: [
                Container(
                  color: RColor.new_basic_grey,
                  height: 1.5,
                ),

                Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: InkWell(
                    child: const Text(
                        '이슈 전체 보기'
                    ),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IssueListPage(),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        basePageState.callPageRouteUpData(
            IssueViewer(),
            PgData(userId: '', pgSn: item.newsSn, pgData: item.issueSn));
      },
    );
  }

  Widget _topDesc() {
    String statusText = '';
    Color statusColor;
    if(item.issueStatus == 'up') {
      statusText = '▲ 상승중';
      statusColor = RColor.sigBuy;
    } else if(item.issueStatus == 'dn') {
      statusText = '▼ 하락중';
      statusColor = RColor.sigSell;
    } else {
      // 보합
      statusText = '    ';
      statusColor = Colors.white;
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
              decoration: UIStyle.roundBtnBox(statusColor),
              child: Text(
                statusText,
                style: TStyle.btnTextWht14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15,),

        Text(
          item.title,
          style: TStyle.subTitle,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12,),

        Text(
          item.content,
          style: TStyle.textGrey15,
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
      children: List.generate(
          len, (index) => _relayStock(item.listStock[index])),
    );
  }

  //관련 종목
  Widget _relayStock(Stock one) {
    int strLen;
    one.stockName.length > 5 ? strLen = 6 : strLen = one.stockName.length;
    return InkWell(
      child: Container(
        child: Text(
          '#${one.stockName.substring(0, strLen)}',
          style: TStyle.commonPurple14,
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
