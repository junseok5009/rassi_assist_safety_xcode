import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/custom_firebase_class.dart';
import '../../../common/net.dart';
import '../../../common/tstyle.dart';
import '../../../custom_lib/sticky_header/custom_stock_home_sticky_header/custom_stock_home_sticky_headers_table.dart';
import '../../../custom_lib/sticky_header/custom_stock_home_sticky_header/custom_stock_home_sticky_headers_table.dart'
    as custom_class_scroller;
import '../../../models/tr_invest/tr_invest01.dart';
import '../../common/common_popup.dart';

/// 2023.03.02_HJS
/// 일자별 매매동향 페이지
class TradingTrendsByDatePage extends StatefulWidget {
  static const String TAG = "[TradingTrendsByDatePage]";
  static const String TAG_NAME = '일자별_매매동향';
  const TradingTrendsByDatePage({Key? key}) : super(key: key);
  @override
  State<TradingTrendsByDatePage> createState() =>
      _TradingTrendsByDatePageState();
}

class _TradingTrendsByDatePageState extends State<TradingTrendsByDatePage> {
  final _appGlobal = AppGlobal();
  late SharedPreferences _prefs;
  String _userId = '';
  String _stkCode = '';
  int _pageNo = 0;
  int _totalPageSize = 0;

  final List<String> _columnTitleList = [
    '외국인',
    '기관',
    '개인',
    '투신',
    '연기금',
    '사모펀드',
  ];
  final List<Invest01ChartData> _trendsListData = [];

  final _controller = ScrollController();

  @override
  void setState(VoidCallback fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      TradingTrendsByDatePage.TAG_NAME,
    );
    _loadPrefData().then(
      (_) => {
        if (_userId != '')
          {
            _requestTrInvest01(),
          },
      },
    );
    // Setup the listener.
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        if (_controller.position.pixels != 0) {
          if (_pageNo == 0) {
            _pageNo = 2;
          } else {
            _pageNo++;
          }
          if (_pageNo < _totalPageSize) {
            _requestTrInvest01();
          }
        }
      }
    });
  }

  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    _stkCode = _appGlobal.stkCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '일자별 매매동향',
              style: TStyle.title18T,
            ),
            IconButton(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                //horizontal: 10,
              ), // 패딩 설정
              constraints: const BoxConstraints(), // constraints
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              icon: const Icon(
                Icons.close,
                color: Colors.black,
                size: 26,
              ),
            ),
          ],
        ),
        //iconTheme: IconThemeData(color: Colors.black),
        centerTitle: false,
        leadingWidth: 0,
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.centerRight,
                child: const Text(
                  '단위 : 주',
                  style: TextStyle(
                    color: RColor.bgTableTextGrey,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Expanded(
                child: CustomStockHomeStickyHeadersTable(
                  showVerticalScrollbar: false,
                  showHorizontalScrollbar: false,
                  scrollControllers: custom_class_scroller.ScrollControllers(
                    verticalBodyController: _controller,
                  ),
                  columnsLength: 6,
                  rowsLength: _trendsListData.length,
                  columnsTitleBuilder: (columnIndex) {
                    return Container(
                      alignment: Alignment.bottomCenter,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: RColor.bgTableGrey,
                        border: Border(
                          top: BorderSide(
                            width: 1.0,
                            color: RColor.bgTableTextGrey,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _columnTitleList[columnIndex],
                          style: const TextStyle(
                            fontSize: 16,
                            color: RColor.bgTableTextGrey,
                          ),
                        ),
                      ),
                    );
                  },
                  rowsTitleBuilder: (i) => Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          width: 1.0,
                          color: RColor.lineGrey,
                        ),
                      ),
                    ),
                    child: Container(
                      color: RColor.bgTableGrey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 40,
                            child: Center(
                              //color: Colors.yellow,
                              child: Text(
                                TStyle.getDateDivFormat(_trendsListData[i].td),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: RColor.bgTableTextGrey,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      TStyle.getMoneyPoint(
                                          _trendsListData[i].tp),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: TStyle.getMinusPlusColor(
                                            _trendsListData[i].fa),
                                      ),
                                    ),
                                    Text(
                                      TStyle.getTriangleStringWithMoneyPoint(
                                          _trendsListData[i].fa),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: TStyle.getMinusPlusColor(
                                          _trendsListData[i].fa,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  contentCellBuilder: (columnIndex, rowIndex) {
                    String value = '';
                    Color color = Colors.black;
                    switch (columnIndex) {
                      case 0:
                        {
                          value = _trendsListData[rowIndex].fv;
                          break;
                        }
                      case 1:
                        {
                          value = _trendsListData[rowIndex].ov;
                          break;
                        }
                      case 2:
                        {
                          value = _trendsListData[rowIndex].pv;
                          break;
                        }
                      case 3:
                        {
                          value = _trendsListData[rowIndex].itv;
                          break;
                        }
                      case 4:
                        {
                          value = _trendsListData[rowIndex].rpv;
                          break;
                        }
                      case 5:
                        {
                          value = _trendsListData[rowIndex].pev;
                          break;
                        }
                    }
                    color = TStyle.getMinusPlusColor(value);
                    value = TStyle.getMoneyPoint(value);
                    if (columnIndex == 0) {
                      return Container(
                        width: 100,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              width: 1.0,
                              color: RColor.lineGrey,
                            ),
                            //bottom: BorderSide(width: 1.0, color: Colors.brown),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              value,
                              style: TextStyle(
                                fontSize: 14,
                                color: color,
                              ),
                            ),
                            Text(
                              '${_trendsListData[rowIndex].fh}%',
                              style: TextStyle(
                                fontSize: 14,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        width: 100,
                        alignment: Alignment.centerRight,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              width: 1.0,
                              color: RColor.lineGrey,
                            ),
                            //bottom: BorderSide(width: 1.0, color: Colors.brown),
                          ),
                        ),
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 14,
                            color: color,
                          ),
                        ),
                      );
                    }
                  },
                  legendCell: Container(
                    height: 32,
                    decoration: const BoxDecoration(
                      color: RColor.bgTableGrey,
                      border: Border(
                        top: BorderSide(
                          width: 1.0,
                          color: RColor.bgTableTextGrey,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(
                          flex: 40,
                          child: Text(
                            '날짜',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: RColor.bgTableTextGrey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 60,
                          child: Text(
                            '종가',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: RColor.bgTableTextGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _requestTrInvest01() async {
    _fetchPosts(
      TR.INVEST01,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'stockCode': _stkCode,
          'pageNo': '$_pageNo',
          'pageItemSize': _pageNo == 0 ? '20' : '10',
        },
      ),
    );
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    DLog.w(trStr + ' ' + json);

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
    } on TimeoutException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);

    // NOTE 매매동향 - 외국인/기관
    if (trStr == TR.INVEST01) {
      final TrInvest01 resData = TrInvest01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Invest01 invest01 = resData.retData;
        _totalPageSize = int.parse(invest01.totalPageSize);
        if (invest01.listChartData.isNotEmpty) {
          setState(() {
            _trendsListData.addAll(invest01.listChartData);
          });
        } else {
          if (_pageNo == 0 && _totalPageSize == 0) {
            //_isNoData = 'Y';
          }
        }
      } else {
        if (_pageNo == 0 && _totalPageSize == 0) {
          //_isNoData = 'Y';
        }
      }
    }
  }
}
