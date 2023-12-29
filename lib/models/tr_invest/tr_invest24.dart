import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';

class TrInvest24 {
  final String retCode;
  final String retMsg;
  final Invest24? retData;

  TrInvest24({this.retCode = '', this.retMsg = '', this.retData});

  factory TrInvest24.fromJson(Map<String, dynamic> json) {
    return TrInvest24(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? null : Invest24.fromJson(json['retData']),
    );
  }
}

class Invest24 {
  String lockupCount = '';
  String returnCount = '';
  List<Invest24Lockup> listInvest24Lockup = [];

  Invest24({
    this.lockupCount = '',
    this.returnCount = '',
    this.listInvest24Lockup = const [],
  });

  Invest24.empty() {
    lockupCount = '0';
    returnCount = '0';
    listInvest24Lockup = [];
  }

  factory Invest24.fromJson(Map<String, dynamic> json) {
    var list = json['list_Lockup'] as List;
    List<Invest24Lockup> dataList = list == null ? [] : list.map((i) => Invest24Lockup.fromJson(i)).toList();
    return Invest24(
      lockupCount: json['lockupCount'] ?? '0',
      returnCount: json['returnCount'] ?? '0',
      listInvest24Lockup: dataList,
    );
  }
}

class Invest24Lockup {
  final String stockCode; // 날짜
  final String stockName; // 가격
  final String workDiv; // 신규 수량
  final String lockupDate; // 상환 수량
  final String lockupVol; // 잔고 수량
  final String lockupRate; // 잔고 비율
  final String returnDate; // 신용 공여율
  final String returnVol; // 신용 잔고율
  final String returnRate; // 신용 잔고율
  final String reasonName;

  Invest24Lockup({
    this.stockCode = '',
    this.stockName = '',
    this.workDiv = '',
    this.lockupDate = '',
    this.lockupVol = '',
    this.lockupRate = '',
    this.returnDate = '',
    this.returnVol = '',
    this.returnRate = '',
    this.reasonName = '',
  });

  factory Invest24Lockup.fromJson(Map<String, dynamic> json) {
    return Invest24Lockup(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      workDiv: json['workDiv'] ?? '',
      lockupDate: json['lockupDate'] ?? '',
      lockupVol: json['lockupVol'] ?? '',
      lockupRate: json['lockupRate'] ?? '',
      returnDate: json['returnDate'] ?? '',
      returnVol: json['returnVol'] ?? '',
      returnRate: json['returnRate'] ?? '',
      reasonName: json['reasonName'] ?? '',
    );
  }

  Widget tileInvest24LockupView() {
    return Container(
      margin: const EdgeInsets.only(
        top: 15,
      ),
      decoration: UIStyle.boxShadowBasic(6),
      padding: const EdgeInsets.all(
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    color: workDiv == '반환' ? RColor.purpleBgBasic_dbdbff : RColor.buyBgBasic_ffd1d1,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    child: Text(
                      workDiv,
                      style: TextStyle(
                        color: workDiv == '반환' ? RColor.mainColor : RColor.sigBuy,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    TStyle.getDateSlashFormat2(
                      workDiv == '반환' ? returnDate : lockupDate,
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (workDiv == '반환')
                Text(
                  '예탁일자 : ${TStyle.getDateSlashFormat2(lockupDate)}',
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            '${TStyle.getMoneyPoint(workDiv == '반환' ? returnVol : lockupVol)}주 (총 발행주식 대비 ${workDiv == '반환' ? returnRate : lockupRate}%)',
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
          Text(
            reasonName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
