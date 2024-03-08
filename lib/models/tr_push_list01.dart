import 'package:flutter/material.dart';
import 'package:rassi_assist/common/tstyle.dart';


/// 2020.10.26
/// 일자별 알림 전체 조회
class TrPushList01 {
  final String retCode;
  final String retMsg;
  final List<PushList01> listData;

  TrPushList01({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrPushList01.fromJson(Map<String, dynamic> json) {
    var list = (json['retData'] ?? []) as List;

    List<PushList01>? rtList;
    list == null ? rtList = null : rtList = list.map((i) => PushList01.fromJson(i)).toList();
    return TrPushList01(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        listData: list.map((i) => PushList01.fromJson(i)).toList(),
    );
  }
}

// 1일
class PushList01 {
  final String issueDate;
  final String weekday;
  final List<PushDiv> divList;

  PushList01({this.issueDate = '', this.weekday = '', this.divList = const [],});

  factory PushList01.fromJson(Map<String, dynamic> json) {
    var list = json['list_PushDiv'] as List;
    List<PushDiv> rtList = list.map((i) => PushDiv.fromJson(i)).toList();

    return PushList01(
      issueDate: json['issueDate'],
      weekday: json['weekday'],
      divList: rtList,
    );
  }

  @override
  String toString() {
    return '$issueDate|$weekday';
  }
}

// 1줄
class PushDiv {
  final String pushDiv1;      //TS:신호, RN:속보, SN:소셜, SB: 스톡벨, .....
  final String pushDiv1Name;
  final String pushCount;
  final List<PushInfo> pushList;

  PushDiv({
    this.pushDiv1 = '',
    this.pushDiv1Name = '',
    this.pushCount = '',
    this.pushList = const []
  });

  factory PushDiv.fromJson(Map<String, dynamic> json) {
    var list = json['list_Push'] as List;
    List<PushInfo> rtList = list.map((i) => PushInfo.fromJson(i)).toList();

    return PushDiv(
      pushDiv1: json['pushDiv1'],
      pushDiv1Name: json['pushDiv1Name'],
      pushCount: json['pushCount'],
      pushList: rtList,
    );
  }

  @override
  String toString() {
    return '$pushDiv1|$pushDiv1Name|$pushCount';
  }
}

// 1칸
class PushInfo {
  final String pushDiv2;    //JB:정보, IJ:일정, SG:수급, SS:시세, USER:개인화
  final String pushDiv3;    //푸시 소분류
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String prodCode;
  final String prodName;
  final String pushTitle;
  final String pushContent;
  final String regDttm;
  final String pocketSn;
  final String pocketName;

  PushInfo({
    this.pushDiv2 = '', this.pushDiv3 = '',
    this.stockCode = '', this.stockName = '',
    this.tradeFlag = '', this.prodCode = '',
    this.prodName = '', this.pushTitle = '', this.pushContent = '',
    this.regDttm = '', this.pocketSn = '', this.pocketName = '',
  });

  factory PushInfo.fromJson(Map<String, dynamic> json) {
    return PushInfo(
      pushDiv2: json['pushDiv2'] ?? '',
      pushDiv3: json['pushDiv3'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      tradeFlag: json['tradeFlag'] ?? '',
      prodCode: json['prodCode'] ?? '',
      prodName: json['prodName'] ?? '',
      pushTitle: json['pushTitle'] ?? '',
      pushContent: json['pushContent'] ?? '',
      regDttm: json['regDttm'] ?? '',
      pocketSn: json['pocketSn'] ?? '',
      pocketName: json['pocketName'] ?? '',
    );
  }

  @override
  String toString() {
    return '$pushDiv2|$pushDiv3|$prodName|$pushTitle';
  }
}


//화면구성
class TilePushList extends StatelessWidget {
  final PushList01 item;

  TilePushList(this.item);

  @override
  Widget build(BuildContext context) {
    // String tm = item.elapsedTmTx;

    return Container(
      width: double.infinity,
      height: 70,
      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0,),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.8,),
        borderRadius: const BorderRadius.all(const Radius.circular(17.0)),
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: double.infinity,
          height: 70,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(item.issueDate, style: TStyle.title18,),
                  SizedBox(width: 5.0,),
                  Text(item.weekday, style: TStyle.textSGrey,),
                ],
              ),
              // Text('$tm시간전\n폭발', maxLines: 2,)
            ],
          ),
        ),
        onTap: (){
          //종목홈-소셜지수 탭으로 연결
          // Provider.of<StockHome>(context, listen: false)
          //     .setStockData(item.stockCode, item.stockName, '', '', '', 2);
          // Navigator.push(context, new MaterialPageRoute(
          //   builder: (context) => StockHomeTab(),
          // ));
        },
      ),
    );
  }
}

//화면구성
class TileDivList extends StatelessWidget {
  final List<PushInfo> listItem;

  TileDivList(this.listItem, );

  @override
  Widget build(BuildContext context) {
    // print("list count = ${listItem.length}");
    return SliverToBoxAdapter(
      child: Container(
        height: 120,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: listItem.length,
            itemBuilder: (context, index) {
              return Text(listItem[index].pushTitle);
            }),
      ),
    );
  }
}