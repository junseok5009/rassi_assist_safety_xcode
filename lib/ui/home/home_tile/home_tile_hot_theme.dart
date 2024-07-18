import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_theme/tr_theme08.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/sub/theme_hot_page.dart';
import 'package:rassi_assist/ui/sub/theme_hot_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [홈_홈 이 시간 HOT테마] - 2023.09.11 HJS
class HomeTileHotTheme extends StatefulWidget {
  const HomeTileHotTheme({Key? key}) : super(key: key);

  @override
  State<HomeTileHotTheme> createState() => HomeTileHotThemeState();
}

class HomeTileHotThemeState extends State<HomeTileHotTheme> {
  late SharedPreferences _prefs;
  final AppGlobal _appGlobal = AppGlobal();
  String _userId = '';

  final List<Theme08> _listTheme08 = [];
  int _themeDiv = 0; // 테마명 선택
  int _selectDiv = 0; // 오늘 강세 종목 / 테마 주도주

  initPage() {
    _requestTrTheme08();
    _themeDiv = 0;
    _selectDiv = 0;
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? _appGlobal.userId;
  }

  @override
  void initState() {
    super.initState();
    _loadPrefData().then((_) {
      initPage();
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    //super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '이 시간 HOT 테마',
                style: TStyle.defaultTitle,
              ),
              InkWell(
                onTap: () async {
                  Navigator.pushNamed(
                    context,
                    ThemeHotPage.routeName,
                    arguments: PgData(pgSn: ''),
                  );
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: const Text(
                  '더보기',
                  style: TextStyle(
                    color: RColor.greyMore_999999,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15.0,
          ),
          if (_listTheme08.isEmpty)
            CommonView.setNoDataTextView(150, '현재 HOT 테마가 없습니다.')
          else
            Column(
              children: [
                Row(
                  children: _titleView(),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                _divView(),
                const SizedBox(
                  height: 20.0,
                ),
                _listTheme08[_themeDiv].themeStatus == 'BULL' ||
                        _listTheme08[_themeDiv].themeStatus == 'Bullish' ||
                        _selectDiv == 0
                    ? _listView()
                    : _bearView(),
                const SizedBox(
                  height: 25.0,
                ),
                InkWell(
                  onTap: () {
                    basePageState.callPageRouteUpData(
                      const ThemeHotViewer(),
                      PgData(
                        pgSn: _listTheme08[_themeDiv].themeCode,
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 42,
                    decoration: UIStyle.boxRoundLine6bgColor(
                      Colors.white,
                    ),
                    child: const Center(
                      child: Text(
                        '테마 자세히 보기',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  List<Widget> _titleView() {
    List<Widget> widgets = [];
    for (int i = 0; i < _listTheme08.length; i++) {
      var item = _listTheme08[i];
      widgets.add(
        Expanded(
          child: InkWell(
            onTap: () {
              if (_themeDiv != i) {
                setState(() {
                  _themeDiv = i;
                });
              }
            },
            child: Container(
              height: 35,
              margin: EdgeInsets.only(
                right: i == 0
                    ? 5
                    : i == 1
                        ? 2.5
                        : 0,
                left: i == 2
                    ? 5
                    : i == 1
                        ? 2.5
                        : 0,
              ),
              alignment: Alignment.center,
              decoration: UIStyle.boxRoundFullColor6c(
                item.themeStatus == 'BULL' || item.themeStatus == 'Bullish'
                    ? const Color(0xffFFEBEB)
                    : const Color(0xffE4EBFE),
              ),
              child: AutoSizeText(
                '#${item.themeName}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: item.themeStatus == 'BULL' || item.themeStatus == 'Bullish'
                      ? i == _themeDiv
                          ? const Color(0xffFF5050)
                          : const Color(0xffFDA2A2)
                      : i == _themeDiv
                          ? const Color(0xff5886FE)
                          : const Color(0xff9FBAFF),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _divView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            if (_selectDiv != 0) {
              setState(() {
                _selectDiv = 0;
              });
            }
          },
          child: Text(
            '오늘 강세 종목',
            style: TextStyle(
              fontSize: 16,
              fontWeight: _selectDiv == 0 ? FontWeight.w600 : FontWeight.w400,
              color: _selectDiv == 0 ? Colors.black : const Color(0xffCDCDCD),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        const Text(
          '|',
          style: TextStyle(
            color: Color(0xffCDCDCD),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        InkWell(
          onTap: () {
            if (_selectDiv != 1) {
              setState(() {
                _selectDiv = 1;
              });
            }
          },
          child: Text(
            '테마 주도주',
            style: TextStyle(
              fontSize: 16,
              fontWeight: _selectDiv == 1 ? FontWeight.w600 : FontWeight.w400,
              color: _selectDiv == 1 ? Colors.black : const Color(0xffCDCDCD),
            ),
          ),
        ),
      ],
    );
  }

  Widget _listView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.zero,
      itemCount: _selectDiv == 0 ? _listTheme08[_themeDiv].listToday.length : _listTheme08[_themeDiv].listTrend.length,
      itemBuilder: (context, index) {
        Theme08Item item =
            _selectDiv == 0 ? _listTheme08[_themeDiv].listToday[index] : _listTheme08[_themeDiv].listTrend[index];
        return InkWell(
          onTap: () {
            basePageState.callPageRouteUpData(
              const ThemeHotViewer(),
              PgData(
                pgSn: _listTheme08[_themeDiv].themeCode,
              ),
            );
          },
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(
              top: index == 0 ? 0 : 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.stockName,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      item.stockCode,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xff999999),
                      ),
                    ),
                  ],
                ),
                Text(
                  TStyle.getPercentString(TStyle.getFixedNum(item.fluctuationRate)),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: TStyle.getMinusPlusColor(
                      item.fluctuationRate,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bearView() {
    return const SizedBox(
      width: double.infinity,
      height: 92,
      child: Center(
        child: Text(
          '오늘 강세를 보인 HOT 테마라도\n현재 테마 추세가 약세일 경우\n주도주가 분석되지 않습니다.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _requestTrTheme08() {
    _fetchPosts(
      TR.THEME08,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'selectCount': '3',
        },
      ),
    );
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));
      _parseTrData(trStr, response);
    } on Exception catch (_) {
      if (context.mounted) {
        CommonPopup.instance.showDialogNetErr(context);
      }
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    if (trStr == TR.THEME08) {
      final TrTheme08 resData = TrTheme08.fromJson(jsonDecode(response.body));
      _listTheme08.clear();
      if (resData.retCode == RT.SUCCESS && resData.retData.isNotEmpty) {
        _listTheme08.addAll(resData.retData);
      }
      setState(() {});
    }
  }
}
