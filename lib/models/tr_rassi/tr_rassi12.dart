import 'package:flutter/material.dart';
import 'package:rassi_assist/common/tstyle.dart';
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

  Rassi12({this.reportDiv = '', this.reportName = '',});

  factory Rassi12.fromJson(Map<String, dynamic> json) {
    return Rassi12(
      reportDiv: json['reportDiv'],
      reportName: json['reportName'],
    );
  }

  @override
  String toString() {
    return '$reportDiv | $reportName';
  }
}


//화면구성
class TileRassi12 extends StatelessWidget {
  final Rassi12 item;
  final Color bColor;

  TileRassi12(this.item, this.bColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(left: 10, right: 8,),
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      decoration: BoxDecoration(color: bColor, shape: BoxShape.circle,),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: 90,
          child: Center(
            child: Text(item.reportName, style: TStyle.commonTitle15,
              maxLines: 2, textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        onTap: (){    //분석 페이지로 이동
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => ReportPage(),
            settings: RouteSettings(
              arguments: PgData(
                pgSn: item.reportDiv,
                pgData: item.reportName,),
            ),
          ));
        },
      ),
    );
  }

}