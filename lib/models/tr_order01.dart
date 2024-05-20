import 'package:flutter/material.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';

/// 2020.12.08
/// 결제 내역
class TrOrder01 {
  final String retCode;
  final String retMsg;
  final List<Order01> listData;

  TrOrder01({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrOrder01.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] == null ? [] : json['retData'] as List;
    List<Order01>? rtList;
    list == null ? rtList = null : rtList = list.map((i) => Order01.fromJson(i)).toList();
    return TrOrder01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: list.map((i) => Order01.fromJson(i)).toList(),
    );
  }
}

class Order01 {
  final String orderSn;
  final String svcDivision;
  final String orderStatus;
  final String orderStatText;
  final String orderChannel;
  final String orderChanText;
  final String csPhoneNo;
  final String prodSubdiv;
  final String prodSubdivName;
  final String prodCateg;
  final String pricePolicy; //가격정책 (MONTH, AUTO, FREE, CASH)
  final String orderDttm;
  final String payMethod;
  final String payMethodText;
  final String paymentAmt;
  final String subscriptStat; //구독상태 (S:구독 이용중, C:구독 해지(상품이용중), E:구독 만료, N:비구독자)
  final String refundAmt;
  final String refundDttm;
  final List<OrderChange> chList;

  Order01({
    this.orderSn = '',
    this.svcDivision = '',
    this.orderStatus = '',
    this.orderStatText = '',
    this.orderChannel = '',
    this.orderChanText = '',
    this.csPhoneNo = '',
    this.prodSubdiv = '',
    this.prodSubdivName = '',
    this.prodCateg = '',
    this.pricePolicy = '',
    this.orderDttm = '',
    this.payMethod = '',
    this.payMethodText = '',
    this.paymentAmt = '',
    this.subscriptStat = '',
    this.refundAmt = '',
    this.refundDttm = '',
    this.chList = const [],
  });

  factory Order01.fromJson(Map<String, dynamic> json) {
    var list = json['list_OrderChange'] == null ? [] : json['list_OrderChange'] as List;
    List<OrderChange>? rtList;
    list == null ? rtList = null : rtList = list.map((i) => OrderChange.fromJson(i)).toList();
    return Order01(
      orderSn: json['orderSn'],
      svcDivision: json['svcDivision'],
      orderStatus: json['orderStatus'],
      orderStatText: json['orderStatText'],
      orderChannel: json['orderChannel'],
      orderChanText: json['orderChanText'],
      csPhoneNo: json['csPhoneNo'] ?? '',
      prodSubdiv: json['prodSubdiv'],
      prodSubdivName: json['prodSubdivName'],
      prodCateg: json['prodCateg'] ?? '',
      pricePolicy: json['pricePolicy'] ?? '',
      orderDttm: json['orderDttm'] ?? '',
      payMethod: json['payMethod'] ?? '',
      payMethodText: json['payMethodText'] ?? '',
      paymentAmt: json['paymentAmt'],
      subscriptStat: json['subscriptStat'] ?? '',
      refundAmt: json['refundAmt'] ?? '0',
      refundDttm: json['refundDttm'] ?? '',
      chList: list.map((i) => OrderChange.fromJson(i)).toList(),
    );
  }
}

class OrderChange {
  final String changeSeq;
  final String prodCode;
  final String prodName;
  final String prodSubdiv;
  final String startDate;
  final String endDate;
  final String paymentAmt;
  final String orderDttm;

  OrderChange({
    this.changeSeq = '',
    this.prodCode = '',
    this.prodName = '',
    this.prodSubdiv = '',
    this.startDate = '',
    this.endDate = '',
    this.paymentAmt = '',
    this.orderDttm = '',
  });

  factory OrderChange.fromJson(Map<String, dynamic> json) {
    return OrderChange(
      changeSeq: json['changeSeq'],
      prodCode: json['prodCode'],
      prodName: json['prodName'],
      prodSubdiv: json['prodSubdiv'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      paymentAmt: json['paymentAmt'],
      orderDttm: json['orderDttm'],
    );
  }
}

//결제 내역 (Tile 에서 메인뷰에 팝업 띄우는 내용으로 사용안함)
class TileOrder01 extends StatelessWidget {
  final Order01 item;

  const TileOrder01(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    String pdName = '';
    String period = '';
    bool _hasRefund = false;

    if (item.refundAmt != '0') {
      _hasRefund = true;
    } else {
      _hasRefund = false;
    }
    bool _isPossibleCancel = false;
    if (item.orderChannel == 'CH32' || item.orderChannel == 'CH33') {
      if (item.prodSubdiv.startsWith('M') && item.prodSubdiv != 'M01') {
        //1개월 이상의 상품이면서 환불되지 않은 상품에 해지하기 표시
        if (!_hasRefund) _isPossibleCancel = true;
      }
    }

    if (item.chList.length > 0) {
      pdName = item.chList[0].prodName;
      period = '${TStyle.getDateSFormat(item.chList[0].startDate)}'
          '~${TStyle.getDateSFormat(item.chList[0].endDate)}';
    }

    return Container(
      margin: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TStyle.getDateFormat(item.orderDttm),
            style: TStyle.textSGrey,
          ),
          Container(
            margin: const EdgeInsets.only(top: 7.0),
            width: double.infinity,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: const Offset(0, 3), //changes position of shadow
                )
              ],
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2.0),
                            child: const Text(
                              '결제',
                              style: TStyle.contentMGrey,
                            ),
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                TStyle.getMoneyPoint(item.paymentAmt),
                                style: TStyle.title18,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                pdName,
                                style: TStyle.commonSPurple,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '사용기한 $period',
                                style: TStyle.textSGrey,
                              ),
                            ],
                          ),
                        ],
                      ),

                      //(ex 월간 정기 상품)
                      Text(
                        '(${item.prodSubdivName})',
                        style: TStyle.textSGrey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),

                  //환불내역
                  Visibility(
                    visible: _hasRefund,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: UIStyle.boxWeakGrey10(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2.0),
                                child: const Text(
                                  '환불',
                                  style: TStyle.contentMGrey,
                                ),
                              ),
                              const SizedBox(width: 5.0),
                              Text(
                                TStyle.getMoneyPoint(item.refundAmt),
                                style: TStyle.title18,
                              ),
                            ],
                          ),
                          Text(
                            TStyle.getDateSFormat(item.refundDttm),
                            style: TStyle.textSGrey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  //해지하기
                  Visibility(
                    visible: _isPossibleCancel,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: UIStyle.boxWeakGrey10(),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '',
                            style: TStyle.contentMGrey,
                          ),
                          Text(
                            '- 해지하기  ',
                            style: TStyle.contentMGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
