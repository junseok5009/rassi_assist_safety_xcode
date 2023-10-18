import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/main/base_page.dart';


/// 2022.05.19
/// 이 시간 종목캐치
class TrStkCatch03 {
  final String retCode;
  final String retMsg;
  final List<StkCatch03> retData;

  TrStkCatch03({this.retCode = '', this.retMsg = '', this.retData = const []});

  factory TrStkCatch03.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<StkCatch03> rtList;
    list == null
        ? rtList = []
        : rtList = list.map((i) => StkCatch03.fromJson(i)).toList();

    return TrStkCatch03(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: rtList,
    );
  }
}

const defStkCatch03 = StkCatch03();
//
class StkCatch03 {
  final String contentDiv;
  final List<StockDiv> stkList;

  const StkCatch03({
    this.contentDiv = '',
    this.stkList = const [],
  });

  factory StkCatch03.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    List<StockDiv> rtList;
    list == null
        ? rtList = []
        : rtList = list.map((i) => StockDiv.fromJson(i)).toList();

    return StkCatch03(
      contentDiv: json['contentDiv'],
      stkList: rtList,
    );
  }
}

class StockDiv {
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String selectDiv;

  StockDiv({
    this.stockCode = '',
    this.stockName = '',
    this.tradeFlag = '',
    this.selectDiv = '',
  });

  factory StockDiv.fromJson(Map<String, dynamic> json) {
    return StockDiv(
      stockCode: json['stockCode'],
      stockName: json['stockName'] ?? '',
      tradeFlag: json['tradeFlag'] ?? '',
      selectDiv: json['selectDiv'] ?? '',
    );
  }
}

//화면구성 - 이시간 종목캐치 (2종목씩 플리킹)
class TileStkCatch03 extends StatelessWidget {
  final StkCatch03 catch03;

  const TileStkCatch03(this.catch03, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // height: 220,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _setThemeBox(
            catch03.stkList[0],
            catch03.stkList.length > 1 ? catch03.stkList[1] : null,
          )
        ],
      ),
    );
  }

  Widget _setThemeBox(
    StockDiv? item1,
    StockDiv? item2,
  ) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        height: 190,
        child: Row(
          children: [
            if (item1 != null) _setInfoBox(item1),
            item2 != null ? _setInfoBox(item2) : _setEmptyBox(),
          ],
        ),
      ),
    );
  }

  Widget _setEmptyBox() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 5),
        decoration: UIStyle.boxRoundLine6(),
        child: Container(
          padding: const EdgeInsets.all(9.0),
          child: const Center(
            child: Text(
              '발생한 종목이 없습니다.',
              style: TStyle.textGreyDefault,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _setInfoBox(
    StockDiv tItem,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 5),
        decoration: UIStyle.boxRoundLine6(),
        child: InkWell(
          splashColor: Colors.deepPurpleAccent.withAlpha(30),
          child: Container(
            padding: const EdgeInsets.all(9.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _setCardStock(
                    tItem.stockName, tItem.selectDiv, tItem.tradeFlag),

                //파트별 아이콘
                _setCardIcons(
                  tItem.selectDiv,
                ),
              ],
            ),
          ),
          onTap: () {
            basePageState.goStockHomePage(
              tItem.stockCode,
              tItem.stockName,
              Const.STK_INDEX_SIGNAL,
            );
          },
        ),
      ),
    );
  }

  Widget _setCardStock(String stkName, String div, String flag) {
    String fText = '';
    if (flag == 'B') {
      fText = '매수';
    } else {
      fText = '매도';
    }

    if (div == 'FRN') {
      return Column(
        children: [
          const Text(
            '라씨 매매비서와\n외국인이',
            style: TStyle.defaultContent,
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  stkName,
                  style: TStyle.puplePlain17(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                TStyle.getJustPostWord(stkName, '을', '를'),
                style: TStyle.defaultContent,
              ),
            ],
          ),
          Text(
            '함께 $fText 했습니다.',
            style: TStyle.defaultContent,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      );
    } else if (div == 'ORG') {
      return Column(
        children: [
          const Text(
            '라씨 매매비서와\n기관이',
            style: TStyle.defaultContent,
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  stkName,
                  style: TStyle.puplePlain17(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                TStyle.getJustPostWord(stkName, '을', '를'),
                style: TStyle.defaultContent,
              ),
            ],
          ),
          Text(
            '함께 $fText 했습니다.',
            style: TStyle.defaultContent,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      );
    } else if (div == 'AVG') {
      return Column(
        children: [
          const Text(
            '적중률과 평균\n수익률이 모두 높은',
            style: TStyle.defaultContent,
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  stkName,
                  style: TStyle.puplePlain17(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                TStyle.getJustPostWord(stkName, '을', '를'),
                style: TStyle.defaultContent,
              ),
            ],
          ),
          Text(
            '$fText 하였습니다.',
            style: TStyle.defaultContent,
          ),
        ],
      );
    } else if (div == 'SUM') {
      return Column(
        children: [
          const Text(
            '적중률과 누적\n수익률이 모두 높은',
            style: TStyle.defaultContent,
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  TStyle.getLimitString(stkName, 10),
                  style: TStyle.puplePlain17(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                TStyle.getJustPostWord(stkName, '을', '를'),
                style: TStyle.defaultContent,
              ),
            ],
          ),
          Text(
            '$fText 하였습니다.',
            style: TStyle.defaultContent,
          ),
        ],
      );
    } else if (div == 'WIN') {
      return Column(
        children: [
          const Text(
            '적중률과 수익난\n매매횟수가 모두 높은',
            style: TStyle.defaultContent,
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  stkName,
                  style: TStyle.puplePlain17(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                TStyle.getJustPostWord(stkName, '을', '를'),
                style: TStyle.defaultContent,
              ),
            ],
          ),
          Text(
            '$fText 하였습니다.',
            style: TStyle.defaultContent,
          ),
        ],
      );
    }

    return const Text('');
  }

  Widget _setCardIcons(String div) {
    if (div == 'FRN') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/logo_circle_icon.png',
            fit: BoxFit.cover,
            scale: 6,
          ),
          const SizedBox(
            width: 7,
          ),
          Image.asset(
            'images/img_foreigner_b.png',
            fit: BoxFit.cover,
            scale: 4,
          ),
        ],
      );
    } else if (div == 'ORG') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/logo_circle_icon.png',
            fit: BoxFit.cover,
            scale: 6,
          ),
          const SizedBox(
            width: 7,
          ),
          Image.asset(
            'images/img_inst.png',
            fit: BoxFit.cover,
            scale: 4,
          ),
        ],
      );
    } else if (div == 'AVG') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/main_hnr_avg_ratio.png',
            fit: BoxFit.cover,
            scale: 7,
          ),
          const SizedBox(
            width: 7,
          ),
          Image.asset(
            'images/main_hnr_win_ratio.png',
            fit: BoxFit.cover,
            scale: 7,
          ),
        ],
      );
    } else if (div == 'SUM') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/main_hnr_acc_ratio.png',
            fit: BoxFit.cover,
            scale: 7,
          ),
          const SizedBox(
            width: 7,
          ),
          Image.asset(
            'images/main_hnr_win_ratio.png',
            fit: BoxFit.cover,
            scale: 7,
          ),
        ],
      );
    } else if (div == 'WIN') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/main_hnr_win_trade.png',
            fit: BoxFit.cover,
            scale: 7,
          ),
          const SizedBox(
            width: 7,
          ),
          Image.asset(
            'images/main_hnr_win_ratio.png',
            fit: BoxFit.cover,
            scale: 7,
          ),
        ],
      );
    }

    return const Text('');
  }
}
