import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/news/news_tag_page.dart';
import 'package:rassi_assist/ui/news/news_tag_sum_page.dart';


/// 2024.07
/// 오늘의 특징주 메뉴 조회
class TrRassi18 {
  final String retCode;
  final String retMsg;
  final List<MenuDiv> listData;

  TrRassi18({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrRassi18.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] == null ? [] : (json['retData'] as List);
    List<MenuDiv> rtList = list.map((i) => MenuDiv.fromJson(i)).toList();

    return TrRassi18(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: rtList,
    );
  }
}


class MenuDiv {
  final String menuDiv;
  final String content;

  MenuDiv({this.menuDiv = '', this.content = '',});

  factory MenuDiv.fromJson(Map<String, dynamic> json) {
    return MenuDiv(
      menuDiv: json['menuDiv'] ?? '',
      content: json['content'] ?? '',
    );
  }

  @override
  String toString() {
    return '$menuDiv | $content';
  }
}
