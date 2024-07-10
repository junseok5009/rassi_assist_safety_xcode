import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/web/inapp_webview_page.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

class TrRassi19 {
  final String retCode;
  final String retMsg;
  final Rassi19 retData;

  TrRassi19({this.retCode = '', this.retMsg = '', this.retData = const Rassi19()});

  factory TrRassi19.fromJson(Map<String, dynamic> json) {
    return TrRassi19(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? const Rassi19() : Rassi19.fromJson(json['retData']),
    );
  }
}

class Rassi19 {
  final String menuDiv;
  final String totalPageSize;
  final String currentPageNo;
  final List<Rassi19Rassiro> listRassiro;

  const Rassi19({this.menuDiv = '', this.totalPageSize = '', this.currentPageNo = '', this.listRassiro = const []});

  factory Rassi19.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Rassiro'];
    return Rassi19(
      menuDiv: json['menuDiv'] ?? '',
      totalPageSize: json['totalPageSize'] ?? '0',
      currentPageNo: json['currentPageNo'] ?? '0',
      listRassiro: jsonList == null ? [] : (jsonList as List).map((e) => Rassi19Rassiro.fromJson(e)).toList(),
    );
  }
}

class Rassi19Rassiro {
  final String issueDate;
  final String issueTime;
  final String stockCode;
  final String stockName;
  final String fluctuationRate;
  final String title;
  final String linkUrl;
  final String currentPrice;

  // menuDiv: CHANGE
  final String listedShares; //상장 주식수
  final String tradeVol; //당일 거래 수량
  final String tradeVolRate; //거래 수량의 비율(상장 주식수 대비)

  bool get isEmpty =>
      issueDate.isEmpty &&
      issueTime.isEmpty &&
      stockCode.isEmpty &&
      stockName.isEmpty &&
      fluctuationRate.isEmpty &&
      title.isEmpty;

  Rassi19Rassiro({
    this.issueDate = '',
    this.issueTime = '',
    this.stockCode = '',
    this.stockName = '',
    this.fluctuationRate = '',
    this.title = '',
    this.linkUrl = '',
    this.currentPrice = '',
    this.listedShares = '',
    this.tradeVol = '',
    this.tradeVolRate = '',
  });

  factory Rassi19Rassiro.fromJson(Map<String, dynamic> json) {
    return Rassi19Rassiro(
      issueDate: json['issueDate'] ?? '',
      issueTime: json['issueTime'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
      title: json['title'] ?? '',
      linkUrl: json['linkUrl'] ?? '',
      currentPrice: json['currentPrice'] ?? '',
      listedShares: json['listedShares'] ?? '',
      tradeVol: json['tradeVol'] ?? '',
      tradeVolRate: json['tradeVolRate'] ?? '',
    );
  }
}

class Rassi19TimeLineRealItemWidget extends StatelessWidget {
  const Rassi19TimeLineRealItemWidget({super.key, required this.item});

  final Rassi19Rassiro item;

  @override
  Widget build(BuildContext context) {
    if (item.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 100,
              child: SkeletonLoader(
                items: 1,
                period: const Duration(seconds: 1),
                highlightColor: Colors.grey[100]!,
                direction: SkeletonDirection.ltr,
                builder: Container(
                  height: 96,
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                  ),
                  alignment: Alignment.centerLeft,
                  //decoration: UIStyle.boxRoundLine6(),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 150,
                            height: 26,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Container(
                            width: 60,
                            height: 18,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 3 / 4,
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    bool isToday = false;
    DateTime dateTime = DateTime.now();
    if (item.issueDate == TStyle.getTodayString()) {
      isToday = true;
      dateTime = (DateTime.now()).subtract(Duration(
          hours: int.parse(item.issueTime.substring(0, 2)), minutes: int.parse(item.issueTime.substring(2, 4))));
    }
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        basePageState.goStockHomePage(
          item.stockCode,
          item.stockName,
          Const.STK_INDEX_HOME,
        );
      },
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isToday
                    ? Row(
                        children: [
                          if (dateTime.hour != 0)
                            Text(
                              '${dateTime.hour}시간 ',
                              style: const TextStyle(
                                color: RColor.mainColor,
                              ),
                            ),
                          Text(
                            '${dateTime.minute}분전',
                            style: const TextStyle(
                              color: RColor.mainColor,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        '${TStyle.getDateSlashFormat2(item.issueDate)} ${item.issueTime.substring(0, 2)}:${item.issueTime.substring(2, 4)}',
                        style: const TextStyle(
                          color: RColor.new_basic_text_color_strong_grey,
                        ),
                      ),
                CommonView.setFluctuationRateBox(
                  value: item.fluctuationRate,
                  fontSize: 14,
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.stockName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  item.stockCode,
                  style: const TextStyle(
                    fontSize: 12,
                    color: RColor.greyBasic_8c8c8c,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            if (item.title.isNotEmpty)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    Platform.isAndroid
                        ? CustomNvRouteClass.createRouteSlow1(
                            InappWebviewPage('', item.linkUrl),
                          )
                        : CustomNvRouteClass.createRoute(
                            InappWebviewPage('', item.linkUrl),
                          ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.title,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            Container(
              width: double.infinity,
              height: 1,
              margin: const EdgeInsets.only(top: 10),
              color: RColor.greyBox_dcdfe2,
            ),
          ],
        ),
      ),
    );
  }
}

class Rassi19RealItemWidget extends StatelessWidget {
  const Rassi19RealItemWidget({super.key, required this.item});

  final Rassi19Rassiro item;

  @override
  Widget build(BuildContext context) {
    if (item.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 100,
              child: SkeletonLoader(
                items: 1,
                period: const Duration(seconds: 1),
                highlightColor: Colors.grey[100]!,
                direction: SkeletonDirection.ltr,
                builder: Container(
                  height: 96,
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                  ),
                  alignment: Alignment.centerLeft,
                  //decoration: UIStyle.boxRoundLine6(),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 150,
                            height: 26,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Container(
                            width: 60,
                            height: 18,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 3 / 4,
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    bool isToday = false;
    DateTime dateTime = DateTime.now();
    if (item.issueDate == TStyle.getTodayString()) {
      isToday = true;
      dateTime = (DateTime.now()).subtract(Duration(
          hours: int.parse(item.issueTime.substring(0, 2)), minutes: int.parse(item.issueTime.substring(2, 4))));
    }
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        basePageState.goStockHomePage(
          item.stockCode,
          item.stockName,
          Const.STK_INDEX_HOME,
        );
      },
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isToday
                    ? Row(
                        children: [
                          if (dateTime.hour != 0)
                            Text(
                              '${dateTime.hour}시간 ',
                              style: const TextStyle(
                                color: RColor.mainColor,
                              ),
                            ),
                          Text(
                            '${dateTime.minute}분전',
                            style: const TextStyle(
                              color: RColor.mainColor,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        '${TStyle.getDateSlashFormat2(item.issueDate)} ${item.issueTime.substring(0, 2)}:${item.issueTime.substring(2, 4)}',
                        style: const TextStyle(
                          color: RColor.new_basic_text_color_strong_grey,
                        ),
                      ),
                CommonView.setFluctuationRateBox(
                  value: item.fluctuationRate,
                  fontSize: 14,
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.stockName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  item.stockCode,
                  style: const TextStyle(
                    fontSize: 12,
                    color: RColor.greyBasic_8c8c8c,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            if (item.title.isNotEmpty)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    Platform.isAndroid
                        ? CustomNvRouteClass.createRouteSlow1(
                            InappWebviewPage('', item.linkUrl),
                          )
                        : CustomNvRouteClass.createRoute(
                            InappWebviewPage('', item.linkUrl),
                          ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.title,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            Container(
              width: double.infinity,
              height: 1,
              margin: const EdgeInsets.only(top: 10),
              color: RColor.greyBox_dcdfe2,
            ),
          ],
        ),
      ),
    );
  }
}

class Rassi19Week52ItemWidget extends StatelessWidget {
  const Rassi19Week52ItemWidget({super.key, required this.item});

  final Rassi19Rassiro item;

  @override
  Widget build(BuildContext context) {
    if (item.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 100,
              child: SkeletonLoader(
                items: 1,
                period: const Duration(seconds: 1),
                highlightColor: Colors.grey[100]!,
                direction: SkeletonDirection.ltr,
                builder: Container(
                  height: 96,
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                  ),
                  alignment: Alignment.centerLeft,
                  //decoration: UIStyle.boxRoundLine6(),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 150,
                            height: 26,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Container(
                            width: 60,
                            height: 18,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 3 / 4,
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        basePageState.goStockHomePage(
          item.stockCode,
          item.stockName,
          Const.STK_INDEX_HOME,
        );
      },
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TStyle.getDateSlashFormat2(item.issueDate),
                  style: const TextStyle(
                    color: RColor.new_basic_text_color_strong_grey,
                  ),
                ),
                CommonView.setFluctuationRateBox(
                  value: item.fluctuationRate,
                  fontSize: 14,
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.stockName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  item.stockCode,
                  style: const TextStyle(
                    fontSize: 12,
                    color: RColor.greyBasic_8c8c8c,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            if (item.title.isNotEmpty)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    Platform.isAndroid
                        ? CustomNvRouteClass.createRouteSlow1(
                            InappWebviewPage('', item.linkUrl),
                          )
                        : CustomNvRouteClass.createRoute(
                            InappWebviewPage('', item.linkUrl),
                          ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.title,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            Container(
              width: double.infinity,
              height: 1,
              margin: const EdgeInsets.only(top: 10),
              color: RColor.greyBox_dcdfe2,
            ),
          ],
        ),
      ),
    );
  }
}

class Rassi19ChangeItemWidget extends StatelessWidget {
  const Rassi19ChangeItemWidget({super.key, required this.item});

  final Rassi19Rassiro item;

  @override
  Widget build(BuildContext context) {
    if (item.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 100,
              child: SkeletonLoader(
                items: 1,
                period: const Duration(seconds: 1),
                highlightColor: Colors.grey[100]!,
                direction: SkeletonDirection.ltr,
                builder: Container(
                  height: 96,
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                  ),
                  alignment: Alignment.centerLeft,
                  //decoration: UIStyle.boxRoundLine6(),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 150,
                            height: 26,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Container(
                            width: 60,
                            height: 18,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 3 / 4,
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        basePageState.goStockHomePage(
          item.stockCode,
          item.stockName,
          Const.STK_INDEX_HOME,
        );
      },
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TStyle.getDateSlashFormat2(item.issueDate),
                  style: const TextStyle(
                    color: RColor.new_basic_text_color_strong_grey,
                  ),
                ),
                CommonView.setFluctuationRateBox(
                  value: item.fluctuationRate,
                  fontSize: 14,
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.stockName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  item.stockCode,
                  style: const TextStyle(
                    fontSize: 12,
                    color: RColor.greyBasic_8c8c8c,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              //alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: UIStyle.boxRoundFullColor6c(
                RColor.greyBox_f5f5f5,
              ),
              child: Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          '거래량 ',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          TStyle.getMoneyPoint(item.tradeVol),
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '상장주식수 ',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          TStyle.getMoneyPoint(item.listedShares),
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          '거래비중 ',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${TStyle.getMoneyPoint(item.tradeVolRate)}%',
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              width: double.infinity,
              height: 1,
              margin: const EdgeInsets.only(top: 10),
              color: RColor.greyBox_dcdfe2,
            ),
          ],
        ),
      ),
    );
  }
}
