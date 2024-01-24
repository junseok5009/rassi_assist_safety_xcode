import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/sub/keyword_viewer.dart';


/// 2021.04.05
class TrKWord01 {
  final String retCode;
  final String retMsg;
  final KWord01 retData;

  TrKWord01({this.retCode = '', this.retMsg = '', this.retData = defKWord01});

  factory TrKWord01.fromJson(Map<String, dynamic> json) {
    return TrKWord01(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null ? defKWord01 : KWord01.fromJson(json['retData'])
    );
  }
}

const defKWord01 = KWord01();

class KWord01 {
  final String stockCode;
  final String stockName;
  final List<KeywordData> listNew;
  final List<KeywordData> listOld;

  const KWord01({
    this.stockCode = '',
    this.stockName = '',
    this.listNew = const [],
    this.listOld = const []
  });

  factory KWord01.fromJson(Map<String, dynamic> json) {
    var listN = json['list_NewKeyword'] as List;
    List<KeywordData> listNew = listN != null
        ? listN.map((e) => KeywordData.fromJson(e)).toList()
        : <KeywordData>[];

    var listO = json['list_OldKeyword'] as List;
    List<KeywordData> listOld = listO != null
        ? listO.map((e) => KeywordData.fromJson(e)).toList()
        : <KeywordData>[];

    return KWord01(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      listNew: listNew,
      listOld: listOld,
    );
  }
}


class KeywordData {
  final String issueDate;
  final String keyword;

  KeywordData({this.issueDate = '', this.keyword = '',});

  factory KeywordData.fromJson(Map<String, dynamic> json) {
    return KeywordData(
      issueDate: json['issueDate'],
      keyword: json['keyword'],
    );
  }

  @override
  String toString() {
    return '$issueDate|$keyword|';
  }
}


//화면구성
class ChipKeyword extends StatelessWidget {
  final KeywordData item;
  final Color bColor;

  const ChipKeyword(this.item, this.bColor, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Chip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Colors.white),
        ),
        label: Text(item.keyword, style: TStyle.puplePlainStyle(),),
        backgroundColor: RColor.bgWeakGrey,
      ),
      onTap: (){
        basePageState.callPageRouteUpData(const KeywordViewer(),
            PgData(userId: '', pgSn: '', pgData: item.keyword));
      },
    );
  }
}
