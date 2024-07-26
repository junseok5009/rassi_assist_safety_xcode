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
