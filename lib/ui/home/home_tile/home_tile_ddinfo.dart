import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi17.dart';
import 'package:rassi_assist/models/tr_today/tr_today05.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/main/search_page.dart';
import 'package:rassi_assist/ui/news/issue_list_page.dart';
import 'package:rassi_assist/ui/news/issue_viewer.dart';
import 'package:rassi_assist/ui/news/news_tag_page.dart';
import 'package:rassi_assist/ui/news/news_tag_sum_page.dart';
import 'package:rassi_assist/ui/sub/rassi_desk_page.dart';
import 'package:rassi_assist/ui/sub/rassi_desk_time_line_page.dart';
import 'package:rassi_assist/ui/sub/social_list_page.dart';

import '../../common/common_popup.dart';

/// [홈_홈 라씨데스크/땡정보] - 2023.09.13 HJS
class HomeTileDdinfo extends StatelessWidget {
  HomeTileDdinfo({required this.today05, Key? key}) : super(key: key);
  final Today05 today05;
  final SwiperController _swiperController = SwiperController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '라씨데스크',
                style: TStyle.defaultTitle,
              ),

              InkWell(
                onTap: () async {
                  basePageState.callPageRoute(const RassiDeskTimeLinePage());
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
            height: 20.0,
          ),
          if (today05.isEmpty())
          CommonView.setNoDataTextView(150, '오늘의 라씨데스크가 없습니다.')
        else
          _dataView(),
        ],
      ),
    );
  }

  Widget _dataView() {
    int swipeInitIndex = 0;
    if (today05.listRassiroNewsDdInfo.isNotEmpty) {
      today05.listRassiroNewsDdInfo.asMap().forEach((key, value) {
        if (value.representYn == 'Y') {
          swipeInitIndex = key;
        }
      });
    }
    return SizedBox(
      width: double.infinity,
      height: 101,
      child: Swiper(
        scrollDirection: Axis.horizontal,
        controller: _swiperController,
        loop: false,
        scale: 0.8,
        index: swipeInitIndex,
        itemCount: today05.listRassiroNewsDdInfo.length,
        itemBuilder: (context, index) => _itemView(
          context,
          index,
        ),
      ),
    );
  }

  Widget _itemView(
    BuildContext context,
    int index,
  ) {
    var item = today05.listRassiroNewsDdInfo[index];
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        if (item.displayYn == 'N') {
          CommonPopup.instance.showDialogTitleMsg(
              context, '알림', '발생 전 입니다.\n정보 발생 시간에 확인해 주세요.');
        } else {
          if (item.contentDiv == 'MKT2' || item.contentDiv == 'MKT') {
            basePageState.callPageRouteNews(
                NewsTagSumPage(), PgNews(tagCode: '', tagName: ''));
          } else if (item.contentDiv == 'ISS') {
            basePageState.callPageRoute(const IssueListPage());
          } else if (item.contentDiv == 'STK') {
            basePageState.callPageRouteNews(
                NewsTagPage(), PgNews(tagCode: 'USRTAG', tagName: '실시간특징주'));
          } else if (item.contentDiv == 'SNS') {
            Navigator.pushNamed(context, SocialListPage.routeName,
                arguments: PgData(pgSn: ''));
          } else if (item.contentDiv == 'BRF2') {
            if (!context.mounted) return;
            _fetchPosts(
              context,
              TR.RASSI17,
              jsonEncode(
                <String, String>{
                  "userId": AppGlobal().userId,
                  "menuDiv": "5",
                },
              ),
            );
          } else if (item.contentDiv == 'SCH' || item.contentDiv == 'SCH2') {
            basePageState.callPageRouteUP(
              const SearchPage(landWhere: SearchPage.goStockHome, pocketSn: '',),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: UIStyle.boxRoundFullColor16c(
          RColor.greyBox_f5f5f5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _setTextTime(
              index,
            ),
            Text(
              item.displaySubject,
              style: TextStyle(
                color: item.displayYn == 'Y'
                    ? Colors.black
                    : RColor.greyBasic_8c8c8c,
                fontSize: 15,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            if (item.displayYn == 'N')
              const Text(
                '종목분석중',
                style: TextStyle(
                  fontSize: 13,
                  color: RColor.greyBasic_8c8c8c,
                ),
              )
            else if (item.listItem.isEmpty)
              item.contentDiv == 'SNS'
                  ? Text(
                      '소셜 폭발 종목 확인하기',
                      style: TextStyle(
                        color: item.representYn == 'Y'
                            ? RColor.orange
                            : RColor.mainColor,
                        fontSize: 13,
                      ),
                    )
                  : const SizedBox()
            else
              Wrap(
                spacing: 10.0,
                alignment: WrapAlignment.center,
                children: List.generate(
                  item.listItem.length > 2 ? 2 : item.listItem.length,
                  (index) {
                    return InkWell(
                      child: Text(
                        '#${item.listItem[index].itemName}',
                        style: const TextStyle(
                          color: RColor.purpleBasic_6565ff,
                          fontSize: 13,
                        ),
                      ),
                      onTap: () {
                        if (item.contentDiv == 'ISS') {
                          // 개별 이슈 페이지로
                          basePageState.callPageRouteUpData(
                            const IssueViewer(),
                            PgData(
                                userId: '',
                                pgSn: item.listItem[index].itemCode),
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
                        else if (item.contentDiv == 'SCH') {
                          basePageState.callPageRouteUP(
                            const SearchPage(landWhere: SearchPage.goStockHome, pocketSn: '',),
                          );
                        } else {
                          // 종목홈으로
                          basePageState.goStockHomePage(
                            item.listItem[index].itemCode,
                            item.listItem[index].itemName,
                            Const.STK_INDEX_HOME,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _setTextTime(
    int timeIndex,
  ) {
    return Container(
      height: 20,
      margin: const EdgeInsets.only(
        bottom: 6,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      decoration: UIStyle.boxRoundFullColor25c(
        today05.listRassiroNewsDdInfo[timeIndex].displayYn == 'Y'
            ? RColor.purpleBasic_6565ff
            : RColor.greyTitle_cdcdcd,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Visibility(
              visible: timeIndex != 0 &&
                  timeIndex != today05.listRassiroNewsDdInfo.length - 1,
              child: Row(
                children: const [
                  Icon(
                    Icons.access_time,
                    size: 13,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 2,
                  ),
                ],
              ),
            ),
            Text(
              timeIndex == 0 ||
                      timeIndex == today05.listRassiroNewsDdInfo.length - 1
                  ? '시간 외 정보'
                  : today05.listRassiroNewsDdInfo[timeIndex].displayTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fetchPosts(BuildContext context, String trStr, String json) async {
    try {
      var url = Uri.parse(Net.TR_BASE + trStr);
      final http.Response response = await http.post(
        url,
        body: json,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));
      //if (context.mounted) return;
      if (context.mounted) {
        _parseTrData(context, trStr, response);
      }
    } on Exception catch (_) {}
  }

  void _parseTrData(
      BuildContext context, String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    if (trStr == TR.RASSI17) {
      final TrRassi17 resData = TrRassi17.fromJson(jsonDecode(response.body));
      final Rassi17 rassi17 = resData.retData;
      if (resData.retCode == RT.SUCCESS) {
        if (rassi17.stockList.isNotEmpty) {
          basePageState.callPageRoute(const RassiDeskPage());
        } else {
          CommonPopup.instance
              .showDialogTitleMsg(context, '알림', '데이터 업데이트 중입니다.');
        }
      } else {
        CommonPopup.instance
            .showDialogTitleMsg(context, '알림', '데이터 업데이트 중입니다.');
      }
    }
  }
}
