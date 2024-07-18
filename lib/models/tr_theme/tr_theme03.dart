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
    var jsonList = json['retData'];
    return TrTheme03(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: jsonList == null ? [] : (jsonList as List).map((i) => Theme03.fromJson(i)).toList(),
    );
  }
}

class Theme03 {
  final String tradeDate;
  final List<ThemeOb> listData;

  Theme03({this.tradeDate = '', this.listData = const []});

  factory Theme03.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Theme'];
    return Theme03(
      tradeDate: json['tradeDate'] ?? '',
      listData: jsonList == null ? [] : (jsonList as List).map((i) => ThemeOb.fromJson(i)).toList(),
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
    List<ThemeOb> subList = item.listData;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      // padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      // decoration: UIStyle.boxRoundLine6(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 5),
              //   visible: item.tradeDate == TStyle.getTodayString(),
              Text(
                item.tradeDate == TStyle.getTodayString()
                    ? '${TStyle.getDateDivFormat(item.tradeDate)} 오늘'
                    : TStyle.getDateDivFormat(item.tradeDate),
                style: TextStyle(
                  fontSize: 16,
                  color: item.tradeDate == TStyle.getTodayString() ? RColor.mainColor : RColor.greyBasic_8c8c8c,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 테마리스트 New
          _setThemeBox(subList),
        ],
      ),
    );
  }

  Widget _setThemeBox(List<ThemeOb> subList) {
    return SizedBox(
      width: double.infinity,
      height: 110,
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: subList.isEmpty ? const SizedBox() : _setInfoBox(subList.first),
            ),
          ),
          Expanded(
            child: Container(
              child: subList.length > 1 ? _setInfoBox(subList[1]) : const SizedBox(),
            ),
          ),
          Expanded(
            child: Container(
              child: subList.length > 2 ?  _setInfoBox(subList.last) : const SizedBox(),
            ),
          ),
        ],
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

    return Container(
      margin: const EdgeInsets.all(5),
      decoration: UIStyle.boxShadowBasic(16),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tItem.themeName,
                style: TStyle.content16T,
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
    );
  }
}
