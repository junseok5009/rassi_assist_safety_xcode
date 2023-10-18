import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_shome/tr_shome04.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/custom_firebase_class.dart';
import '../../../../common/net.dart';
import '../../../../common/tstyle.dart';
import '../../common/common_popup.dart';
import '../../../../models/pg_news.dart';
import '../../../models/tr_shome/tr_shome06.dart';
import '../../common/only_web_view.dart';


/// 2023.02.22_HJS
/// 종목정보 페이지
class StockInfoPage extends StatefulWidget {
  static const String TAG = "[StockInfoPage]";
  static const String TAG_NAME = '종목정보';
  const StockInfoPage({Key? key}) : super(key: key);
  @override
  State<StockInfoPage> createState() => _StockInfoPageState();
}

class _StockInfoPageState extends State<StockInfoPage> {
  late SharedPreferences _prefs;
  String _userId = '';
  String _stkName = '';
  String _stkCode = '';
  int _divIndex = 0;

  Shome06 _shome06 = defShome06; // chatgpt

  //종목요약정보 + 시세
  Shome04Stock _shome04stock = defShome04Stock;
  Shome04Price _shome04price = defShome04Price;
  final List<List<String>> _marketPriceTitle = [
    [
      '현재가',
      '거래대금',
    ],
    [
      '전일대비',
      '거래량',
    ],
    [
      '등락율',
      '전일거래량',
    ],
    [
      '전일종가',
      '시가',
    ],
    [
      '고가',
      '저가',
    ],
    [
      'PER',
      '외인보유',
    ],
    [
      'EPS',
      '외인비율',
    ],
    [
      '시가총액',
      '상장주식수',
    ],
    [
      '시총순위',
      '액면가',
    ],
    [
      '결산월',
      '자본금',
    ],
  ];

  // 종목차트
  final List<String> _divTitle = ['일봉', '주봉', '월봉', '5분봉'];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      StockInfoPage.TAG_NAME,
    );
    _loadPrefData().then((_) => {
          Future.delayed(Duration.zero, () {
            PgData pgData = ModalRoute.of(context)!.settings.arguments as PgData;
            if (_userId != '' &&
                pgData.stockCode != null &&
                pgData.stockCode.isNotEmpty) {
              _stkName = pgData.stockName;
              _stkCode = pgData.stockCode;
              _requestTrAll();
            }
          }),
        });
  }

  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: _shome04stock.bizOverview.isNotEmpty && _shome06.content.isNotEmpty
            ? 130
            : _shome06.content.isNotEmpty
              ? 110
              : _shome04stock.bizOverview.isNotEmpty
                ? 80
                : 50,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _stkName.length > 8
                  ? '${_stkName.substring(0, 8)} 종목정보'
                  : '$_stkName 종목정보',
              style: TStyle.title20,
            ),
            IconButton(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
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
        leading: null,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 10,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: _shome04stock.bizOverview.isNotEmpty,
                      child: Text(
                        _shome04stock.bizOverview,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              _shome04price.marketType == '1' ? '코스피' : '코스닥',
                              style: const TextStyle(
                                fontSize: 12,
                                color: RColor.bubbleChartTxtColorGrey,
                              ),
                            ),
                            Text(
                              '  |  ${_shome04stock.sectorName}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: RColor.bubbleChartTxtColorGrey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Visibility(
                              visible: _shome04stock.tradingHaltYn != null &&
                                  _shome04stock.tradingHaltYn == 'Y',
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: UIStyle.boxNewSelectBtn1(),
                                child: const Text(
                                  '관리종목',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _shome04stock.investStatus != null &&
                                  _shome04stock.investStatus.isNotEmpty,
                              child: const SizedBox(
                                width: 5,
                              ),
                            ),
                            Visibility(
                              visible: _shome04stock.investStatus != null &&
                                  _shome04stock.investStatus.isNotEmpty,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: UIStyle.boxNewSelectBtn1(),
                                child: Text(
                                  _shome04stock.investStatus,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Visibility(
                      visible: _shome06.content.isNotEmpty,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Container(
                          alignment: Alignment.center,
                          height: 50,
                          margin: const EdgeInsets.only(
                            top: 10,
                          ),
                          decoration: UIStyle.boxRoundLine6(),
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'images/icon_chat_gpt_logo.jpg',
                                width: 18,
                                height: 18,
                              ),
                              const Text(
                                ' 챗GPT가 요약한',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  ' $_stkName',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: RColor.mainColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Text(
                                '의 사업 개요',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          _showChatGptShome06Dialog();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 10,
                color: RColor.new_basic_grey,
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          scrollDirection: Axis.vertical,
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  // 시세
                  _setMarketConditionView(),

                  // 종목차트
                  _setStockChartView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //시세
  _setMarketConditionView() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Table(
        /*border: TableBorder.symmetric(
                      outside: BorderSide(color: Colors.redAccent, width: 1, style: BorderStyle.solid, strokeAlign: 10,),
                      inside:  BorderSide(color: Colors.blueAccent, width: 2, style: BorderStyle.solid, strokeAlign:5,),
                    ),*/
        children: List.generate(
          _marketPriceTitle.length,
          (index) => _setMarketConditionTableRows(index),
        ),
      ),
    );
  }

  //시세
  _setMarketConditionTableRows(int row) {
    return TableRow(
      children: List.generate(
        2,
        (index) => _setMarketConditionTableViews(row, index),
      ),
    );
  }

  //시세
  _setMarketConditionTableViews(int row, int column) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 2,
          color: (row == 0) ? Colors.transparent : RColor.bgWeakGrey,
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _marketPriceTitle[row][column],
                style: TStyle.content14,
              ),
              _setMarketConditionValueView(row, column),
            ],
          ),
        ),
        /* Visibility(
          visible: _marketPriceTitle.length - 1 == row,
          child: Container(
            height: 2,
            color: Colors.black,
          ),
        ),*/
      ],
    );
  }

  //시세
  _setMarketConditionValueView(int row, int column) {
    Text textView;
    switch (row) {
      case 0:
        {
          if (column == 0) {
            //현재가
            textView = Text(
              TStyle.getMoneyPoint(_shome04price.currentPrice),
              style: TextStyle(
                color: TStyle.getMinusPlusColor(_shome04price.fluctuationAmt),
              ),
            );
          } else {
            //거래대금
            textView = Text(
              '${TStyle.getMoneyPoint(_shome04price.accTradeAmt)}백만',
            );
          }
          break;
        }

      case 1:
        {
          if (column == 0) {
            //전일대비(원)
            textView = Text(
              TStyle.getTriangleStringWithMoneyPoint(_shome04price.fluctuationAmt),
              style: TextStyle(
                color: TStyle.getMinusPlusColor(_shome04price.fluctuationAmt),
              ),
            );
          } else {
            //거래량
            textView = Text(
              TStyle.getMoneyPoint(_shome04price.accTradeVol),
            );
          }
          break;
        }

      case 2:
        {
          if (column == 0) {
            //등락율(1개월)%
            textView = Text(
              '${_shome04price.fluctMonth1}%(1개월)',
              style: TextStyle(
                color: TStyle.getMinusPlusColor(_shome04price.fluctMonth1),
              ),
            );
          } else {
            //전일거래량
            textView = Text(
              TStyle.getMoneyPoint(_shome04price.preAccTradeVol),
            );
          }
          break;
        }

      case 3:
        {
          if (column == 0) {
            //전일종가
            textView = Text(
              TStyle.getMoneyPoint(_shome04price.preClosePrice),
            );
          } else {
            //시가
            textView = Text(
              TStyle.getMoneyPoint(_shome04price.openPrice),
            );
          }
          break;
        }

      case 4:
        {
          if (column == 0) {
            //고가
            textView = Text(
              TStyle.getMoneyPoint(_shome04price.highPrice),
            );
          } else {
            //저가
            textView = Text(
              TStyle.getMoneyPoint(_shome04price.lowPrice),
            );
          }
          break;
        }

      case 5:
        {
          if (column == 0) {
            //PER
            textView = Text(
              TStyle.getMoneyPoint(_shome04price.per),
            );
          } else {
            //외인보유
            textView = Text(
              '${TStyle.getMoneyPoint(_shome04price.frnHoldVol)}천주',
            );
          }
          break;
        }

      case 6:
        {
          if (column == 0) {
            //EPS
            textView = Text(
              TStyle.getMoneyPoint(_shome04price.eps),
            );
          } else {
            //외인비율
            textView = Text(
              '${TStyle.getMoneyPoint(_shome04price.frnHoldRate)}%',
            );
          }
          break;
        }

      case 7:
        {
          if (column == 0) {
            //시가총액
            textView = Text(
              '${TStyle.getMoneyPoint(_shome04price.marketValue)}억원',
            );
          } else {
            //상장주식수
            textView = Text(
              '${TStyle.getMoneyPoint(_shome04price.listedShares)}만주',
            );
          }
          break;
        }

      case 8:
        {
          if (column == 0) {
            //시총순위
            textView = Text(
              _shome04price.marketType == '1'
                  ? '코스피 ${_shome04price.marketRank}위'
                  : '코스닥 ${_shome04price.marketRank}위',
            );
          } else {
            //액면가
            textView = Text(
              '${TStyle.getMoneyPoint(_shome04price.par)}원',
            );
          }
          break;
        }

      case 9:
        {
          if (column == 0) {
            //결산월
            textView = Text(
              _shome04price.closingMMDD.length > 2
                  ? '${_shome04price.closingMMDD.substring(0, 2)}월'
                  : '월',
            );
          } else {
            //자본금
            textView = Text(
              '${TStyle.getMoneyPoint(_shome04price.capital)}억원',
            );
          }
          break;
        }

      default:
        textView = const Text('no data');
    }
    return textView;
  }

  Widget _setStockChartView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '종목차트',
            style: TStyle.title18T,
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            decoration: UIStyle.boxNewBasicGrey10(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      TStyle.getMoneyPoint(_shome04price.currentPrice),
                      style: TStyle.subTitle,
                    ),
                    Text(
                      '  ${_shome04price.fluctuationRate}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: TStyle.getMinusPlusColor(
                            _shome04price.fluctuationRate,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: RColor.lineGrey3,
                    inactiveTrackColor: RColor.lineGrey3,
                    thumbColor: RColor.lineGrey2,
                    overlayShape: SliderComponentShape.noOverlay,
                    showValueIndicator: ShowValueIndicator.always,
                    /*thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: enabledThumbRadius,
                      elevation: elevation,
                    ),*/
                    trackShape: const RectangularSliderTrackShape(),
                    //valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                    trackHeight: 7,
                  ),
                  child: Slider(
                    value: double.tryParse(_shome04price.currentPrice) != null && double.tryParse(_shome04price.top52Price) != null
                        ? double.parse(_shome04price.currentPrice) > double.tryParse(_shome04price.top52Price)!
                        ? double.tryParse(_shome04price.top52Price)! : double.parse(_shome04price.currentPrice) : 0,
                    min: double.tryParse(_shome04price.low52Price) != null
                        ? double.parse(_shome04price.low52Price)
                        : 0,
                    max: double.tryParse(_shome04price.top52Price) != null
                        ? double.parse(_shome04price.top52Price)
                        : 0,
                    onChanged: (double value) {},
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TStyle.getMoneyPoint(_shome04price.low52Price),
                            style: TStyle.subSmallTitle,
                          ),
                          const Text(
                            '52주최저',
                            style: TStyle.subSmallTitle,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TStyle.getMoneyPoint(_shome04price.top52Price),
                            style: TStyle.subSmallTitle,
                          ),
                          const Text(
                            '52주최고',
                            style: TStyle.subSmallTitle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          _setDivView(),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            color: Colors.red,
            //height: 260,
            child: Image.network(
              _divIndex == 0
                  ? 'https://webchart.thinkpool.com/2022Mobile/Stock1Day/A$_stkCode.png'
                  : _divIndex == 1
                      ? 'https://webchart.thinkpool.com/2022Mobile/Stock1Week/A$_stkCode.png'
                      : _divIndex == 2
                          ? 'https://webchart.thinkpool.com/2022Mobile/StockMonth/A$_stkCode.png'
                          : _divIndex == 3
                              ? 'https://webchart.thinkpool.com/2022Mobile/Stock5Min/A$_stkCode.png'
                              : 'https://webchart.thinkpool.com/2022Mobile/Stock1Day/A$_stkCode.png',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
              basePageState.callPageRouteNews(
                OnlyWebView(),
                PgNews(linkUrl: 'https://m.thinkpool.com/item/$_stkCode/chart'),
              );
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: UIStyle.boxRoundLine6(),
              alignment: Alignment.center,
              child: const Text(
                '차트 크게 보기',
                style: TStyle.subTitle16,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget _setDivView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        4,
        (index) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 4,
            ),
            margin: EdgeInsets.only(right: index == 3 ? 0 : 5),
            decoration: _divIndex == index
                ? UIStyle.boxNewSelectBtn1()
                : UIStyle.boxNewUnSelectBtn1(),
            child: Center(
              child: InkWell(
                child: Text(
                  _divTitle[index],
                  style: TextStyle(
                    color: _divIndex == index ? Colors.black : Colors.grey,
                    fontSize: 15,
                  ),
                ),
                onTap: () {
                  if (_divIndex != index) {
                    setState(() {
                      _divIndex = index;
                      //_requestTrReport01();
                    });
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // 챗GPT 오늘의 요약 기업 개요 레이어
  _showChatGptShome06Dialog() {
    // auto height 레이어
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 15,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          height: MediaQuery.of(context).size.height * 3 / 4,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.topRight,
                  color: Colors.black,
                  constraints: const BoxConstraints(),
                  iconSize: 26,
                  onPressed: () => Navigator.of(context).pop(null),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  //physics: NeverScrollableScrollPhysics(),
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'images/icon_chat_gpt_logo.jpg',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: Text(
                            '챗GPT가 요약한 $_stkName의 사업 개요',
                            style: TStyle.title17,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${TStyle.getDateSlashFormat3(_shome06.updateDate)} 업데이트',
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      _shome06.content,
                    ),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: RColor.new_basic_line_grey,
                      margin: const EdgeInsets.symmetric(vertical: 10,),
                    ),
                    const Text(
                      '※ ChatGPT를 이용한 사업개요 요약은 DART 자료를 바탕으로 수집되며, 기술적 방법에 따라 일부 내용에 오류가 있을 수 있습니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: RColor.bgTableTextGrey,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '※ $_stkName의 공시자료를 GPT-3.5 Turbo로 구동되는 씽크풀의 컨텐츠 생성 및 검수 시스템을 통해 요약한 정보 입니다. 본 컨텐츠는 AI를 이용한 컨텐츠로, AI기술이 가진 구조적 한계를 가지고 있습니다.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: RColor.bgTableTextGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _requestTrAll() async {
    String jsonSHOME04 = jsonEncode(
      <String, String>{
        'userId': _userId,
        'stockCode': _stkCode,
      },
    );
    String jsonSHOME06 = jsonEncode(
      <String, String>{
        'userId': _userId,
        'stockCode': _stkCode,
      },
    );
    await Future.wait(
      [
        // DEFINE 종목요약정보 + 시세
        _fetchPosts(
          TR.SHOME04,
          jsonSHOME04,
        ),
        // DEFINE 오늘의 요약 - 챗 GPT 기업 개요
        _fetchPosts(
          TR.SHOME06,
          jsonSHOME06,
        ),
      ],
    );

    setState(() {});
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    //DLog.d(StockHomeHomePage.TAG, trStr + ' ' + json);

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
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup().showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    // DEFINE 종목요약정보 + 시세
    if (trStr == TR.SHOME04) {
      final TrShome04 resData = TrShome04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _shome04stock = resData.retData.shome04stock;
        _shome04price = resData.retData.shome04price;
      } else {
        _shome04stock = defShome04Stock;
        _shome04price = defShome04Price;
      }
    }
    // NOTE 오늘의 요약 - 챗 GPT 기업 개요 정보
    else if (trStr == TR.SHOME06) {
      final TrShome06 resData = TrShome06.fromJson(jsonDecode(response.body));
      _shome06 = defShome06;
      if (resData.retCode == RT.SUCCESS) {
        _shome06 = resData.retData;
      }
    }
  }
}
