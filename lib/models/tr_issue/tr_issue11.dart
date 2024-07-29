import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/market/issue_new_viewer.dart';

/// 2024.07
/// 이슈 통계 데이터 조회 (이슈 인사이트)
class TrIssue11 {
  final String retCode;
  final String retMsg;
  final Issue11 retData;

  TrIssue11({
    this.retCode = '',
    this.retMsg = '',
    this.retData = defIssue11,
  });

  factory TrIssue11.fromJson(Map<String, dynamic> json) {
    return TrIssue11(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defIssue11 : Issue11.fromJson(json['retData']),
    );
  }
}

const defIssue11 = Issue11();

class Issue11 {
  final String menuDiv;
  final String content1;

  // [OCCUR]
  final List<IssueGenMonth> listGenMonth;

  // [TREND]
  final String title1;
  final String title2;
  final String content2;
  final String upMaxDate;
  final String dnMaxDate;
  final List<IssueTrendCount> listIssueCount;
  final List<KospiIndex> listKospiIndex;
  final List<KosdaqIndex> listKosdaqIndex;

  // [UPDAY]
  final String totalPageSize;
  final String totalItemSize;
  final String currentPageNo;
  final List<IssueTopDay> listDayTop;

  const Issue11({
    this.menuDiv = '',
    this.content1 = '',
    this.listGenMonth = const [],

    this.title1 = '',
    this.title2 = '',
    this.content2 = '',
    this.upMaxDate = '',
    this.dnMaxDate = '',
    this.listIssueCount = const [],
    this.listKospiIndex = const [],
    this.listKosdaqIndex = const [],

    this.totalPageSize = '',
    this.totalItemSize = '',
    this.currentPageNo = '',
    this.listDayTop = const [],
  });

  factory Issue11.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Issue'];
    var jsonKospi = json['list_Kospi'];
    var jsonKosdaq = json['list_Kosdaq'];
    return Issue11(
      menuDiv: json['menuDiv'] ?? '',
      content1: json['content1'] ?? '',
      title1: json['title1'] ?? '',
      title2: json['title2'] ?? '',
      content2: json['content2'] ?? '',
      upMaxDate: json['upMaxDate'] ?? '',
      dnMaxDate: json['dnMaxDate'] ?? '',
      totalPageSize: json['totalPageSize'] ?? '',
      totalItemSize: json['totalItemSize'] ?? '',
      currentPageNo: json['currentPageNo'] ?? '',
      listGenMonth: jsonList == null ? [] : (jsonList as List).map((i) => IssueGenMonth.fromJson(i)).toList(),
      listIssueCount: jsonList == null ? [] : (jsonList as List).map((i) => IssueTrendCount.fromJson(i)).toList(),
      listKospiIndex: jsonKospi == null ? [] : (jsonKospi as List).map((i) => KospiIndex.fromJson(i)).toList(),
      listKosdaqIndex: jsonKosdaq == null ? [] : (jsonKosdaq as List).map((i) => KosdaqIndex.fromJson(i)).toList(),
      listDayTop: jsonList == null ? [] : (jsonList as List).map((i) => IssueTopDay.fromJson(i)).toList(),
    );
  }
}

// 한달 많이 발생한 이슈 [OCCUR]
class IssueGenMonth {
  final String issueSn;
  final String keyword;
  final String occurCount;

  IssueGenMonth({this.issueSn = '', this.keyword = '', this.occurCount = ''});

  factory IssueGenMonth.fromJson(Map<String, dynamic> json) {
    return IssueGenMonth(
      issueSn: json['issueSn'] ?? '',
      keyword: json['keyword'] ?? '',
      occurCount: json['occurCount'] ?? '',
    );
  }
}

//  [TREND]
class IssueTrendCount {
  final String issueDate;
  final String upCount;
  final String downCount;
  final String occurCount;

  IssueTrendCount({
    this.issueDate = '',
    this.upCount = '0',
    this.downCount = '0',
    this.occurCount = '0',
  });

  factory IssueTrendCount.fromJson(Map<String, dynamic> json) {
    return IssueTrendCount(
      issueDate: json['issueDate'] ?? '',
      upCount: json['upCount'] ?? '0',
      downCount: json['downCount'] ?? '0',
      occurCount: json['occurCount'] ?? '0',
    );
  }

  @override
  String toString() {
    return '$issueDate | $upCount | $downCount | $occurCount';
  }
}

//  [TREND - kospi]
class KospiIndex {
  final String priceIndex;
  final String indexFluctuation;
  final String fluctuationRate;
  final String tradeDate;

  KospiIndex({
    this.priceIndex = '',
    this.indexFluctuation = '',
    this.fluctuationRate = '',
    this.tradeDate = '',
  });

  factory KospiIndex.fromJson(Map<String, dynamic> json) {
    return KospiIndex(
      priceIndex: json['priceIndex'] ?? '',
      indexFluctuation: json['indexFluctuation'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
      tradeDate: json['tradeDate'] ?? '',
    );
  }

  @override
  String toString() {
    return '$priceIndex | $indexFluctuation | $fluctuationRate | $tradeDate';
  }
}

//  [TREND - kosdaq]
class KosdaqIndex {
  final String priceIndex;
  final String indexFluctuation;
  final String fluctuationRate;
  final String tradeDate;

  KosdaqIndex({
    this.priceIndex = '',
    this.indexFluctuation = '',
    this.fluctuationRate = '',
    this.tradeDate = '',
  });

  factory KosdaqIndex.fromJson(Map<String, dynamic> json) {
    return KosdaqIndex(
      priceIndex: json['priceIndex'] ?? '',
      indexFluctuation: json['indexFluctuation'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
      tradeDate: json['tradeDate'] ?? '',
    );
  }

  @override
  String toString() {
    return '$priceIndex | $indexFluctuation | $fluctuationRate | $tradeDate';
  }
}


// 하루 많이 상승한 이슈 [UPDAY]
class IssueTopDay {
  final String issueSn;
  final String issueDate;
  final String keyword;
  final String avgFluctRate;

  IssueTopDay({
    this.issueSn = '',
    this.issueDate = '',
    this.keyword = '',
    this.avgFluctRate = '',
  });

  factory IssueTopDay.fromJson(Map<String, dynamic> json) {
    return IssueTopDay(
      issueSn: json['issueSn'] ?? '',
      issueDate: json['issueDate'] ?? '',
      keyword: json['keyword'] ?? '',
      avgFluctRate: json['avgFluctRate'] ?? '',
    );
  }
}



// Tile 한달동안 많이 발섕한 이슈
class TileMonthTopIssue extends StatelessWidget {
  final IssueGenMonth item;
  final int idx;

  const TileMonthTopIssue(this.item, this.idx, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(15),
        decoration: UIStyle.boxWithOpacity16(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('${(idx + 1)}', style: TStyle.defaultContent),
                const SizedBox(width: 10),
                Text(
                  item.keyword,
                  style: TStyle.defaultContent,
                ),
              ],
            ),
            Text(
              '${item.occurCount}회',
              style: TStyle.defaultTitle,
            )
          ],
        ),
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          IssueNewViewer.routeName,
          arguments: PgData(
            pgData: item.issueSn,
            data: item.keyword,
          ),
        );
      },
    );
  }
}

// Tile 하루 많이 상승한 이슈
class TileDayTopIssue extends StatelessWidget {
  final IssueTopDay item;

  const TileDayTopIssue(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(15),
        decoration: UIStyle.boxWithOpacity16(),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  item.keyword,
                  style: TStyle.defaultContent,
                ),
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          IssueNewViewer.routeName,
          arguments: PgData(
            pgData: item.issueSn,
            data: item.keyword,
          ),
        );
      },
    );
  }

  Widget _setStockList(BuildContext context, List<Stock> listStk) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 7.0,
        alignment: WrapAlignment.start,
        children: List.generate(
          listStk.length,
          (index) => InkWell(
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
              // decoration: UIStyle.boxRoundFullColor25c(RColor.bgWeakGrey),
              child: Text(
                TStyle.getLimitString(listStk[index].stockName, 7),
                style: TStyle.contentGrey14,
              ),
            ),
            onTap: () {
              //종목홈으로 이동
              basePageState.goStockHomePage(
                listStk[index].stockCode,
                listStk[index].stockName,
                Const.STK_INDEX_HOME,
              );
            },
          ),
        ),
      ),
    );
  }
}

enum IssueDivType {
  OCCUR, //한달간 가장 많이 발생
  TREND, //이슈 트랜드
  UPDAY, //일별 가장 많이 상승
  UPMON, //월별 가장 많이 상승
}

// enum Issue11Type {
//   OCCUR('OCCUR', '한달_많이_발생'),
//   TREND('TREND', '이슈_트랜드'),
//   UPDAY('UPDAY', '일별_상승_랭킹'),
//   UPMON('UPMON', '월별_상승_랭킹'),
//   undefined('undefined', '정의되지않음');
//
//   const Issue11Type(this.code, this.displayName);
//
//   final String code;
//   final String displayName;
//
//   factory Issue11Type.getByCode(String code) {
//     return Issue11Type.values.firstWhere((value) => value.code == code, orElse: () => Issue11Type.undefined);
//   }
// }
