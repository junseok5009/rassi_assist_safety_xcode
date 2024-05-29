import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/ui/main/base_page.dart';


/// 소셜지수 HOT 조회
class TrSns03 {
  final String retCode;
  final String retMsg;
  final List<Sns03> listData;

  TrSns03({
    this.retCode = '',
    this.retMsg = '',
    this.listData = const [],
  });

  factory TrSns03.fromJson(Map<String, dynamic> json) {
    var jsonList = json['retData'];
    return TrSns03(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: jsonList == null ? [] : (jsonList as List).map((i) => Sns03.fromJson(i)).toList(),
    );
  }
}

class Sns03 {
  final String stockCode;
  final String stockName;
  final String elapsedTmTx;
  final String fluctuationRate;

  Sns03({
    this.stockCode = '',
    this.stockName = '',
    this.elapsedTmTx = '',
    this.fluctuationRate = '',
  });

  factory Sns03.fromJson(Map<String, dynamic> json) {
    return Sns03(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      elapsedTmTx: json['elapsedTmTx'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
    );
  }
}

//화면구성
class TileSns03 extends StatelessWidget {
  final appGlobal = AppGlobal();
  final Sns03 item;

  TileSns03(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String tm = item.elapsedTmTx;
    return Container(
      width: double.infinity,
      height: 70,
      margin: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 10.0,
      ),
      alignment: Alignment.centerLeft,
      decoration: UIStyle.boxRoundLine6bgColor(Colors.white,),
      child: InkWell(
        // splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: double.infinity,
          height: 70,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    item.stockName,
                    style: TStyle.title17,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    item.stockCode,
                    style: TStyle.textSGrey,
                  ),
                ],
              ),
              Text(
                '$tm시간전\n폭발',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: RColor.socialList,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        onTap: () {
          // 종목홈
          basePageState.goStockHomePage(
            item.stockCode,
            item.stockName,
            Const.STK_INDEX_HOME,
          );
        },
      ),
    );
  }
}
