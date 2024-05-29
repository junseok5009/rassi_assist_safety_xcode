import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/theme_top_data.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/sub/theme_hot_viewer.dart';

/// 2022.02.08
/// -->(05.10 변경) 주간 Weekly HOT 테마 조회
class TrTheme02 {
  final String retCode;
  final String retMsg;
  final Theme02 retData;

  TrTheme02({this.retCode = '', this.retMsg = '', this.retData = defTheme02});

  factory TrTheme02.fromJson(Map<String, dynamic> json) {
    return TrTheme02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defTheme02 : Theme02.fromJson(json['retData']),
    );
  }
}

const defTheme02 = Theme02();

class Theme02 {
  final String startDate;
  final String endDate;
  final List<ThemeTopData> listData;

  const Theme02({this.startDate = '', this.endDate = '', this.listData = const []});

  factory Theme02.fromJson(Map<String, dynamic> json) {
    var list = json['list_Theme'] as List;
    // List<ThemeInfo>? rtList;
    // if (list != null) rtList = list.map((i) => ThemeInfo.fromJson(i)).toList();

    return Theme02(
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      listData: list.map((i) => ThemeTopData.fromJson(i)).toList(),
    );
  }
}

//화면구성 - 테마리스트 HOT3 Swiper
class TileTheme02 extends StatelessWidget {
  final ThemeTopData item;
  final String topIdx;

  const TileTheme02(this.item, this.topIdx, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        decoration: UIStyle.boxShadowBasic(16),
        child: _setThemeContainer(),
      ),
      onTap: () {
        basePageState.callPageRouteUpData(
          const ThemeHotViewer(),
          PgData(userId: '', pgSn: item.themeCode),
        );
      },
    );
  }

  Widget _setThemeContainer() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.themeName} 테마',
                style: TStyle.title17,
              ),
              const SizedBox(height: 3),
              Text(
                TStyle.getPercentString(item.increaseRate),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: TStyle.getMinusPlusColor(item.increaseRate),
                ),
              ),
            ],
          ),

          //Top3 종목 리스트
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: UIStyle.boxWeakGrey10(),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: item.listStock.length,
              itemBuilder: (BuildContext context, int index) {
                return TileThemeTop(item.listStock[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  //네트워크 이미지
  ImageProvider _setNetworkImage(String tCode) {
    var tmp = 'http://files.thinkpool.com/rassi_signal/theme_images/$tCode.jpg';
    try {
      ImageProvider img = NetworkImage(tmp);
      return img;
    } on Exception catch (_) {
      // DLog.d(ThemeHotViewer.TAG, 'ERR : Exception');
      return const NetworkImage('http://files.thinkpool.com/rassi_signal/theme_images/0000.jpg');
    }
  }
}

//화면구성 - Top3 종목 리스트
class TileThemeTop extends StatelessWidget {
  final StockTopData stockInfo;

  const TileThemeTop(this.stockInfo, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(15, 7, 15, 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        TStyle.getLimitString(stockInfo.stockName, 8),
                        style: TStyle.content17T,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        stockInfo.stockCode,
                        style: TStyle.contentGrey13,
                      ),
                    ],
                  ),

                  //주간 등락률
                  CommonView.setFluctuationRateBox(value: stockInfo.increaseRate, fontSize: 14),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        basePageState.goStockHomePage(
          stockInfo.stockCode,
          stockInfo.stockName,
          Const.STK_INDEX_HOME,
        );
      },
    );
  }
}
