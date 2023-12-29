import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/ui/news/news_viewer.dart';

import '../../ui/main/base_page.dart';
import '../../ui/news/issue_viewer.dart';
import '../../ui/stock_home/page/disclos_detail_page.dart';
import '../../ui/stock_home/page/recent_social_list_page.dart';
import '../pg_news.dart';

class TrSearch09 {
  final String retCode;
  final String retMsg;
  final Search09 retData;

  TrSearch09({this.retCode = '', this.retMsg = '', this.retData = defSearch09});

  factory TrSearch09.fromJson(Map<String, dynamic> json) {
    return TrSearch09(
        retCode: json['retCode'], retMsg: json['retMsg'], retData: json['retData'] == null ? defSearch09 : Search09.fromJson(json['retData']));
  }
}

const defSearch09 = Search09();

class Search09 {
  final String issueDate;
  final String tradePrice;
  final String fluctuationRate;
  final String fluctuationAmt;
  final List<Event> listEvent;

  const Search09({
    this.issueDate = '',
    this.tradePrice = '',
    this.fluctuationRate = '',
    this.fluctuationAmt = '',
    this.listEvent = const [],
  });

/*  Search09.empty() {
    issueDate = '';
    tradePrice = '';
    fluctuationRate = '';
    fluctuationAmt = '';
    listEvent = [];
  }*/

  factory Search09.fromJson(Map<String, dynamic> json) {
    var list = json['list_Event'] as List;
    List<Event> listData = list == null ? [] : list.map((e) => Event.fromJson(e)).toList();
    return Search09(
      issueDate: json['issueDate'] ?? '',
      tradePrice: json['tradePrice'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
      fluctuationAmt: json['fluctuationAmt'] ?? '',
      listEvent: listData,
    );
  }
}

const defEvent = Event();

class Event {
  // 이슈포착
  final String newsDiv; // ISS : 이슈포착, SND : 수급포착, SCR: 실적 발표, SNS : 소셜 분석, DSC : 공시 발생
  final String newsSn; // 소셜분석 빼고 상세 코드
  final String issueSn;
  final String keyword;
  final String title;
  final String content;
  final String sbCategName; // 차트분석 - 스톡벨 카테고리 이름 (시세, 정보)
  final String concernGrade; // 소셜분석 - 관심 등급(지수) > 1:조용, 2:수군, 3:왁자지껄, 4:폭발

  const Event({
    this.newsDiv = '',
    this.newsSn = '',
    this.issueSn = '',
    this.keyword = '',
    this.title = '',
    this.content = '',
    this.sbCategName = '',
    this.concernGrade = '',
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      newsDiv: json['newsDiv'] ?? '',
      newsSn: json['newsSn'] ?? '',
      issueSn: json['issueSn'] ?? '',
      keyword: json['keyword'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      sbCategName: json['sbCategName'] ?? '',
      concernGrade: json['concernGrade'] ?? '',
    );
  }

  @override
  String toString() {
    return '$newsDiv|$newsSn|$issueSn|$keyword|$title|$content|$sbCategName|$concernGrade';
  }
}

// 이슈포착
class TileSearch09ISS extends StatelessWidget {
  //const TileSearch09ISS({Key? key}) : super(key: key);
  final Search09 search09;
  final Event event;

  const TileSearch09ISS({
    Key? key,
    this.search09 = defSearch09,
    this.event = defEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: UIStyle.boxNewBasicGrey10(),
      padding: const EdgeInsets.all(
        20,
      ),
      child: InkWell(
        highlightColor: Colors.transparent,
        onTap: () {
          basePageState.callPageRouteUpData(
            IssueViewer(),
            PgData(userId: '', pgSn: event.newsSn),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _setTopView(
              search09,
              event,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${event.keyword}',
                  maxLines: 1,
                  style: TStyle.purpleThin15Style(),
                ),
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TStyle.newBasicStrongGreyS15,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 수급포착
class TileSearch09SND extends StatelessWidget {
  final Search09 search09;
  final Event event;

  const TileSearch09SND({
    Key? key,
    this.search09 = defSearch09,
    this.event = defEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: UIStyle.boxNewBasicGrey10(),
      padding: const EdgeInsets.all(
        20,
      ),
      child: InkWell(
        highlightColor: Colors.transparent,
        onTap: () {
          basePageState.callPageRouteNews(
            const NewsViewer(),
            PgNews(
              stockCode: AppGlobal().stkCode,
              stockName: AppGlobal().stkName,
              createDate: search09.issueDate,
              newsSn: event.newsSn,
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _setTopView(
              search09,
              event,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Html(
                  data: event.content,
                  style: {
                    "html": Style(
                      fontSize: FontSize(15),
                      textAlign: TextAlign.start,
                      // padding: EdgeInsets.zero,
                      maxLines: 1,
                      margin: Margins.zero,
                      textOverflow: TextOverflow.ellipsis,
                      color: RColor.new_basic_text_color_strong_grey,
                      //lineHeight: LineHeight(1),
                    ),
                    "body": Style(
                      margin: Margins.zero,
                      // padding: EdgeInsets.only(
                      //   top: 2,
                      //   bottom: 2,
                      // ),
                    ),
                  },
                ),
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TStyle.newBasicStrongGreyS15,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 실적발표
class TileSearch09SCR extends StatelessWidget {
  final Search09 search09;
  final Event event;

  const TileSearch09SCR({
    Key? key,
    this.search09 = defSearch09,
    this.event = defEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: UIStyle.boxNewBasicGrey10(),
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 10,
      ),
      child: InkWell(
        highlightColor: Colors.transparent,
        onTap: () {
          basePageState.callPageRouteNews(
            const NewsViewer(),
            PgNews(
              stockCode: AppGlobal().stkCode,
              stockName: AppGlobal().stkName,
              newsSn: event.newsSn,
              createDate: search09.issueDate,
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _setTopView(
              search09,
              event,
            ),
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TStyle.newBasicStrongGreyS15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 소셜분석
class TileSearch09SNS extends StatelessWidget {
  //const TileSearch09ISS({Key? key}) : super(key: key);
  final Stock stock;
  final Search09 search09;
  final Event event;

  TileSearch09SNS({
    Key? key,
    Stock? stock,
    Search09? search09,
    Event? event,
  })  : stock = stock ?? Stock(stockCode: '', stockName: ''),
        search09 = search09 ?? defSearch09,
        event = event ?? defEvent,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: UIStyle.boxNewBasicGrey10(),
      padding: const EdgeInsets.all(
        20,
      ),
      child: InkWell(
        highlightColor: Colors.transparent,
        onTap: () {
          // 종목 최근 소셜지수 페이지
          basePageState.callPageRouteData(
            RecentSocialListPage(),
            PgData(
              stockName: stock.stockName,
              stockCode: stock.stockCode,
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _setTopView(
              search09,
              event,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.concernGrade == '1'
                      ? '#조용조용'
                      : event.concernGrade == '2'
                          ? '#수군수군'
                          : event.concernGrade == '3'
                              ? '#왁자지껄'
                              : event.concernGrade == '4'
                                  ? '#폭발'
                                  : '#조용조용',
                  maxLines: 1,
                  style: TStyle.purpleThin15Style(),
                ),
                (event.concernGrade == '3' || event.concernGrade == '4') && (TStyle.getTodayString() == search09.issueDate)
                    ? const Text(
                        '현재 커뮤니티 참여도가 매우 높습니다.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TStyle.newBasicStrongGreyS15,
                      )
                    : Html(
                        data: event.title,
                        style: {
                          "html": Style(
                              fontSize: FontSize(15),
                              textAlign: TextAlign.start,
                              // padding: EdgeInsets.zero,
                              maxLines: 1,
                              // margin: Margins.zero,
                              textOverflow: TextOverflow.ellipsis,
                              color: RColor.new_basic_text_color_strong_grey
                              //lineHeight: LineHeight(1),
                              ),
                          "body": Style(
                              // margin: Margins.zero,
                              // padding: EdgeInsets.only(
                              //   top: 2,
                              //   bottom: 2,
                              // ),
                              ),
                        },
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 공시발생
class TileSearch09DSC extends StatelessWidget {
  final Search09 search09;
  final Event event;

  const TileSearch09DSC({
    Key? key,
    this.search09 = defSearch09,
    this.event = defEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: UIStyle.boxNewBasicGrey10(),
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 10,
      ),
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _setTopView(
              search09,
              event,
            ),
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TStyle.newBasicStrongGreyS15,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          basePageState.callPageRouteUpData(
            const DisclosDetailPage(),
            PgData(
              stockCode: AppGlobal().stkCode,
              pgData: event.newsSn,
            ),
          );
        },
      ),
    );
  }
}

Widget _setTopView(Search09 search09, Event? event) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Flexible(
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Visibility(
              visible: search09?.issueDate == TStyle.getTodayString(),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: RColor.sigBuy,
                ),
                margin: const EdgeInsets.only(
                  right: 4,
                ),
                padding: const EdgeInsets.all(5),
                child: const Text(
                  '오늘',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Text(
              TStyle.getDateSlashFormat3(search09.issueDate),
              style: TStyle.commonTitle,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              '${TStyle.getMoneyPoint(search09.tradePrice)} ${TStyle.getPercentString(search09.fluctuationRate)}',
            ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.only(
          left: 5,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 1,
        ),
        decoration: BoxDecoration(
          //color: Colors.white,
          border: Border.all(
            width: 1.2,
            color: Colors.black,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(
              5,
            ),
          ),
        ),
        child: Text(event?.newsDiv == 'ISS'
            ? '이슈포착'
            : event?.newsDiv == 'SND'
                ? '수급포착'
                : event?.newsDiv == 'SCR'
                    ? '실적발표'
                    : event?.newsDiv == 'SNS'
                        ? '소셜분석'
                        : event?.newsDiv == 'DSC'
                            ? '공시발생'
                            : ''),
      ),
    ],
  );
}
