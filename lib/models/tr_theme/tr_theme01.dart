import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_atom.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/test/theme_viewer.dart';


/// 2022.01.10
/// 테마 전체리스트 조회
class TrTheme01 extends TrAtom {
  final List<Theme01> listData;

  TrTheme01({
    String retCode = '',
    String retMsg = '',
    this.listData = const [],
  }) : super(retCode: retCode, retMsg: retMsg);

  factory TrTheme01.fromJson(Map<String, dynamic> json) {
    var list = json['retData']['list_Theme'] as List;
    // List<Theme01>? rtList;
    // list == null ? rtList = null : rtList = list.map((i) => Theme01.fromJson(i)).toList();

    return TrTheme01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: list.map((i) => Theme01.fromJson(i)).toList(),
    );
  }
}

class Theme01 {
  final String themeCode;
  final String themeName;
  final String totalCount;
  final String buyCount;
  final String holdCount;
  final String sellCount;
  final String waitCount;
  final String increaseRate;

  Theme01({
    this.themeCode = '',
    this.themeName = '',
    this.totalCount = '',
    this.buyCount = '',
    this.holdCount = '',
    this.sellCount = '',
    this.waitCount = '',
    this.increaseRate = '',
  });

  factory Theme01.fromJson(Map<String, dynamic> json) {
    return Theme01(
      themeCode: json['themeCode'],
      themeName: json['themeName'],
      totalCount: json['totalCount'],
      buyCount: json['buyCount'],
      holdCount: json['holdCount'],
      sellCount: json['sellCount'],
      waitCount: json['waitCount'],
      increaseRate: json['increaseRate'],
    );
  }
}


//화면구성 - 종목캐치 메인 가로 리스트
class TileThemeH01 extends StatelessWidget {
  final Theme01 item;
  TileThemeH01(this.item,);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 8, top: 15, bottom: 15),
      decoration: UIStyle.boxWithOpacity(),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: 135,
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(item.themeName, style: TStyle.defaultTitle,
                maxLines: 1, overflow: TextOverflow.clip,),

              Column(
                children: [
                  Text('신규 매수 신호 발생', style: TextStyle(       //작은 그레이 텍스트
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(item.buyCount, style: TStyle.title22,),
                      const Text('종목', style: TStyle.subTitle,),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        onTap: (){
          basePageState.callPageRouteUpData(ThemeViewer(),
              PgData(userId: '', pgSn: item.themeCode));
        },
      ),
    );
  }
}


//화면구성 - 테마 리스트
class TileTheme01 extends StatelessWidget {
  final Theme01 item;
  final cirSize = 50.0;
  TileTheme01(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      margin: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0,),
      padding: const EdgeInsets.all(10),
      alignment: Alignment.centerLeft,
      decoration: UIStyle.boxWithOpacity(),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Column(
          children: [
            // 테마명 / 오늘 테마 상승률
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(TStyle.getLimitString(item.themeName, 12),
                  style: TStyle.defaultTitle,),

                Row(
                  children: [
                    const Text('오늘 테마 상승률  ', style: TStyle.defaultContent,),
                    _setRateText(),
                    const SizedBox(width: 10,),
                  ],
                )
              ],
            ),
            const SizedBox(height: 10,),

            // 총 00종목 / 매수 보유 매도 관망
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text('총', style: TStyle.defaultContent,),
                    const SizedBox(width: 2,),
                    Text(item.totalCount, style: TStyle.title22,),
                    const SizedBox(width: 2,),
                    const Text('종목', style: TStyle.defaultContent,),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _setCircleText(item.buyCount, RColor.sigBuy, '매수'),
                    _setCircleText(item.holdCount, RColor.bgHolding, '보유'),
                    _setCircleText(item.sellCount, RColor.sigSell, '매도'),
                    _setCircleText(item.waitCount, RColor.sigWatching, '관망'),
                  ],
                ),
              ],
            )
          ],
        ),
        onTap: (){
          basePageState.callPageRouteUpData(ThemeViewer(),
              PgData(userId: '', pgSn: item.themeCode));
        },
      ),
    );
  }


  Widget _setCircleText(String cnt, Color color, String label) {
    return Column(
      children: [
        Container(
          width: cirSize,
          height: cirSize,
          margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle,),
          child: Center(
            child: Text(cnt, style: TStyle.btnTextWht17,),
          ),
        ),
        Text(label, style: TStyle.content16,),
      ],
    );
  }

  Widget _setRateText() {
    Color rateColor;
    String strRate;
    if(item.increaseRate.contains('-')) {
      strRate = item.increaseRate;
      rateColor = RColor.bgSell;
    } else {
      strRate = '+${item.increaseRate}';
      rateColor = RColor.bgBuy;
    }

    return Text('$strRate%', style: TextStyle(fontWeight: FontWeight.w600,
        fontSize: 15, color: rateColor),);
  }

}