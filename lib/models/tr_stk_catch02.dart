import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

/// 2022.01.25
/// 성과 TOP 종목캐치
class TrStkCatch02 {
  final String retCode;
  final String retMsg;
  final StkCatch02 retData;

  TrStkCatch02({this.retCode = '', this.retMsg = '', this.retData = defStkCatch02});

  factory TrStkCatch02.fromJson(Map<String, dynamic> json) {
    return TrStkCatch02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData:
          json['retData'] != null ? StkCatch02.fromJson(json['retData']) : defStkCatch02,
    );
  }
}

const defStkCatch02 = StkCatch02();
//
class StkCatch02 {
  final String selectDiv;
  final String tradeFlag;
  final String periodMonth;
  final List<CatchStock> stkList;

  const StkCatch02({
    this.selectDiv = '',
    this.tradeFlag = '',
    this.periodMonth = '',
    this.stkList = const [],
  });

  factory StkCatch02.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    List<CatchStock> rtList;
    list == null
        ? rtList = []
        : rtList = list.map((i) => CatchStock.fromJson(i)).toList();

    return StkCatch02(
      selectDiv: json['selectDiv'],
      tradeFlag: json['tradeFlag'],
      periodMonth: json['periodMonth'],
      stkList: rtList,
    );
  }
}

class CatchStock {
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String avgProfitRate;
  final String sumProfitRate;
  final String winningRate;
  final String winCount;

  CatchStock({
    this.stockCode = '',
    this.stockName = '',
    this.tradeFlag = '',
    this.avgProfitRate = '',
    this.sumProfitRate = '',
    this.winningRate = '',
    this.winCount = '',
  });

  factory CatchStock.fromJson(Map<String, dynamic> json) {
    return CatchStock(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      tradeFlag: json['tradeFlag'],
      avgProfitRate: json['avgProfitRate'] ?? '',
      sumProfitRate: json['sumProfitRate'] ?? '',
      winningRate: json['winningRate'] ?? '',
      winCount: json['winCount'] ?? '',
    );
  }
}

//화면구성 - 종목캐치 메인
class TileStkCatch02 extends StatelessWidget {
  final CatchStock item;
  const TileStkCatch02(this.item, {Key? key}) : super(key: key);
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
    String sSign = '+';
    String sRate = '';
    String postfix = '%';
    if (item.avgProfitRate.isNotEmpty) {
      sRate = item.avgProfitRate;
    } else if (item.sumProfitRate.isNotEmpty) {
      sRate = item.sumProfitRate;
    } else if (item.winCount.isNotEmpty) {
      sRate = item.winCount;
      sSign = '';
      postfix = '번';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //적중률 최근1년
        Expanded(
          child: Column(
            children: [
              _setBtnHit(),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    item.winningRate,
                    style: TStyle.title20,
                  ),
                  const Text(
                    '%',
                    style: TStyle.content17T,
                  ),
                ],
              ),
              const Text(
                '최근 3년',
                style: TStyle.content17T,
              ),
            ],
          ),
        ),

        Expanded(
          child: Column(
            children: [
              _setBtnTitle(
                  item.avgProfitRate, item.sumProfitRate, item.winCount),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    sSign,
                    style: TStyle.content17T,
                  ),
                  Text(
                    sRate,
                    style: TStyle.title20,
                  ),
                  Text(
                    postfix,
                    style: TStyle.content17T,
                  ),
                ],
              ),
              const Text(
                '최근 3년',
                style: TStyle.content17T,
              ),
            ],
          ),
        ),
      ],
    );
  }


  // 버튼 형태의 타이틀
  Widget _setBtnTitle(
    String avgRate,
    String sumRate,
    String winCount,
  ) {
    String title = '';
    if (avgRate.isNotEmpty)
      title = '평균수익률';
    else if (sumRate.isNotEmpty)
      title = '누적수익률';
    else if (winCount.isNotEmpty) title = '수익난 매매';

    return Container(
      width: 115,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Center(
        child: Text(
          title,
          style: TStyle.btnTextWht15,
        ),
      ),
    );
  }

  //적중률 타이틀
  Widget _setBtnHit() {
    return Container(
      width: 115,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: const BoxDecoration(
        color: RColor.jinbora,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: const Center(
        child: Text(
          '적중률',
          style: TStyle.btnTextWht15,
        ),
      ),
    );
  }
}
