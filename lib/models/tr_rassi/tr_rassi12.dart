import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/sub/report_page.dart';

/// 2021.03.08
/// 라씨 분석 리포트
class TrRassi12 {
  final String retCode;
  final String retMsg;
  final List<Rassi12> listData;

  TrRassi12({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrRassi12.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<Rassi12> rtList = list.map((i) => Rassi12.fromJson(i)).toList();
    return TrRassi12(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: rtList,
    );
  }
}

class Rassi12 {
  final String reportDiv;
  final String reportName;
  final String reportDesc;
  final String tagCode;
  final String tagName;

  Rassi12({
    this.reportDiv = '',
    this.reportName = '',
    this.reportDesc = '',
    this.tagCode = '',
    this.tagName = '',
  });

  factory Rassi12.fromJson(Map<String, dynamic> json) {
    return Rassi12(
      reportDiv: json['reportDiv'] ?? '',
      reportName: json['reportName'] ?? '',
      reportDesc: json['reportDesc'] ?? '',
      tagCode: json['tagCode'] ?? '',
      tagName: json['tagName'] ?? '',
    );
  }

  @override
  String toString() {
    return '$reportDiv | $reportName | $tagName | $tagCode';
  }
}

//화면구성 (기존)
class TileRassi12 extends StatelessWidget {
  final Rassi12 item;
  final Color bColor;

  TileRassi12(this.item, this.bColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(
        left: 10,
        right: 8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      decoration: BoxDecoration(
        color: bColor,
        shape: BoxShape.circle,
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: 90,
          child: Center(
            child: Text(
              item.reportName,
              style: TStyle.commonTitle15,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        onTap: () {
          //분석 페이지로 이동
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportPage(),
                settings: RouteSettings(
                  arguments: PgData(
                    pgSn: item.reportDiv,
                    pgData: item.reportName,
                  ),
                ),
              ));
        },
      ),
    );
  }
}

//화면구성 - Swiper (2024.06)
class TileSwpRassi12 extends StatelessWidget {
  final List<Rassi12> itemList;

  const TileSwpRassi12(this.itemList);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){
        double gridViewHeight = 340; // 고정된 GridView 높이
        double gridViewWidth = constraints.maxWidth; // 현재 사용 가능한 너비
        int crossAxisCount = 2; // 가로로 표시할 아이템 수

        // 각 아이템의 너비 계산
        double itemWidth = gridViewWidth / crossAxisCount;
        // 각 아이템의 높이 계산 (GridView 높이의 절반)
        double itemHeight = gridViewHeight / 2;

        // childAspectRatio 계산
        double aspectRatio = itemWidth / itemHeight;

        return Container(
          width: double.infinity,
          //height: 250,
          margin: const EdgeInsets.only(left: 10, right: 8),
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: aspectRatio,
            crossAxisCount: 2,
            children: List<Widget>.generate(itemList.length, (index) {
              return InkWell(
                child: Container(
                  // width: 300,
                  // height: 85,
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(15),
                  decoration: UIStyle.boxShadowBasic(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              itemList[index].reportName,
                              style: TStyle.commonTitle,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: AutoSizeText(
                                itemList[index].reportDesc,
                                maxLines: 3,
                                style: TextStyle(color: RColor.greyBasicStrong_666666,),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: itemList[index].tagName.isNotEmpty,
                        child: Text(
                          '#${itemList[index].tagName}',
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: RColor.mainColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  //분석 페이지로 이동
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportPage(),
                        settings: RouteSettings(
                          arguments: PgData(
                            pgSn: itemList[index].reportDiv,
                            pgData: itemList[index].reportName,
                          ),
                        ),
                      ));
                },
              );
            }),
          ),
        );
      },
    );
  }

}
