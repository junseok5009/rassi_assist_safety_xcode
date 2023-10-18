import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/stock.dart';
import 'package:rassi_assist/models/theme_info.dart';
import 'package:rassi_assist/models/tr_atom.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/sub/theme_hot_viewer.dart';


/// 2022.05.12
/// 이시간 HOT 테마 조회
class TrTheme07 extends TrAtom {
  final Theme07? retData;

  TrTheme07({String retCode = '', String retMsg = '', this.retData})
      : super(retCode: retCode, retMsg: retMsg);

  factory TrTheme07.fromJson(Map<String, dynamic> json) {
    return TrTheme07(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData:
          json['retData'] == null ? null : Theme07.fromJson(json['retData']),
    );
  }
}

class Theme07 {
  final String startDate;
  final String endDate;
  final List<ThemeInfo>? listData;

  Theme07({this.startDate = '', this.endDate = '', this.listData});

  factory Theme07.fromJson(Map<String, dynamic> json) {
    var list = json['list_Theme'] as List;
    List<ThemeInfo>? rtList;
    if (list != null) rtList = list.map((i) => ThemeInfo.fromJson(i)).toList();

    return Theme07(
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      listData: rtList,
    );
  }
}

//화면구성 - (홈_홈) 이시간 핫 테마
class TileTheme07 extends StatelessWidget {
  // final appGlobal = AppGlobal();
  final ThemeInfo item;

  const TileTheme07(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String rText;
    Color rColor;
    if (item.increaseRate.contains('-')) {
      rText = item.increaseRate;
      rColor = RColor.sigSell;
    } else {
      rText = '+${item.increaseRate}';
      rColor = RColor.sigBuy;
    }

    return Container(
      width: double.infinity,
      height: 80,
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
          height: 80,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //테마명
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.themeName,
                    style: TStyle.commonTitle,
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Wrap(
                    spacing: 7.0,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                        item.listStock.length > 2 ? 2 : item.listStock.length,
                        (index) => Text(
                              TStyle.getLimitString(
                                  item.listStock[index].stockName, 10),
                            ),
                    ),
                  ),
                ],
              ),

              //테마 수익률
              Text(
                '$rText%',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: rColor,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        onTap: () {
          //테마 상세페이지 연결
          basePageState.callPageRouteUpData(
              ThemeHotViewer(), PgData(userId: '', pgSn: item.themeCode));
        },
      ),
    );
  }
}

//화면구성(매매비서 페이지)
class TileHotTheme extends StatelessWidget {
  final Stock item;
  final Color bColor;

  TileHotTheme(this.item, this.bColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(
        left: 10,
        right: 8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      decoration: BoxDecoration(
        color: bColor,
        shape: BoxShape.circle,
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: 90,
          child: Center(
            child: Text(
              item.stockName,
              style: TStyle.subTitle,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
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
