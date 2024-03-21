import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pocket.dart';

/// 2020.11.05
/// 포켓 리스트
class TrPock03 {
  final String retCode;
  final String retMsg;
  final List<Pock03> listData;

  TrPock03({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrPock03.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<Pock03> rtList;
    list == null ? rtList = [] : rtList = list.map((i) => Pock03.fromJson(i)).toList();

    return TrPock03(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: rtList,
    );
  }
}

class Pock03 extends Pocket {
  final String pocketSn;
  final String pocketName;
  final String viewSeq;
  final String pocketSize;
  final String waitCount;
  final String holdCount;

  Pock03({
    this.pocketSn = '',
    this.pocketName = '',
    this.viewSeq = '',
    this.pocketSize = '',
    this.waitCount = '',
    this.holdCount = '',
  }) : super(pocketSn, pocketName);

  factory Pock03.fromJson(Map<String, dynamic> json) {
    return Pock03(
      pocketSn: json['pocketSn'],
      pocketName: json['pocketName'],
      viewSeq: json['viewSeq'],
      pocketSize: json['pocketSize'],
      waitCount: json['waitCount'] ?? 0,
      holdCount: json['holdCount'] ?? 0,
    );
  }

  @override
  String toString() {
    return '$pocketSn | $pocketName';
  }
}

//화면구성 - 종목 추가 BottomSheet
class TilePock03 extends StatelessWidget {
  final Pock03 item;

  const TilePock03(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var waitCnt = int.parse(item.waitCount);
    var holdCnt = int.parse(item.holdCount);
    var totCnt = waitCnt + holdCnt;
    return _setCirclePocket(item.pocketName, "${totCnt.toString()}/${item.pocketSize}");
  }

  //투자수익 Circle
  Widget _setCirclePocket(String pktName, String pktCnt) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      width: 80.0,
      height: 80.0,
      decoration: const BoxDecoration(
        color: RColor.bgSolidSky,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            pktName,
            style: TStyle.title20,
            
          ),
          const SizedBox(
            height: 15.0,
          ),
          const Text(
            '종목수',
            
          ),
          const SizedBox(
            height: 5.0,
          ),
          Text(
            pktCnt,
            
          ),
        ],
      ),
    );
  }
}
