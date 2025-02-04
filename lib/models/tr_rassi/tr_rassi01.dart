import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/models/rassiro.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/news/news_viewer.dart';

import '../../common/custom_nv_route_class.dart';

/// 2020.09.07
/// 라씨로 일반 뉴스 리스트
class TrRassi01 {
  final String retCode;
  final String retMsg;
  final List<Rassiro> listData;

  TrRassi01({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrRassi01.fromJson(Map<String, dynamic> json) {
    var jsonList = json['retData']['list_Rassiro'];
    return TrRassi01(
      retCode: json['retCode'] ?? '',
      retMsg: json['retMsg'] ?? '',
      listData: jsonList == null ? [] : (jsonList as List).map((i) => Rassiro.fromJson(i)).toList(),
    );
  }
}

//화면구성 (마켓뷰)
class TileRassi01 extends StatelessWidget {
  final Rassiro item;
  final bool visibleDividerLine;

  const TileRassi01({required this.item, required this.visibleDividerLine, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(
        top: 12,
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: double.infinity,
          //padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TStyle.defaultContent,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 3),
              Text(
                TStyle.getDtTimeFormat(item.issueDttm),
                style: const TextStyle(
                  color: RColor.greyMore_999999,
                ),
              ),
              Container(
                color: Colors.black12,
                height: visibleDividerLine ? 1.2 : 0,
                margin: const EdgeInsets.only(
                  top: 12,
                ),
              )
            ],
          ),
        ),
        onTap: () {
          basePageState.callPageRouteNews(
            const NewsViewer(),
            PgNews(
              stockCode: '',
              stockName: '',
              newsSn: item.newsSn,
              createDate: item.newsCrtDate,
            ),
          );
        },
      ),
    );
  }
}

class TileRassi01ListItemView extends StatelessWidget {
  //const TileRassi01ListItemView({super.key});
  TileRassi01ListItemView(this.item, {Key? key}) : super(key: key);
  final Rassiro item;

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
                  const NewsViewer(),
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
