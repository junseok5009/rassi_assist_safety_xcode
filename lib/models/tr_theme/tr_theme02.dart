import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/theme_info.dart';
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
      retData:
          json['retData'] == null ? defTheme02 : Theme02.fromJson(json['retData']),
    );
  }
}


const defTheme02 = Theme02();

class Theme02 {
  final String startDate;
  final String endDate;
  final List<ThemeInfo> listData;

  const Theme02({this.startDate = '', this.endDate = '', this.listData = const []});

  factory Theme02.fromJson(Map<String, dynamic> json) {
    var list = json['list_Theme'] as List;
    // List<ThemeInfo>? rtList;
    // if (list != null) rtList = list.map((i) => ThemeInfo.fromJson(i)).toList();

    return Theme02(
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      listData: list.map((i) => ThemeInfo.fromJson(i)).toList(),
    );
  }
}

//화면구성 - 테마리스트 HOT3 Swiper
class TileTheme02 extends StatelessWidget {
  final ThemeInfo item;
  final String topIdx;

  const TileTheme02(this.item, this.topIdx, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          height: 230,
          margin: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          //decoration: UIStyle.boxRoundLine6(),
          child: _setThemeContainer(),
        ),
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
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
        image: DecorationImage(
          image: NetworkImage(RString.themeDefaultUrl),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 180.0,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              image: DecorationImage(
                image: _setNetworkImage(item.themeCode),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(6.0)),
              color: const Color(0xbb121212).withOpacity(0.45),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      child: Text(
                        ' TOP$topIdx ',
                        style: TStyle.btnTextWht14,
                      ),
                    ),
                  ],
                ),

                // 하단 테마에 속한 3종목
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: RColor.mainColor,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  child: Wrap(
                    spacing: 7.0,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                      item.listStock.length,
                      (index) => InkWell(
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          // color: RColor.bgWeakGrey,
                          child: Text(
                            ' ${TStyle.getLimitString(item.listStock[index].stockName, 7)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xffEFEFEF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${item.themeName} 테마',
                  style: TStyle.btnTextWht20,
                ),
                const SizedBox(
                  height: 3.0,
                ),
                Text(
                  '$rText%',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    color: rColor,
                  ),
                ),
              ],
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
      return const NetworkImage(
          'http://files.thinkpool.com/rassi_signal/theme_images/0000.jpg');
    }
  }
}
