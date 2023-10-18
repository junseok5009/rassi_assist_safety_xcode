import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/news/news_viewer.dart';

///
/// 라씨로 속보 리스트 조회
class TrRassi05 {
  final String retCode;
  final String retMsg;
  final List<Rassi05>? retData;

  TrRassi05({this.retCode = '', this.retMsg = '', this.retData});

  factory TrRassi05.fromJson(Map<String, dynamic> json) {
    var list = json['retData']['list_Rassiro'] as List;
    List<Rassi05> rtList = list.map((i) => Rassi05.fromJson(i)).toList();
    print(list.length);

    return TrRassi05(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: rtList,
    );
  }
}

class Rassi05 {
  final String newsDiv;
  final String newsSn;
  final String newsCrtDate;
  final String issueDttm;
  final String elapsedTmTx;
  final String title;
  final String imageUrl;
  final String viewLinkYn;

  Rassi05({
    this.newsDiv = '',
    this.newsSn = '',
    this.newsCrtDate = '',
    this.issueDttm = '',
    this.elapsedTmTx = '',
    this.title = '',
    this.imageUrl = '',
    this.viewLinkYn = ''
  });

  factory Rassi05.fromJson(Map<String, dynamic> json) {
    return Rassi05(
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

  @override
  String toString() {
    return '$newsSn|$elapsedTmTx|$title|';
  }
}

//화면구성
class TileRassi05 extends StatelessWidget {
  final Rassi05 item;

  TileRassi05(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 72,
      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0,),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border.all(color: RColor.lineGrey, width: 0.8,),
        borderRadius: const BorderRadius.all(Radius.circular(14.0)),
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: double.infinity,
          height: 72,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.elapsedTmTx, style: TStyle.textSGreen,),
              const SizedBox(height: 2,),
              Text(item.title, style: TStyle.contentSBLK,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,),
            ],
          ),
        ),
        onTap: (){
          basePageState.callPageRouteNews(NewsViewer(),
              PgNews(
                stockCode: '',
                stockName: '',
                newsSn: item.newsSn,
                createDate: item.newsCrtDate,),);
        },
      ),
    );
  }
}

