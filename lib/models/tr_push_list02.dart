import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

/// 2020.10.26
/// 알림 분류별 조회
class TrPushList02 {
  final String retCode;
  final String retMsg;
  final PushList02? retData;

  TrPushList02({this.retCode = '', this.retMsg = '', this.retData});

  factory TrPushList02.fromJson(Map<String, dynamic> json) {
    return TrPushList02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? null : PushList02.fromJson(json['retData']),
    );
  }
}

class PushList02 {
  final String displayYn; //
  final String totalPageSize;
  final String currentPageNo;
  final List<PushInfoDv>? pushList;

  PushList02({
    this.displayYn = '',
    this.totalPageSize = '',
    this.currentPageNo = '',
    this.pushList,
  });

  factory PushList02.fromJson(Map<String, dynamic> json) {
    var jsonListPush = json['list_Push'];
    List<PushInfoDv>? rtList =
        jsonListPush == null ? [] : (jsonListPush as List).map((i) => PushInfoDv.fromJson(i)).toList();

    return PushList02(
      displayYn: json['displayYn'],
      totalPageSize: json['totalPageSize'],
      currentPageNo: json['currentPageNo'],
      pushList: rtList,
    );
  }

  @override
  String toString() {
    return '$displayYn| $currentPageNo/$totalPageSize';
  }
}

class PushInfoDv {
  final String pushDiv1;
  final String pushDiv1Name;
  final String pushDiv2; //JB:정보, IJ:일정, SG:수급, SS:시세, USER:개인화
  final String pushDiv2Name;
  final String pushDiv3; //푸시 소분류
  final String prodCode;
  final String prodName;
  final String pocketCode;
  final String pocketName;
  final String stockCode;
  final String stockName;
  final String pushTitle;
  final String pushContent;
  final String regDttm;

  PushInfoDv({
    this.pushDiv1 = '',
    this.pushDiv1Name = '',
    this.pushDiv2 = '',
    this.pushDiv2Name = '',
    this.pushDiv3 = '',
    this.prodCode = '',
    this.prodName = '',
    this.pocketCode = '',
    this.pocketName = '',
    this.stockCode = '',
    this.stockName = '',
    this.pushTitle = '',
    this.pushContent = '',
    this.regDttm = '',
  });

  factory PushInfoDv.fromJson(Map<String, dynamic> json) {
    return PushInfoDv(
      pushDiv1: json['pushDiv1'] ?? '',
      pushDiv1Name: json['pushDiv1Name'] ?? '',
      pushDiv2: json['pushDiv2'] ?? '',
      pushDiv2Name: json['pushDiv2Name'] ?? '',
      pushDiv3: json['pushDiv3'] ?? '',
      prodCode: json['prodCode'] ?? '',
      prodName: json['prodName'] ?? '',
      pocketCode: json['pocketCode'] ?? '',
      pocketName: json['pocketName'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      pushTitle: json['pushTitle'] ?? '',
      pushContent: json['pushContent'] ?? '',
      regDttm: json['regDttm'] ?? '',
    );
  }

  @override
  String toString() {
    return '$pushDiv2|$pushDiv3|$prodName|$pushTitle';
  }
}

//화면구성
class TilePushListDv extends StatelessWidget {
  final appGlobal = AppGlobal();
  final PushInfoDv item;

  TilePushListDv(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    String content;
    if (item.pushDiv1 == 'TS' || item.pushDiv1 == 'SB') {
      content = '${item.stockName}   ${item.stockCode}';
    } else {
      content = item.pushContent;
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 20,
      ),
      alignment: Alignment.centerLeft,
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'images/main_arlim_icon_buy.png',
                height: 25,
                fit: BoxFit.contain,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.pushTitle,
                      style: TStyle.commonTitle15,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      content,
                      style: TStyle.content14,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(TStyle.getDateFormat(item.regDttm)),
                  ],
                ),
              )
            ],
          ),
        ),
        onTap: () {
          if (item.pushDiv1 == 'TS') {
            basePageState.goStockHomePage(
              item.stockCode,
              item.stockName,
              Const.STK_INDEX_SIGNAL,
            );
            // 포켓 SN 이 있을경우 포켓으로 이동
          } /*if(item.pushDiv1 == 'RN'){
            goStockHome(context, Const.STK_INDEX_NEWS);
          } if(item.pushDiv1 == 'SN'){
            goStockHome(context, Const.STK_INDEX_SOCIAL);
          } if(item.pushDiv1 == 'SB'){
            goStockHome(context, Const.STK_INDEX_TIMELINE);
          } if(item.pushDiv1 == 'BS'){
            //메인 배너 랜딩?
          } if(item.pushDiv1 == 'CB'){
            //메인 배너 랜딩?
          } if(item.pushDiv1 == 'IS'){
            //메인 배너 랜딩?
          }*/
        },
      ),
    );
  }
}
