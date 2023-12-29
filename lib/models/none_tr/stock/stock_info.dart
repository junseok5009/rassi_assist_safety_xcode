import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

///
class StockInfo {
  final String stockCode;
  final String stockName;
  final String flag;
  final String tradeDate;
  final String tradeTime;
  final String tradePrc;
  final String profitRate;
  final String elapsedDays;
  final String statusDesc;

  StockInfo({
    this.stockCode = '',
      this.stockName = '',
      this.flag = '',
      this.tradeDate = '',
      this.tradeTime = '',
      this.tradePrc = '',
      this.profitRate = '',
      this.elapsedDays = '',
      this.statusDesc = '',
  });

  factory StockInfo.fromJson(Map<String, dynamic> json) {
    return StockInfo(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      flag: json['tradeFlag'],
      tradeDate: json['tradeDate'],
      tradeTime: json['tradeTime'],
      tradePrc: json['tradePrice'],
      profitRate: json['profitRate'] ?? '',
      elapsedDays: json['elapsedDays'] ?? '',
      statusDesc: json['statusDesc'] ?? '',
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$flag';
  }
}

//종목정보 기본형 ???
class TileStockInfo extends StatelessWidget {
  final appGlobal = AppGlobal();
  final StockInfo item;
  final bool isPremium;

  TileStockInfo(this.item, this.isPremium);

  @override
  Widget build(BuildContext context) {
    String timeStr = item.tradeDate + item.tradeTime;
    String divStr = '';
    if (item.flag == 'B') divStr = '매수가';
    if (item.flag == 'S') divStr = '매도가';

    return Container(
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: UIStyle.boxRoundLine15(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        TStyle.getLimitString(item.stockName, 8),
                        style: TStyle.commonTitle,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        item.stockCode,
                        style: TStyle.textSGrey,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    TStyle.getDateTdFormat(timeStr),
                    style: TStyle.contentGrey14,
                  ),
                ],
              ),
              Visibility(
                visible: isPremium,
                child: Row(
                  children: [
                    Text(
                      '$divStr ',
                      style: TStyle.textGrey15,
                    ),
                    Text(
                      TStyle.getMoneyPoint(item.tradePrc),
                      style: TStyle.commonTitle,
                    ),
                    const Text(
                      '원',
                      style: TStyle.textGrey15,
                    )
                  ],
                ),
              ),
              Visibility(
                visible: !isPremium,
                child: const Text(
                  '종목홈에서 라씨 매매비서\n신호를 확인해 보세요!',
                  textAlign: TextAlign.end,
                  style: TStyle.textSGrey,
                ),
              ),
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
      ),
    );
  }
}
