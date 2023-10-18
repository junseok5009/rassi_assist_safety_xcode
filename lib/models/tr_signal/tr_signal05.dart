import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/ui_style.dart';


/// 2020.09.07
/// 오늘의 매매신호 현황
class TrSignal05 {
  final String retCode;
  final String retMsg;
  final Signal05 retData;

  TrSignal05({this.retCode = '', this.retMsg = '', this.retData = defSignal05});

  factory TrSignal05.fromJson(Map<String, dynamic> json) {
    return TrSignal05(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData:
      json['retData'] != null ? Signal05.fromJson(json['retData']) : defSignal05,
    );
  }
}

const defSignal05 = Signal05();

class Signal05 {
  final String updateDttm;
  final String buyCount;
  final String sellCount;
  final List<SignalData>? listSignal;
  final List<HonorData> listHonor;

  const Signal05({
    this.updateDttm = '',
    this.buyCount = '',
    this.sellCount = '',
    this.listSignal,
    this.listHonor = const [],
  });

  factory Signal05.fromJson(Map<String, dynamic> json) {
    var list = json['list_Signal'] as List;
    List<SignalData> listData =
        list == null ? [] : list.map((e) => SignalData.fromJson(e)).toList();

    var honorlist = json['list_HonorStock'] as List;
    List<HonorData> hlistData = honorlist == null
        ? []
        : honorlist.map((e) => HonorData.fromJson(e)).toList();

    return Signal05(
      updateDttm: json['updateDttm'],
      buyCount: json['buyCount'],
      sellCount: json['sellCount'],
      listSignal: listData,
      listHonor: hlistData,
    );
  }
}

class SignalData {
  final String tradeTime;
  final String tradeFlag;
  final String tradeCount;

  SignalData({
    this.tradeTime = '', this.tradeFlag = '', this.tradeCount = ''
  });

  factory SignalData.fromJson(Map<String, dynamic> json) {
    return SignalData(
        tradeTime: json['tradeTime'],
        tradeFlag: json['tradeFlag'],
        tradeCount: json['tradeCount']);
  }

  @override
  String toString() {
    return '$tradeTime| $tradeFlag| $tradeCount';
  }
}

class HonorData {
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String tradeTime;
  final String honorDiv;

  HonorData({
    this.stockCode = '',
      this.stockName = '',
      this.tradeFlag = '',
      this.tradeTime = '',
      this.honorDiv = ''
  });

  factory HonorData.fromJson(Map<String, dynamic> json) {
    return HonorData(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      tradeFlag: json['tradeFlag'],
      tradeTime: json['tradeTime'],
      honorDiv: json['honorDiv'] ?? '',
    );
  }

  @override
  String toString() {
    return '$tradeTime| $tradeFlag| $honorDiv';
  }
}

//화면구성
class TileSigStatus extends StatelessWidget {
  final HonorData item;
  const TileSigStatus(this.item, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String strTopImg = 'images/main_hnr_win_trade.png';
    strTopImg = getTopImage(item.honorDiv);
    String topTxt = getTopText(item.honorDiv);
    String desc;
    if (item.tradeFlag == 'B') {
      desc = '새로운 매수 신호 발생';
    } else {
      desc = '새로운 매도 신호 발생';
    }

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: UIStyle.boxRoundFullColor6c(
        RColor.bgWeakGrey,
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Wrap(
          //mainAxisAlignment: MainAxisAlignment.center,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Image.asset(
              strTopImg,
              height: 17,
            ),
            const SizedBox(
              width: 3.0,
            ),
            Text(
              topTxt,
              style: const TextStyle(
                color: RColor.sigBuy,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              '에서',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              width: 3.0,
            ),
            Text(
              desc,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  String getTopText(String topType) {
    if (topType == 'WIN_RATE') return '적중률 TOP';
    if (topType == 'PROFIT_10P') return '수익난 매매 TOP';
    if (topType == 'SUM_PROFIT') return '누적수익률 TOP';
    if (topType == 'MAX_PROFIT') return '최대수익률 TOP';
    if (topType == 'AVG_PROFIT')
      return '평균수익률 TOP';
    else
      return '';
  }

  String getTopImage(String topType) {
    if (topType.length > 0) {
      if (topType == 'WIN_RATE')
        return 'images/main_hnr_win_trade.png';
      else if (topType == 'PROFIT_10P')
        return 'images/main_hnr_avg_ratio.png';
      else if (topType == 'SUM_PROFIT')
        return 'images/main_hnr_max_ratio.png';
      else if (topType == 'MAX_PROFIT')
        return 'images/main_hnr_win_ratio.png';
      else if (topType == 'AVG_PROFIT')
        return 'images/main_hnr_acc_ratio.png';
      else
        return 'images/main_hnr_win_trade.png';
    }
    return '';
  }
}
