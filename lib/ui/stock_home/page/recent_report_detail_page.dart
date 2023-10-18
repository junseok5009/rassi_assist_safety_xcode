import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/tr_report04.dart';

/// 2023.03.15
/// 최신 리포트 상세 페이지

class RecentReportDetailPage extends StatelessWidget {
  //const RecentReportDetailPage({Key? key}) : super(key: key);
  RecentReportDetailPage(this.item);
  final Report04Report item;
  static const String TAG_NAME = '최신_리포트_상세';

  @override
  Widget build(BuildContext context) {
    DLog.w('build');
    CustomFirebaseClass.logEvtScreenView(
      RecentReportDetailPage.TAG_NAME,
    );
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(Icons.close),
              color: Colors.black,
              onPressed: () => Navigator.of(context).pop(null),
            ),
            const SizedBox(
              width: 10.0,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                Text(
                  '${item.title}',
                  style: TStyle.title18,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Text(
                      '${item.organName} | ',
                      style: TStyle.contentGrey12,
                    ),
                    Text(
                      TStyle.getDateDivFormat(item.issueDate),
                      style: TStyle.contentGrey12,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: RColor.lineGrey,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Text('목표가 : ${TStyle.getMoneyPoint(item.goalPrice)}원',),
                const SizedBox(height: 4,),
                Text('투자의견 : ${item.opinion}',),
                const SizedBox(height: 20,),
                Text(item.content),
              ],
            ),
          ),
        ),
      ),
    );
  }

}