import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/news/news_tag_page.dart';
import 'package:rassi_assist/ui/news/news_tag_sum_page.dart';


/// 2021.03.03
/// 추천 태그 조회
class TrRassi15 {
  final String retCode;
  final String retMsg;
  final List<TagNew> listData;

  TrRassi15({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrRassi15.fromJson(Map<String, dynamic> json) {
    var list = json['retData']['list_NewsTag'] as List;
    List<TagNew> rtList = list.map((i) => TagNew.fromJson(i)).toList();

    return TrRassi15(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: rtList,
    );
  }
}


class TagNew {
  final String tagDiv;
  final String tagCode;
  final String tagName;

  TagNew({this.tagDiv = '', this.tagCode = '', this.tagName = '',});

  factory TagNew.fromJson(Map<String, dynamic> json) {
    return TagNew(
      tagDiv: json['tagDiv'] ?? '',
      tagCode: json['tagCode'] ?? '',
      tagName: json['tagName'] ?? '',
    );
  }

  @override
  String toString() {
    return '$tagName | $tagCode';
  }
}


//화면구성
class TileChipTag extends StatelessWidget {
  final TagNew item;

  const TileChipTag(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Chip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Colors.white),
        ),
        label: Text(
          '#${item.tagName}',
          style: TStyle.pupleRegularStyle(),),
        backgroundColor: RColor.bgWeakGrey,
      ),
      onTap: (){
        if(item.tagCode == 'USRTAG') {
          // 태그 시장총정리 페이지로 이동
          basePageState.callPageRouteNews(NewsTagSumPage(),
              PgNews(tagCode: item.tagCode, tagName: item.tagName));
        } else {
          basePageState.callPageRouteNews(NewsTagPage(),
              PgNews(tagCode: item.tagCode, tagName: item.tagName));
        }
      },
    );
  }
}
