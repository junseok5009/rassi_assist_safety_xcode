import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/pg_news.dart';
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

/// [홈_홈 라씨데스크/땡정보] - 2023.09.013 HJS
class HomeTileDdinfo extends StatelessWidget {
  final Today05 today05;

  HomeTileDdinfo(this.today05, {Key? key}) : super(key: key);
  final SwiperController _swiperController = SwiperController();

  @override
  Widget build(BuildContext context) {
    if (today05 != null && today05.listRassiroNewsDdInfo.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        today05.listRassiroNewsDdInfo.asMap().forEach((key, value) {
          if (value.representYn == 'Y') {
            _swiperController.move(
              key,
              animation: true,
            );
          }
        });
      });
    }
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
                style: TStyle.commonTitle,
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
                    fontSize: 12,
                    color: Color(0xff999999),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15.0,
          ),
          if (today05 == null)
            const SizedBox(
              height: 100,
            )
          else if (today05.isEmpty())
            CommonView.setNoDataTextView(150, '오늘의 라씨데스크가 없습니다.')
          else
            _dataView(),
        ],
      ),
    );
  }

  Widget _dataView() {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Swiper(
        scrollDirection: Axis.horizontal,
        controller: _swiperController,
        loop: false,
        scale: 0.8,
        //viewportFraction: 0.8,
        itemCount: today05.listRassiroNewsDdInfo.length,
        itemBuilder: (context, index) => _itemView(
          context,
          index,
        ),
        onIndexChanged: (value) {},
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
          CommonPopup().showDialogMsg(context, '정보 발생 전 입니다.');
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
            basePageState.callPageRoute(const RassiDeskPage());
          } else if (item.contentDiv == 'SCH'){
            basePageState.callPageRoute(const SearchPage());
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: UIStyle.boxRoundFullColor16c(
          const Color(0xffF7F7F8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            index == 0 || index == today05.listRassiroNewsDdInfo.length - 1
                ? const SizedBox()
                : _setTextTime(
                    index,
                  ),
            Text(
              item.displaySubject,
              style: const TextStyle(
                //color: timeStatus.isNow ? Colors.white : Colors.black,
                color: Colors.black,
                fontSize: 14,
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
                  color: RColor.mainColor,
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
                  item.listItem.length > 2
                      ? 2
                      : item.listItem.length,
                  (index) {
                    return InkWell(
                      child: Text(
                        '#${item.listItem[index].itemName}',
                        style: const TextStyle(
                          /*color: timeStatus.isNow
                              ? RColor.orange
                              : RColor.mainColor,*/
                          color: Color(0xff6565FF),
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        if (item.contentDiv == 'ISS') {
                          // 개별 이슈 페이지로
                          basePageState.callPageRouteUpData(
                              IssueViewer(),
                              PgData(
                                  userId: '',
                                  pgSn: item.listItem[index].itemCode));
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
                            const SearchPage(),
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
      width: 58,
      margin: const EdgeInsets.only(
        bottom: 6,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 1,
      ),
      decoration: UIStyle.boxRoundFullColor25c(
        const Color(0xff6565FF),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.access_time,
            size: 13,
            color: Colors.white,
          ),
          const SizedBox(
            width: 2,
          ),
          Text(
            today05.listRassiroNewsDdInfo[timeIndex].displayTime,
            style: const TextStyle(
              //fontWeight: FontWeight.w600,
              /*color: isNow
                  ? Colors.white
                  : isOn
                      ? RColor.mainColor
                      : RColor.new_basic_text_color_grey,*/
              color: Colors.white,
              fontSize: 11,
            ),
          ),
          const SizedBox(
            width: 2,
          ),
        ],
      ),
    );
  }
}
