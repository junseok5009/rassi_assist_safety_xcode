import 'package:flutter/material.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/news/news_viewer.dart';

import '../../common/const.dart';
import '../../common/custom_nv_route_class.dart';


/// 2020.09.07
/// 라씨로 종목뉴스 리스트
class TrRassi02 {
  final String retCode;
  final String retMsg;
  final List<Rassi02> listData;

  TrRassi02({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrRassi02.fromJson(Map<String, dynamic> json) {
    var list = json['retData']['list_Rassiro'] as List;
    List<Rassi02>? rtList;
    list == null
        ? rtList = null
        : rtList = list.map((i) => Rassi02.fromJson(i)).toList();

    return TrRassi02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: list.map((i) => Rassi02.fromJson(i)).toList(),
    );
  }
}

class Rassi02 {
  final String newsDiv;
  final String newsSn;
  final String newsCrtDate;
  final String issueDttm;
  final String elapsedTmTx;
  final String title;
  final String imageUrl;
  final String viewLinkYn;

  Rassi02({
    this.newsDiv = '',
      this.newsSn = '',
      this.newsCrtDate = '',
      this.issueDttm = '',
      this.elapsedTmTx = '',
      this.title = '',
      this.imageUrl = '',
      this.viewLinkYn = ''
  });

  bool isEmpty() {
    return [
      title,
      newsCrtDate,
      newsSn,
    ].contains(null);
  }

  factory Rassi02.fromJson(Map<String, dynamic> json) {
    return Rassi02(
      newsDiv: json['newsDiv'],
      newsSn: json['newsSn'],
      newsCrtDate: json['newsCrtDate'],
      issueDttm: json['issueDttm'],
      elapsedTmTx: json['elapsedTmTx'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      viewLinkYn: json['viewLinkYn'],
    );
  }
}

//화면구성 (라씨로 뉴스 리스트)
class TileRassi02 extends StatelessWidget {
  final Rassi02 item;

  TileRassi02(this.item);

  @override
  Widget build(BuildContext context) {
    return item.isEmpty()
        ? Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.center,
            child: Image.asset(
              'images/gif_ios_loading_large.gif',
              height: 20,
            ),
          )
        : Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: InkWell(
              splashColor: Colors.deepPurpleAccent.withAlpha(30),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                  left: 15.0,
                  right: 15.0,
                  top: 12.0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: UIStyle.boxRoundLine15(),
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
                    Text(
                      item.title,
                      style: TStyle.subTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              onTap: () {
                basePageState.callPageRouteNews(
                    NewsViewer(),
                    PgNews(
                      stockCode: '',
                      stockName: '',
                      newsSn: item.newsSn,
                      createDate: item.newsCrtDate,
                    ));
              },
            ),
          );
  }

  Widget _setNetImage(String sUrl) {
    if (sUrl == null) {
      return Visibility(visible: false, child: Text(''));
    } else {
      return Image.network(
        sUrl,
        width: 45,
      );
    }
  }
}

class TileRassi02ListItemView extends StatelessWidget {
  const TileRassi02ListItemView(this.item);

  final Rassi02 item;

  @override
  Widget build(BuildContext context) {
    return item.isEmpty()
        ? Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.center,
            child: Image.asset(
              'images/gif_ios_loading_large.gif',
              height: 20,
            ),
          )
        : InkWell(
            splashColor: Colors.deepPurpleAccent.withAlpha(30),
            highlightColor: Colors.transparent,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    width: 1.0,
                    color: RColor.btnUnSelectGreyStroke,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TStyle.content15,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    TStyle.getDateTimeFormat(item.issueDttm),
                    style: TStyle.newBasicGreyS15,
                  ),
                ],
              ),
            ),
            onTap: () async {
              dynamic result = await Navigator.push(
                context,
                CustomNvRouteClass.createRouteData(
                  NewsViewer(),
                  RouteSettings(
                    arguments: PgNews(
                      stockCode: '',
                      stockName: '',
                      newsSn: item.newsSn,
                      createDate: item.newsCrtDate,
                    ),
                  ),
                ),
              );
              if (context.mounted && result == true) {
                Navigator.pop(context);
              }
            },
          );
  }
}
