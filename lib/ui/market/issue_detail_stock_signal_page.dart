import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/pocket_api_result.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_status.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue04.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_layer.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IssueDetailStockSignalPage extends StatefulWidget {
  const IssueDetailStockSignalPage({super.key});

  static const routeName = '/issue_detail_stock_signal';
  static const String TAG = "[IssueDetailStockSignalPage]";
  static const String TAG_NAME = "종목의_AI매매신호";

  @override
  State<IssueDetailStockSignalPage> createState() => _IssueDetailStockSignalPageState();
}

class _IssueDetailStockSignalPageState extends State<IssueDetailStockSignalPage> {
  late SharedPreferences _prefs;
  PgNews _pgNews = PgNews();
  String _userId = '';

  final List<StockStatus> _listTodaySignal = [];
  final List<StockStatus> _listHoldSignal = [];
  final List<StockStatus> _listWaitSignal = [];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      IssueDetailStockSignalPage.TAG_NAME,
    );
    _loadPrefData().then((value) {
      Future.delayed(Duration.zero, () {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        if (arguments == null || arguments is! PgNews || arguments.issueSn.isEmpty) {
          Navigator.pop(context);
          return const SizedBox.shrink();
        }
        _pgNews = ModalRoute.of(context)!.settings.arguments as PgNews;
        _fetchPosts(
            TR.ISSUE04,
            jsonEncode(<String, String>{
              'userId': _userId,
              'newsSn': _pgNews.newsSn,
              'issueSn': _pgNews.issueSn,
            }));
      });
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? AppGlobal().userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.basic(buildContext: context, title: '${_pgNews.tagName} 종목의 AI매매신호', elevation: 1),
      backgroundColor: RColor.bgBasic_fdfdfd,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_listTodaySignal.isNotEmpty) _setTodaySignalListView,
              _setAddStockInPocketBanner,
              if (_listHoldSignal.isNotEmpty) _setHoldSignalListView,
              if (_listWaitSignal.isNotEmpty) _setWaitSignalListView,
            ],
          ),
        ),
      ),
    );
  }

  Widget get _setTodaySignalListView {
    return Material(
      color: RColor.greyBox_f5f5f5,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            const Text(
              '오늘 AI매매신호 발생 종목',
              style: TStyle.commonTitle,
            ),
            const SizedBox(
              height: 15,
            ),
            ListView.builder(
              itemBuilder: (context, index) {
                var item = _listTodaySignal[index];
                return Container(
                  margin: const EdgeInsets.only(
                    top: 15,
                  ),
                  child: Ink(
                    decoration: UIStyle.boxShadowBasic(16),
                    //margin: EdgeInsets.only(top: 15,),
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      onLongPress: () async {
                        await _showAddStockLayerAndResult(stkName: item.stockName, stkCode: item.stockCode);
                      },
                      onTap: () {
                        basePageState.goStockHomePage(
                          item.stockCode,
                          item.stockName,
                          Const.STK_INDEX_SIGNAL,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 20,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  _setTradeFlagCircleView(
                                    text: item.tradeFlag == 'B' ? '매수' : '매도',
                                    circleColor: item.tradeFlag == 'B' ? RColor.sigBuy : RColor.sigSell,
                                    textColor: Colors.white,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.stockName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          item.stockCode,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: RColor.greyBasic_8c8c8c,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      item.tradeFlag == 'B' ? '매수가 ' : '매도가 ',
                                      style: const TextStyle(
                                        color: RColor.greyBasic_8c8c8c,
                                      ),
                                    ),
                                    Text(
                                      TStyle.getMoneyPoint(item.tradePrice),
                                    ),
                                    const Text(
                                      '원',
                                      style: TextStyle(
                                        color: RColor.greyBasic_8c8c8c,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '발생 ${item.tradeDate.substring(4, 6)}'
                                  '/${item.tradeDate.substring(6)}'
                                  ' ${item.tradeTime.substring(0, 2)}'
                                  ':${item.tradeTime.substring(2, 4)}',
                                  style: const TextStyle(
                                    color: RColor.greyBasic_8c8c8c,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _listTodaySignal.length,
            ),
            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }

  Widget get _setHoldSignalListView {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '보유중인 종목',
            style: TStyle.title18T,
          ),
          const SizedBox(
            height: 5,
          ),
          ListView.builder(
            itemBuilder: (context, index) {
              var item = _listHoldSignal[index];
              return Container(
                margin: const EdgeInsets.only(
                  top: 15,
                ),
                child: Ink(
                  decoration: UIStyle.boxShadowBasic(16),
                  //margin: EdgeInsets.only(top: 15,),
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    onLongPress: () async {
                      await _showAddStockLayerAndResult(stkName: item.stockName, stkCode: item.stockCode);
                    },
                    onTap: () {
                      basePageState.goStockHomePage(
                        item.stockCode,
                        item.stockName,
                        Const.STK_INDEX_SIGNAL,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                _setTradeFlagCircleView(
                                  text: '보유',
                                  circleColor: RColor.sigHolding,
                                  textColor: Colors.white,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.stockName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        item.stockCode,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: RColor.greyBasic_8c8c8c,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    '매수가 ',
                                    style: TextStyle(
                                      color: RColor.greyBasic_8c8c8c,
                                    ),
                                  ),
                                  Text(
                                    TStyle.getMoneyPoint(item.tradePrice),
                                  ),
                                  const Text(
                                    '원',
                                    style: TextStyle(
                                      color: RColor.greyBasic_8c8c8c,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    '보유수익률 ',
                                    style: TextStyle(
                                      color: RColor.greyBasic_8c8c8c,
                                    ),
                                  ),
                                  Text(
                                    TStyle.getPercentString(item.profitRate),
                                    style: TextStyle(
                                      color: TStyle.getMinusPlusColor(item.profitRate),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _listHoldSignal.length,
          ),
          const SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }

  Widget get _setWaitSignalListView {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '관망중인 종목',
            style: TStyle.title18T,
          ),
          const SizedBox(
            height: 5,
          ),
          ListView.builder(
            itemBuilder: (context, index) {
              var item = _listWaitSignal[index];
              return Container(
                margin: const EdgeInsets.only(
                  top: 15,
                ),
                child: Ink(
                  decoration: UIStyle.boxShadowBasic(16),
                  //margin: EdgeInsets.only(top: 15,),
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    onLongPress: () async {
                      await _showAddStockLayerAndResult(stkName: item.stockName, stkCode: item.stockCode);
                    },
                    onTap: () {
                      basePageState.goStockHomePage(
                        item.stockCode,
                        item.stockName,
                        Const.STK_INDEX_SIGNAL,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                _setTradeFlagCircleView(
                                  text: '관망',
                                  circleColor: RColor.sigWatching,
                                  textColor: Colors.white,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.stockName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        item.stockCode,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: RColor.greyBasic_8c8c8c,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                '관망 ',
                                style: TextStyle(
                                  color: RColor.greyBasic_8c8c8c,
                                ),
                              ),
                              Text(
                                item.elapsedDays,
                              ),
                              const Text(
                                '일째',
                                style: TextStyle(
                                  color: RColor.greyBasic_8c8c8c,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _listWaitSignal.length,
          ),
          const SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }

  Widget _setTradeFlagCircleView({
    required String text,
    required Color circleColor,
    required Color textColor,
  }) {
    return Container(
      width: 50.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: circleColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
          // style: theme.textTheme.body.apply(color: textColor),
        ),
      ),
    );
  }

  Widget get _setAddStockInPocketBanner {
    return InkWell(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 25,
        ),
        decoration: UIStyle.boxRoundFullColor6c(
          RColor.greyBox_dcdfe2,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ImageIcon(
              AssetImage('images/icon_pocket_add.png'),
              size: 20,
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: AutoSizeText(
                '종목을 꾹 누르면 포켓에 종목이 추가됩니다.',
                style: TextStyle(
                  fontSize: 15,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 정렬 함수
  int compareStockStatus(StockStatus a, StockStatus b) {
    int dateComparison = b.tradeDate.compareTo(a.tradeDate);
    if (dateComparison == 0) {
      return b.tradeTime.compareTo(a.tradeTime);
    }
    return dateComparison;
  }

  _showAddStockLayerAndResult({required String stkCode, required String stkName}) async {
    await CommonLayer.instance
        .showLayerAddStock(
      context,
      Stock(
        stockName: stkName,
        stockCode: stkCode,
      ),
      '',
    )
        .then(
      (result) async {
        switch (result.code) {
          case PocketApiCode.successWithData:
            _showBottomSheetMyStock(pocketSn: result.data);
            break;
          case PocketApiCode.showPopup:
            {
              dynamic data = result.data;
              if (data != null && data is Map) {
                switch (data['type']) {
                  case PocketApiPopupType.premium:
                    {
                      await CommonPopup.instance.showDialogPremium(context).then(
                            (_) => basePageState.navigateAndGetResultPayPremiumPage(),
                          );
                      break;
                    }
                  case PocketApiPopupType.failMsg:
                    {
                      CommonPopup.instance.showDialogBasic(context, '안내', data['message']);
                      break;
                    }
                }
              }
            }
            break;
          case PocketApiCode.unknownFailure:
            CommonPopup.instance.showDialogBasic(context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
            break;
          case PocketApiCode.userCancelled:
            break;
        }
      },
    );
  }

  // 나의 포켓으로 등록 이후 바텀시트
  _showBottomSheetMyStock({required String pocketSn}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '나의 종목 추가하기',
                      style: TStyle.title18T,
                    ),
                    InkWell(
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 30,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Text(
                  '${TStyle.getPostWord(AppGlobal().stkName, '이', '가')} 나의 종목으로 추가되었습니다.\n나의 종목 포켓에서 확인하시겠어요?',
                  style: TStyle.content15,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 40,
                ),
                InkWell(
                  child: SizedBox(
                    width: 240,
                    //height: 40,
                    child: Image.asset(
                      'images/rassibs_btn_pk.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  onTap: () {
                    basePageState.goPocketPage(Const.PKT_INDEX_MY, pktSn: pocketSn);
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _fetchPosts(String trStr, String json) async {
    DLog.d(IssueDetailStockSignalPage.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http
          .post(
            url,
            body: json,
            headers: Net.headers,
          )
          .timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {}
  }

  Future<void> _parseTrData(String trStr, final http.Response response) async {
    DLog.d(IssueDetailStockSignalPage.TAG, response.body);

    if (trStr == TR.ISSUE04) {
      final TrIssue04 resData = TrIssue04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Issue04 issue04 = resData.retData;
        // 데이터를 정렬한 후 분류
        var sortedList = issue04.stkList..sort(compareStockStatus);

        for (var stockStatus in sortedList) {
          if (stockStatus.tradeFlag == 'B' || stockStatus.tradeFlag == 'S') {
            _listTodaySignal.add(stockStatus);
          } else if (stockStatus.tradeFlag == 'H') {
            _listHoldSignal.add(stockStatus);
          } else if (stockStatus.tradeFlag == 'W') {
            _listWaitSignal.add(stockStatus);
          }
        }
        setState(() {});
      }
    }
  }
}
