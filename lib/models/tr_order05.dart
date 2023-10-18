
/// 2021.12.09
/// 주문 상세 내역 조회
class TrOrder05 {
  final String retCode;
  final String retMsg;
  final Order05? retData;

  TrOrder05({this.retCode = '', this.retMsg = '', this.retData});

  factory TrOrder05.fromJson(Map<String, dynamic> json) {
    return TrOrder05(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? null : Order05.fromJson(json['retData']),
    );
  }
}


class Order05 {
  final String orderSn;
  final String svcDivision;
  final String orderStatus;
  final String orderStatText;
  final String orderChannel;
  final String orderChanText;
  final String svcCondition;
  final String svcCondText;
  final String prodCode;
  final String prodName;
  final String prodSubdiv;
  final String prodSubdivName;
  final String prodCateg;
  final String startDate;
  final String endDate;
  final String pricePolicy;
  final String orderDttm;
  final String paymentAmt;
  final String subscriptStat;
  final String payMethod;
  final String transactId;
  final String usageDays;
  final String usageMonth;
  final String usageAmt;
  final String cancelFee;
  final String remainAmt;

  Order05({
      this.orderSn = '',
      this.svcDivision = '',
      this.orderStatus = '',
      this.orderStatText = '',
      this.orderChannel = '',
      this.orderChanText = '',
      this.svcCondition = '',
      this.svcCondText = '',
      this.prodCode = '',
      this.prodName = '',
      this.prodSubdiv = '',
      this.prodSubdivName = '',
      this.prodCateg = '',
      this.startDate = '',
      this.endDate = '',
      this.pricePolicy = '',
      this.orderDttm = '',
      this.paymentAmt = '',
      this.subscriptStat = '',
      this.payMethod = '',
      this.transactId = '',
      this.usageDays = '',
      this.usageMonth = '',
      this.usageAmt = '',
      this.cancelFee = '',
      this.remainAmt = ''
  });

  factory Order05.fromJson(Map<String, dynamic> json) {
    return Order05(
      orderSn: json['orderSn'],
      svcDivision: json['svcDivision'],
      orderStatus: json['orderStatus'],
      orderStatText: json['orderStatText'],
      orderChannel: json['orderChannel'],

      orderChanText: json['orderChanText'],
      svcCondition: json['svcCondition'],
      svcCondText: json['svcCondText'],
      prodCode: json['prodCode'],
      prodName: json['prodName'],
      prodSubdiv: json['prodSubdiv'],
      prodSubdivName: json['prodSubdivName'],
      prodCateg: json['prodCateg'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      pricePolicy: json['pricePolicy'],
      orderDttm: json['orderDttm'],

      paymentAmt: json['paymentAmt'],
      subscriptStat: json['subscriptStat'],
      payMethod: json['payMethod'],
      transactId: json['transactId'],
      usageDays: json['usageDays'],
      usageMonth: json['usageMonth'],
      usageAmt: json['usageAmt'],
      cancelFee: json['cancelFee'],
      remainAmt: json['remainAmt'],
    );
  }
}
