import 'package:flutter/material.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';

/// 2021.12.09
/// 정기 결제 내역
class TrOrder02 {
  final String retCode;
  final String retMsg;
  final List<Order02> listData;

  TrOrder02({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrOrder02.fromJson(Map<String, dynamic> json) {
    var list = (json['retData'] ?? []) as List;
    // List<Order02> rtList;
    // list == null ? rtList = [] : rtList = list.map((i) => Order02.fromJson(i)).toList();

    return TrOrder02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: list.map((i) => Order02.fromJson(i)).toList(),
    );
  }
}

class Order02 {
  final String orderSn;
  final String orderStatus;
  final String orderStatText;
  final String orderChannel; //주문채널(APP, Web, CS)
  final String orderChanText;
  final String csPhoneNo;

  final String svcCondition; //현재 상태(U:이용중, P:이용예정, C:해지)
  final String svcCondText;
  final String svcDivision; //서비스 구분(S:운영, T:테스트)
  final String payMethod; //결제수단
  final String paymentAmt; //결제금액

  final String prodCateg; //상품카테고리(AC:계정, CS:캐시, SR:종목추천)
  final String prodSubdiv;
  final String prodCode;
  final String prodName;
  final String startDate;
  final String endDate;
  final String nextPayDate;
  final String transactId; //거래 ID

  Order02({
    this.orderSn = '',
    this.orderStatus = '',
    this.orderStatText = '',
    this.orderChannel = '',
    this.orderChanText = '',
    this.csPhoneNo = '',
    this.svcCondition = '',
    this.svcCondText = '',
    this.svcDivision = '',
    this.payMethod = '',
    this.paymentAmt = '',
    this.prodCateg = '',
    this.prodSubdiv = '',
    this.prodCode = '',
    this.prodName = '',
    this.startDate = '',
    this.endDate = '',
    this.nextPayDate = '',
    this.transactId = '',
  });

  factory Order02.fromJson(Map<String, dynamic> json) {
    return Order02(
      orderSn: json['orderSn'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      orderStatText: json['orderStatText'] ?? '',
      orderChannel: json['orderChannel'] ?? '',
      orderChanText: json['orderChanText'] ?? '',
      csPhoneNo: json['csPhoneNo'] ?? '',
      svcCondition: json['svcCondition'] ?? '',
      svcCondText: json['svcCondText'] ?? '',
      svcDivision: json['svcDivision'] ?? '',
      payMethod: json['payMethod'] ?? '',
      paymentAmt: json['paymentAmt'] ?? '',
      prodCateg: json['prodCateg'] ?? '',
      prodSubdiv: json['prodSubdiv'] ?? '',
      prodCode: json['prodCode'] ?? '',
      prodName: json['prodName'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      nextPayDate: json['nextPayDate'] ?? '',
      transactId: json['transactId'] ?? '',
    );
  }
}

//정기결제 내역(Tile 에서 메인뷰에 팝업 띄우는 내용으로 사용안함)
class TileOrder02 extends StatelessWidget {
  final Order02 item;

  TileOrder02(this.item);

  @override
  Widget build(BuildContext context) {
    String pdName = '';
    String period = '';
    period = '${TStyle.getDateSFormat(item.startDate)} ~ ${TStyle.getDateSFormat(item.endDate)}';

    return Container(
      margin: const EdgeInsets.all(12.0),
      child: Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      item.prodName,
                      style: TStyle.titleGrey,
                    ),
                  ),
                  const Text(
                    '(정기결제)',
                    style: TextStyle(
                      //공통 중간 타이틀
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Color(0xdd555555),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2.0),
                        child: const Text(
                          '사용기한  ',
                          style: TStyle.textGreyDefault,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        period,
                        style: TStyle.defaultContent,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              //TODO 다음 결제 예정일
              Container(
                padding: const EdgeInsets.all(7),
                decoration: UIStyle.boxWeakGrey10(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2.0),
                          child: const Text(
                            '다음 결제 예정일',
                            style: TStyle.textGrey15,
                          ),
                        ),
                        const SizedBox(width: 7.0),
                        Text(
                          TStyle.getDateMdKorFormat(item.nextPayDate),
                          style: TStyle.defaultContent,
                        ),
                      ],
                    ),
                    const Text(
                      '-정기결제 해지하기',
                      style: TStyle.textGrey14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
