import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/main/base_page.dart';


/// 2022.01.24
/// 큰손들의 종목캐치
class TrStkCatch01 {
  final String retCode;
  final String retMsg;
  final StkCatch01 retData;

  TrStkCatch01({this.retCode = '', this.retMsg = '', this.retData = defStkCatch01});

  factory TrStkCatch01.fromJson(Map<String, dynamic> json) {
    return TrStkCatch01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: StkCatch01.fromJson(json['retData']),
    );
  }
}

const defStkCatch01 = StkCatch01();
//
class StkCatch01 {
  final String selectDiv;
  final List<TimelineCatch> timeList;

  const StkCatch01({
    this.selectDiv = '',
    this.timeList = const [],
  });

  factory StkCatch01.fromJson(Map<String, dynamic> json) {
    var list = json['list_Timeline'] as List;
    List<TimelineCatch> rtList =
        list.map((i) => TimelineCatch.fromJson(i)).toList();

    return StkCatch01(
      selectDiv: json['selectDiv'],
      timeList: rtList,
    );
  }
}

class TimelineCatch {
  final String tradeDate; //20220121
  final List<CatchSigInfo> sigList;

  TimelineCatch({
    this.tradeDate = '',
    this.sigList = const [],
  });

  factory TimelineCatch.fromJson(Map<String, dynamic> json) {
    var list = json['list_Signal'] as List;
    List<CatchSigInfo> rtList =
        list.map((i) => CatchSigInfo.fromJson(i)).toList();

    return TimelineCatch(
      tradeDate: json['tradeDate'],
      sigList: rtList,
    );
  }
}

class CatchSigInfo {
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String tradeDate;
  final String tradeTime;
  final String tradePrice;
  final String tradeVol;
  final String tradeDays;

  CatchSigInfo(
      {this.stockCode = '',
      this.stockName = '',
      this.tradeFlag = '',
      this.tradeDate = '',
      this.tradeTime = '',
      this.tradePrice = '',
      this.tradeVol = '',
      this.tradeDays = ''
      });

  factory CatchSigInfo.fromJson(Map<String, dynamic> json) {
    return CatchSigInfo(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      tradeFlag: json['tradeFlag'],
      tradeDate: json['tradeDate'],
      tradeTime: json['tradeTime'],
      tradePrice: json['tradePrice'],
      tradeVol: json['tradeVol'],
      tradeDays: json['tradeDays'],
    );
  }
}

//화면구성 - 종목캐치 상세
class TileStkCatch01 extends StatelessWidget {
  final CatchSigInfo item;
  final String div;

  const TileStkCatch01.gen(this.item, this.div, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isToday = item.tradeDate == TStyle.getTodayString();
    return InkWell(
      splashColor: Colors.deepPurpleAccent.withAlpha(30),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          vertical: 7,
          horizontal: 15,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 25,
        ),
        decoration: isToday
            ? UIStyle.boxRoundLine6LineColor(RColor.mainColor,)
            : UIStyle.boxRoundLine6bgColor(
                Colors.white,
              ),
        child: Column(
          children: [
            _setStockInfo(),
            const SizedBox(
              height: 15.0,
            ),
            _setCompareView(),
          ],
        ),
      ),
      onTap: () {
        basePageState.goStockHomePage(
          item.stockCode,
          item.stockName,
          Const.STK_INDEX_SIGNAL,
        );
      },
    );
  }

  //종목명, 종목코드
  Widget _setStockInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          item.stockName,
          style: TStyle.title18T,
        ),
        const SizedBox(
          width: 3,
        ),
        Text(
          item.stockCode,
          style: TStyle.textMGrey,
        ),
      ],
    );
  }

  Widget _setCompareView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                width: 130,
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                decoration: const BoxDecoration(
                  color: RColor.jinbora,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                child: const Center(
                  child: Text(
                    '라씨 매수',
                    style: TStyle.btnTextWht15,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    TStyle.getMoneyPoint(item.tradePrice),
                    style: TStyle.title20,
                  ),
                  const Text('원', style: TStyle.content17T),
                ],
              ),
              Text(
                TStyle.getDateTdFormat(item.tradeDate + item.tradeTime),
                style: TStyle.content17T,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              _setBtnTitle(div, Colors.orange),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    TStyle.getMoneyPoint(item.tradeVol),
                    style: TStyle.title20,
                  ),
                  Text('주', style: TStyle.content17T),
                ],
              ),
              FittedBox(
                child: Text(
                  '${item.tradeDays}일 연속 순매수',
                  style: TStyle.content17T,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 버튼 형태의 타이틀
  Widget _setBtnTitle(String bTitle, Color color) {
    String title = '';
    if (bTitle == 'FRN') {
      title = '외국인매수';
    } else if (bTitle == 'ORG') {
      title = '기관매수';
    }

    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Center(
        child: Text(
          title,
          style: TStyle.btnTextWht15,
        ),
      ),
    );
  }
}

//화면구성 - 종목캐치 메인
class TileStkCatch01M extends StatelessWidget {
  final CatchSigInfo item;
  final String div;

  const TileStkCatch01M.gen(this.item, this.div, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          vertical: 7,
          horizontal: 15,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 25,
        ),
        decoration: UIStyle.boxRoundLine6bgColor(
          Colors.white,
        ),
        child: Column(
          children: [
            _setStockInfo(),
            const SizedBox(
              height: 15.0,
            ),
            _setCompareView(),
          ],
        ),
      ),
      onTap: () {
        basePageState.goStockHomePage(
          item.stockCode,
          item.stockName,
          Const.STK_INDEX_SIGNAL,
        );
      },
    );
  }

  //종목명, 종목코드
  Widget _setStockInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          TStyle.getLimitString(item.stockName, 18),
          style: TStyle.title18T,
        ),
        const SizedBox(
          width: 3,
        ),
        Text(
          item.stockCode,
          style: TStyle.textMGrey,
        ),
      ],
    );
  }

  Widget _setCompareView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                width: 130,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                decoration: const BoxDecoration(
                  color: RColor.jinbora,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                child: const Center(
                  child: Text(
                    '라씨 매수',
                    style: TStyle.btnTextWht15,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    TStyle.getMoneyPoint(item.tradePrice),
                    style: TStyle.title20,
                  ),
                  const Text('원', style: TStyle.content17T),
                ],
              ),
              Text(
                TStyle.getDateTdFormat(item.tradeDate + item.tradeTime),
                style: TStyle.content17T,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              _setBtnTitle(div, Colors.orange),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    TStyle.getMoneyPoint(item.tradeVol),
                    style: TStyle.title20,
                  ),
                  const Text('주', style: TStyle.content17T),
                ],
              ),
              FittedBox(
                child: Text(
                  '${item.tradeDays}일 연속 순매수',
                  style: TStyle.content17T,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 버튼 형태의 타이틀
  Widget _setBtnTitle(String bTitle, Color color) {
    String title = '';
    if (bTitle == 'FRN') {
      title = '외국인매수';
    } else if (bTitle == 'ORG') {
      title = '기관매수';
    }

    return Container(
      width: 130,
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(const Radius.circular(20.0)),
      ),
      child: Center(
        child: Text(
          title,
          style: TStyle.btnTextWht15,
        ),
      ),
    );
  }
}
