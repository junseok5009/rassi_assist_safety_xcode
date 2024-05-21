import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/sub/theme_hot_viewer.dart';

/// 2022.05.11
/// 월간 Monthly 테마 리스트 조회
class TrTheme03 {
  final String retCode;
  final String retMsg;
  final List<Theme03> retData;

  TrTheme03({this.retCode = '', this.retMsg = '', this.retData = const []});

  factory TrTheme03.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] == null ? [] : json['retData'] as List;
    List<Theme03>? rtList;
    if (list != null) rtList = list.map((i) => Theme03.fromJson(i)).toList();

    return TrTheme03(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: list.map((i) => Theme03.fromJson(i)).toList(),
    );
  }
}

class Theme03 {
  final String tradeDate;
  final List<ThemeOb> listData;

  Theme03({this.tradeDate = '', this.listData = const []});

  factory Theme03.fromJson(Map<String, dynamic> json) {
    var list = json['list_Theme'] == null ? [] : json['list_Theme'] as List;
    List<ThemeOb>? rtList;
    if (list != null) rtList = list.map((i) => ThemeOb.fromJson(i)).toList();

    return Theme03(
      tradeDate: json['tradeDate'] ?? '',
      listData: list.map((i) => ThemeOb.fromJson(i)).toList(),
    );
  }
}

//테마 객체
class ThemeOb {
  final String tradeDate;
  final String themeCode;
  final String themeName;
  final String increaseRate;

  ThemeOb({
    this.tradeDate = '',
    this.themeCode = '',
    this.themeName = '',
    this.increaseRate = '',
  });

  factory ThemeOb.fromJson(Map<String, dynamic> json) {
    return ThemeOb(
      tradeDate: json['tradeDate'] ?? '',
      themeCode: json['themeCode'] ?? '',
      themeName: json['themeName'] ?? '',
      increaseRate: json['increaseRate'] ?? '',
    );
  }

  @override
  String toString() {
    return '$themeCode|$themeName|$increaseRate';
  }
}

//화면구성
class TileTheme03 extends StatelessWidget {
  final Theme03 item;

  const TileTheme03(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ThemeOb>? subList = item.listData;
    return Container(
      width: double.infinity,
      // height: 200,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: UIStyle.boxRoundLine6(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Image.asset(
                    'images/rassi_itemar_icon_ar1.png',
                    width: 20,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    TStyle.getDateMdKorFormat(item.tradeDate),
                    style: const TextStyle(
                      fontSize: 16,
                      color: RColor.bgBuy,
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: item.tradeDate == TStyle.getTodayString(),
                child: const Chip(
                  label: Text(
                    ' TODAY ',
                    style: TStyle.btnTextWht14,
                  ),
                  backgroundColor: RColor.bgBuy,
                ),
              )
            ],
          ),
          const SizedBox(height: 15),

          // 테마리스트 New
          _setThemeBox(subList),

/*        // 테마리스트 Old
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: subList.length,
          itemBuilder: (context, index) {
            return Container(
              width: double.infinity,
              height: 70,
              decoration: UIStyle.boxRoundLine6(),
              margin: const EdgeInsets.only(
                top: 10.0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TStyle.getLimitString(subList[index].themeName, 10),
                      style: TStyle.title18T,
                    ),
                    Text(
                      TStyle.getPercentString(
                        subList[index].increaseRate,
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        color: TStyle.getMinusPlusColor(
                          subList[index].increaseRate,
                        ),
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  ],
                ),
                onTap: () {
                  basePageState.callPageRouteUpData(
                    const ThemeHotViewer(),
                    PgData(userId: '', pgSn: subList[index].themeCode),
                  );
                },
              ),
            );
          },
        ),*/
        ],
      ),
    );
  }

  //
  Widget _setThemeBox(List<ThemeOb> subList) {
    ThemeOb? item1 = subList[0];
    ThemeOb? item2 = subList[1];
    ThemeOb? item3 = subList[2];
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        height: 100,
        child: Row(
          children: [
            if (item1 != null) _setInfoBox(item1),
            if (item2 != null) _setInfoBox(item2),
            if (item3 != null) _setInfoBox(item3),
          ],
        ),
      ),
    );
  }

  //
  Widget _setInfoBox(ThemeOb tItem) {
    String rText;
    Color rColor;
    if (tItem.increaseRate.contains('-')) {
      rText = tItem.increaseRate;
      rColor = RColor.sigSell;
    } else {
      rText = '+${tItem.increaseRate}';
      rColor = RColor.sigBuy;
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: UIStyle.boxWeakGrey6(),
        child: InkWell(
          splashColor: Colors.deepPurpleAccent.withAlpha(30),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tItem.themeName,
                  style: TStyle.subTitle,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
                Text(
                  '$rText%',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: rColor,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            basePageState.callPageRouteUpData(
              const ThemeHotViewer(),
              PgData(userId: '', pgSn: tItem.themeCode),
            );
          },
        ),
      ),
    );
  }
}
