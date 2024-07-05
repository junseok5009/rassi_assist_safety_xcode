import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/models/tag_info.dart';
import 'package:rassi_assist/ui/news/news_tag_page.dart';
import 'package:rassi_assist/ui/news/news_viewer.dart';
import 'package:rassi_assist/ui/web/only_web_view.dart';

import '../common/custom_nv_route_class.dart';

/// 라씨로 뉴스
class Rassiro {
  final String newsDiv;
  final String newsSn;
  final String newsCrtDate;
  final String issueDttm;
  final String title;
  final String viewLinkYn;
  final String stockCode;
  final String stockName;
  final String imageUrl;

  // TR_RASSIRO06 땡정보 + 실시간 특징주 추가
  final String linkUrl; // TR_RASSIRO06 땡정보 (태그별 AI속보 리스트 > 실시간 특징주) : 랜딩페이지 링크 주소
  final String currentPrice; // 관련 종목 현재 가격
  final String fluctuationRate; // 관련 종목 등락

  Rassiro({
    this.newsDiv = '',
    this.newsSn = '',
    this.newsCrtDate = '',
    this.issueDttm = '',
    this.title = '',
    this.viewLinkYn = '',
    this.stockCode = '',
    this.stockName = '',
    this.imageUrl = '',
    this.linkUrl = '',
    this.currentPrice = '',
    this.fluctuationRate = '',
  });

  bool isEmpty() {
    return [
      title,
      newsCrtDate,
      newsSn,
    ].contains(null);
  }

  factory Rassiro.fromJson(Map<String, dynamic> json) {
    return Rassiro(
      newsDiv: json['newsDiv'] ?? '',
      newsSn: json['newsSn'] ?? '',
      newsCrtDate: json['newsCrtDate'] ?? '',
      issueDttm: json['issueDttm'] ?? '',
      title: json['title'] ?? '',
      viewLinkYn: json['viewLinkYn'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      linkUrl: json['linkUrl'] ?? '',
      currentPrice: json['currentPrice'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
    );
  }
}

//화면구성 (라씨로 뉴스 리스트)
class TileRassiroList extends StatelessWidget {
  final Rassiro item;

  const TileRassiroList(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // height: 80,
      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
      alignment: Alignment.centerLeft,
      // decoration: UIStyle.boxRoundLine6bgColor(Colors.white),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TStyle.getDateTdFormat(item.issueDttm),
                      style: TStyle.purpleThinStyle(),
                    ),
                    const SizedBox(
                      height: 4
                    ),
                    Text(
                      item.title,
                      style: TStyle.content16,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      color: Colors.black12,
                      height: 1.2,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        onTap: () async {
          // NewsViewer로 이동 > NewsViewer 페이지에서 관련태그 클릭하면 다시 NewsTagPage 이거 하나 더 떠서 중복으로 계속 스택 쌓임,
          // NewsViewer _ 관련태그인 Tr_Rassi03 _ TileTags에서 클릭하면 NewsViewer 닫고 이 함수 호출해서 중복으로 안뜨고 갱신되게 함
          dynamic result = await Navigator.push(
            context,
            CustomNvRouteClass.createRouteData(
              const NewsViewer(),
              RouteSettings(
                arguments: PgNews(
                  stockCode: item.stockCode,
                  stockName: item.stockName,
                  newsSn: item.newsSn,
                  createDate: item.newsCrtDate,
                ),
              ),
            ),
          );
          if (context.mounted) {
            if (result is Tag) {
              NewsTagPageState? parent = context.findAncestorStateOfType<NewsTagPageState>();
              Tag item = result;
              parent?.tagName = item.tagName;
              parent?.tagCode = item.tagCode;
              parent?.pageNum = 0;
              parent?.newsList.clear();
              parent?.requestData();
            } else if (result == true) {
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }
}

//화면구성 (라씨로 뉴스 리스트) 22.07.13 실시간특징주 추가
class TileRassiroFeatureList extends StatelessWidget {
  final Rassiro item;

  const TileRassiroFeatureList(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 84,
      margin: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 10.0,
      ),
      alignment: Alignment.centerLeft,
      decoration: UIStyle.boxRoundLine6bgColor(
        Colors.white,
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: double.infinity,
          height: 84,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TStyle.getDateTdFormat(item.issueDttm),
                      style: TStyle.commonSPurple,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TStyle.subTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Visibility(
                          visible: int.parse(DateTime.now()
                                  .difference(DateTime.parse(item.issueDttm.substring(0, 8)))
                                  .inDays
                                  .toString()) ==
                              0,
                          child: Image.asset(
                            'images/main_icon_new_red_small.png',
                            height: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    _setRelayInfo(context, item),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            CustomNvRouteClass.createRoute(
              OnlyWebViewPage(title: '', url: item.linkUrl),
            ),
          );
        },
      ),
    );
  }

  Widget _setRelayInfo(BuildContext context, Rassiro rassiro) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(2, 1, 2, 1),
          color: RColor.bgWeakGrey,
          child: Text(
            TStyle.getLimitString(rassiro.stockName, 8),
            style: TStyle.purpleThinStyle(),
          ),
        ),
        const SizedBox(
          width: 6,
        ),
        Visibility(
          visible: rassiro.currentPrice.isNotEmpty,
          child: Text(
            TStyle.getMoneyPoint(rassiro.currentPrice),
            style: TStyle.purpleThinStyle(),
          ),
        ),
        const SizedBox(
          width: 6,
        ),
        Visibility(
          visible: rassiro.currentPrice.isNotEmpty && rassiro.fluctuationRate.isNotEmpty,
          child: Text(
            TStyle.getPercentString(rassiro.fluctuationRate),
            style: TStyle.purpleThinStyle(),
          ),
        ),
      ],
    );
  }
}
