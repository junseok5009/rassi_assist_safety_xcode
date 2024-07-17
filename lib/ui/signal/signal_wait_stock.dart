import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_signal/tr_signal06.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2021.08.03 - JY
/// 현재 관망중인 종목
class SignalWaitPage extends StatefulWidget {
  static const routeName = '/page_signal_wait';
  static const String TAG = "[SignalWaitPage] ";
  static const String TAG_NAME = '매매신호_관망중_전체';
  @override
  State<StatefulWidget> createState() => SignalWaitPageState();
}

class SignalWaitPageState extends State<SignalWaitPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  final List<TimeLineSig> _listData = [];
  late ScrollController _scrollController;
  int _pageNum = 0;
  String _preDate = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(SignalWaitPage.TAG_NAME);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 300), () {
      DLog.d(SignalWaitPage.TAG, "delayed user id : $_userId");
      if (_userId != '') {
        _requestData();
      }
    });
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _bYetDispose = false;
    super.dispose();
  }

  //리스트뷰 하단 리스너
  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      //리스트뷰 하단 도착 / 새로운 데이터 요청
      _pageNum = _pageNum + 1;
      _requestData();
    }
  }

  _requestData() {
    DLog.d(SignalWaitPage.TAG, '### requestData');
    _fetchPosts(
        TR.SIGNAL06,
        jsonEncode(<String, String>{
          'userId': _userId,
          'tradeFlag': 'W', //H:보유, W:관망
          'honorYn': 'N', //명예의 전당 종목만 only
          'pageNo': _pageNum.toString(),
          'pageItemSize': '30',
        }));
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: _setLayout(),
    );
  }

  Widget _setLayout() {
    return Scaffold(
      appBar: CommonAppbar.basic(buildContext: context, title: '현재 관망중인 종목', elevation: 1,),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _listData.length,
        itemBuilder: (context, index) {
          return _buildOneItem(
              _listData[index].elapsedTmTx, _listData[index].listData);
        },
      ),
    );
  }

  //종목 리스트
  Widget _buildOneItem(String strTime, List<SignalSig> subList) {
    bool bShowDate = true;
    if (_preDate == strTime)
      bShowDate = false;
    else
      _preDate = strTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: bShowDate,
          child: Container(
            margin: const EdgeInsets.only(
              left: 15,
              top: 15,
            ),
            child: Row(
              children: [
                Image.asset(
                  'images/rassi_itemar_icon_ar1.png',
                  fit: BoxFit.cover,
                  scale: 3,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  strTime,
                  style:
                      TextStyle(fontSize: 14, color: Colors.deepOrangeAccent),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 7, left: 15, right: 15, bottom: 5),
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: subList.length,
              itemBuilder: (context, index) {
                return Container(
                  height: 67,
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: UIStyle.boxRoundLine20(),
                  child: InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //종목명, 종목코드
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              TStyle.getLimitString(
                                  subList[index].stockName, 12),
                              style: TStyle.commonSTitle,
                            ),
                            const SizedBox(
                              width: 3.0,
                            ),
                            Text(
                              subList[index].stockCode,
                              style: TStyle.textSGrey,
                            ),
                            const SizedBox(
                              width: 3.0,
                            ),
                          ],
                        ),
                        //거래가격
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text('관망'),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              '${TStyle.getMoneyPoint(subList[index].elapsedDays)}일째',
                              style: TStyle.content17T,
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      //종목 신호 정보로 이동
                      basePageState.goStockHomePage(
                        subList[index].stockCode,
                        subList[index].stockName,
                        Const.STK_INDEX_SIGNAL,
                      );
                    },
                  ),
                );
              }),
        )
      ],
    );
  }

  Widget _setAppBar() {
    return Container(
      height: Const.HEIGHT_APP_BAR,
      decoration: const BoxDecoration(
          border: Border(
        bottom: BorderSide(color: RColor.lineGrey, width: 1),
      )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            iconSize: 20,
            onPressed: () => Navigator.of(context).pop(null),
          ),
          const Text(
            '현재 관망중인 종목',
            style: TStyle.commonTitle,
          ),
          const SizedBox(
            width: 40,
          )
        ],
      ),
    );
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(SignalWaitPage.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    final http.Response response = await http.post(
      url,
      headers: Net.headers,
      body: json,
    );

    if (_bYetDispose) _parseTrData(trStr, response);
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(SignalWaitPage.TAG, response.body);

    final TrSignal06 resData = TrSignal06.fromJson(jsonDecode(response.body));
    if (resData.retCode == RT.SUCCESS) {
      _listData.addAll(resData.retData?.listData as Iterable<TimeLineSig>);

      setState(() {});
    }
  }
}
