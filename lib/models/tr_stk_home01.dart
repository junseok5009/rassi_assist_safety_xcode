import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/news/issue_viewer.dart';
import 'package:rassi_assist/ui/news/news_viewer.dart';


/// 2020.11.30
/// 종목홈 - 종목 정보 조회
class TrSHome01 {
  final String retCode;
  final String retMsg;
  final SHome01 retData;

  TrSHome01({this.retCode = '', this.retMsg = '', this.retData = defSHome01});

  factory TrSHome01.fromJson(Map<String, dynamic> json) {
    return TrSHome01(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: SHome01.fromJson(json['retData']),
    );
  }
}

const defSHome01 = SHome01();
class SHome01 {
  final SbCount? sbCount;      //스톡벨 갯수
  final String snsGrade;      //SNS 관심지수
  final List<LinkData>? listLink;
  final List<RassiroH>? listRas;

  const SHome01({
    this.sbCount,
    this.snsGrade = '',
    this.listLink,
    this.listRas
  });

  factory SHome01.fromJson(Map<String, dynamic> json) {
    var listLink = json['list_Link'] as List<dynamic>?;
    List<LinkData> linkList;
    listLink == null ? linkList = [] : linkList = listLink.map((i) => LinkData.fromJson(i)).toList();

    var listRas = json['list_Rassiro'] as List<dynamic>?;
    List<RassiroH> rasList;
    listRas == null ? rasList = [] : rasList = listRas.map((i) => RassiroH.fromJson(i)).toList();

    var stkBell = json['struct_SbCount'];
    if(stkBell == null) {
      stkBell = SbCount(siseCnt: '0', invtCnt: '0', infoCnt: '0');
    } else {
      stkBell = SbCount.fromJson(json['struct_SbCount']);
    }

    return SHome01(
      sbCount: stkBell,
      snsGrade: json['struct_Concern']['concernGrade'],
      listLink: linkList,
      listRas: rasList,
    );
  }
}

//종목 소식 갯수
class SbCount {
  final String siseCnt;
  final String invtCnt;
  final String infoCnt;

  SbCount({
    this.siseCnt = '', this.invtCnt = '', this.infoCnt = ''
  });

  factory SbCount.fromJson(Map<String, dynamic> json) {
    return SbCount(
      siseCnt: json['siseCount'] ?? '',
      invtCnt: json['investorCount'] ?? '',
      infoCnt: json['infoCount'] ?? '',
    );
  }
}

//연결 종목 정보
class LinkData {
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String newsSn;
  final String newsDiv;
  final String issueDate;

  LinkData({
    this.stockCode = '', this.stockName = '', this.tradeFlag = '',
    this.newsSn = '', this.newsDiv = '', this.issueDate = ''
  });

  factory LinkData.fromJson(Map<String, dynamic> json) {
    return LinkData(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      tradeFlag: json['tradeFlag'] ?? '',
      newsSn: json['newsSn'] ?? '',
      newsDiv: json['newsDiv'] ?? '',
      issueDate: json['issueDate'] ?? '',
    );
  }

  @override
  String toString() {
    return '$stockName|$stockCode|$tradeFlag';
  }
}

//AI 속보
class RassiroH {
  final String newsDiv;
  final String newsSn;
  final String newsCrtDate;
  final String issueDttm;
  final String elapsedTmTx;
  final String title;
  final String imageUrl;
  final String viewLinkYn;

  RassiroH({
    this.newsDiv = '', this.newsSn = '',
    this.newsCrtDate = '', this.issueDttm = '',
    this.elapsedTmTx = '', this.title = '',
    this.imageUrl = '', this.viewLinkYn = '',
  });

  factory RassiroH.fromJson(Map<String, dynamic> json) {
    return RassiroH(
      newsDiv: json['newsDiv'] ?? '',
      newsSn: json['newsSn'] ?? '',
      newsCrtDate: json['newsCrtDate'] ?? '',
      issueDttm: json['issueDttm'] ?? '',
      elapsedTmTx: json['elapsedTmTx'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      viewLinkYn: json['viewLinkYn'] ?? '',
    );
  }

  @override
  String toString() {
    return '$title|$newsSn|$newsDiv';
  }
}

//종목홈 - AI속보 리스트
class TileRassiroH extends StatelessWidget {
  final RassiroH item;
  const TileRassiroH(this.item, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15,),
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10,),
            Text(
              item.title,
              style: TStyle.defaultContent,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 10,),
            Text(
              TStyle.getDateSFormat(item.newsCrtDate),
              style: TStyle.textGrey14,
            ),
            const SizedBox(height: 10,),
            Container(width: double.infinity, height: 1, color: RColor.lineGrey,),
          ],
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
