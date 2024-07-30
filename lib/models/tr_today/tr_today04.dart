import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/market/issue_new_viewer.dart';
import 'package:rassi_assist/ui/news/issue_list_page.dart';
import 'package:rassi_assist/ui/news/news_tag_page.dart';
import 'package:rassi_assist/ui/news/news_tag_sum_page.dart';
import 'package:rassi_assist/ui/sub/rassi_desk_page.dart';
import 'package:rassi_assist/ui/sub/social_list_page.dart';

/// 2022.04.22 - JY // 22.07.21 - JS 수정
/// 지금 봐야 할 정보 (땡정보)
class TrToday04 {
  final String retCode;
  final String retMsg;
  final Today04? retData;

  TrToday04({this.retCode = '', this.retMsg = '', this.retData});

  factory TrToday04.fromJson(Map<String, dynamic> json) {
    return TrToday04(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? null : Today04.fromJson(json['retData']),
    );
  }
}

class Item {
  final String itemName;
  final String itemCode;

  Item({
    this.itemName = '',
    this.itemCode = '',
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemName: json['itemName'] ?? '',
      itemCode: json['itemCode'] ?? '',
    );
  }
}

class Today04 {
  String contentDiv = '';
  String displayTime = '';
  String displayTitle = '';
  String linkUrl = ''; // contentDiv == BRF // 금요일 오후 9시 주간 브리핑때만 있음
  List<Item> listItem = [];

  Today04({
    this.contentDiv = '',
    this.displayTime = '',
    this.displayTitle = '',
    this.linkUrl = '',
    this.listItem = const [],
  });

  Today04.empty() {
    contentDiv = '';
    displayTime = '';
    displayTitle = '';
    linkUrl = '';
    listItem = [];
  }

  bool isEmpty() {
    if (contentDiv.isEmpty && contentDiv.isEmpty && listItem.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  factory Today04.fromJson(Map<String, dynamic> json) {
    return Today04(
      contentDiv: json['contentDiv'] ?? '',
      displayTime: json['displayTime'] ?? '',
      displayTitle: json['displayTitle'] ?? '',
      linkUrl: json['linkUrl'] ?? '',
      listItem: json['list_Item'] == null ? [] : (json['list_Item'] as List).map((i) => Item.fromJson(i)).toList(),
    );
  }
}

class TileToday04 extends StatelessWidget {
  final Today04 item;

  const TileToday04(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageRoute = '';

    switch (item.contentDiv) {
      // 08:30 ~ 08:59  오늘 장 예측
      case 'MKT2':
      // 16:00 ~ 16:29  오늘 시장 마무리
      case 'MKT':
        imageRoute = 'images/rstm_today_05.png';
        break;
      // 09:00 ~ 09:29 오늘의 이슈
      case 'ISS':
        imageRoute = 'images/rstm_today_01.png';
        break;
      // 09:30 ~ 09:59 리포트
      /*case 'RPT':
        imageRoute = 'images/rstm_today_02.png';
        break; */
      // 10:00 ~ 10:29 지금 특징주
      case 'STK':
        imageRoute = 'images/rstm_today_03.png';
        break;
      // 14:00 ~ 14:29  소셜 이슈
      case 'SNS':
        imageRoute = 'images/rstm_today_04.png';
        break;
      // 17:00 ~ 17:29  주간 토픽, 격주 금요일 발생
      /*case 'TPC':
        imageRoute = 'images/rstm_today_06.png';
        break;*/
      // 21:00 ~ 21:29  주간 브리핑, 매주 금요일 발생
      /*case 'BRF':
        imageRoute = 'images/rstm_today_07.png';
        break;*/
      // 18:30 ~ 22:00  오늘 시장 브리핑
      case 'BRF2':
        imageRoute = 'images/rstm_today_08.png';
        break;
    }

    return InkWell(
      onTap: () {
        CustomFirebaseClass.logEvtDdInfo(
          time: item.displayTime,
        );
        switch (item.contentDiv) {
          case 'MKT2': // 08:30
          case 'MKT': // 16시
            basePageState.callPageRouteNews(const NewsTagSumPage(), PgNews(tagCode: '', tagName: ''));
            break;
          case 'ISS': // 9시
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const IssueListPage(),
              ),
            );
            break;
          /*case 'RPT': // 9시 30분
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportPage(),
                settings: RouteSettings(
                  arguments: PgData(
                    pgSn: '0',
                    pgData: '증권사 리포트',
                  ),
                ),
              ),
            );
            break;*/
          case 'STK': // 10시
            basePageState.callPageRouteNews(NewsTagPage(), PgNews(tagCode: 'USRTAG', tagName: '실시간특징주'));
            break;
          case 'SNS': // 14시
            Navigator.pushNamed(context, SocialListPage.routeName, arguments: PgData(pgSn: ''));
            break;
          /*  case 'TPC': // 17시
            basePageState.callPageRoute(CatchListPage());
            break;*/
          /*case 'BRF': // 21시
            Navigator.push(
              context,
              _createRouteData(
                OnlyWebView(),
                RouteSettings(
                  arguments: PgNews(linkUrl: item.linkUrl),
                ),
              ),
            );
            break;*/
          case 'BRF2': // 18시 30분
            basePageState.callPageRoute(const RassiDeskPage());
            break;
        }
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            alignment: Alignment.centerLeft,
            color: RColor.mainColor,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Align(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
                          decoration: const BoxDecoration(
                            color: RColor.deepBlue,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: Text(
                            '${item.displayTime} 라씨데스크',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Color(0xffFFFFFF),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            top: 4,
                            bottom: 4,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.displayTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              color: Color(0xffFFFFFF),
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 10.0,
                          alignment: WrapAlignment.start,
                          children: List.generate(
                            item.listItem.length,
                            (index) => InkWell(
                              onTap: () {
                                if (item.contentDiv == 'ISS') {
                                  // 개별 이슈 페이지로
                                  Navigator.pushNamed(
                                    context,
                                    IssueNewViewer.routeName,
                                    arguments: PgData(
                                      pgSn: item.listItem[index].itemCode,
                                      data: item.listItem[index].itemName,
                                    ),
                                  );
                                }
                                /*else if (item.contentDiv == 'RPT') {
                                  // 증권사 리포트로
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReportPage(),
                                      settings: RouteSettings(
                                        arguments: PgData(
                                          pgSn: '0',
                                          pgData: '증권사 리포트',
                                        ),
                                      ),
                                    ),
                                  );
                                } */ /*else if (item.contentDiv == 'BRF') {
                                  // 웹뷰로 띄우기
                                } */
                                else {
                                  // 종목홈으로
                                  basePageState.goStockHomePage(
                                    item.listItem[index].itemCode,
                                    item.listItem[index].itemName,
                                    Const.STK_INDEX_SIGNAL,
                                  );
                                }
                              },
                              child: Text(
                                '#${item.listItem[index].itemName}  ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: RColor.orange,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    right: 10,
                    left: 10,
                  ),
                  height: 76,
                  child: Image.asset(
                    imageRoute,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
