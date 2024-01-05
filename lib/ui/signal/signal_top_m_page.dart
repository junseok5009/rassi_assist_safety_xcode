import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_find/tr_find01.dart';
import 'package:rassi_assist/models/tr_find/tr_find02.dart';
import 'package:rassi_assist/models/tr_find/tr_find03.dart';
import 'package:rassi_assist/models/tr_find/tr_find04.dart';
import 'package:rassi_assist/models/tr_find/tr_find05.dart';
import 'package:rassi_assist/models/tr_find/tr_find07.dart';
import 'package:rassi_assist/models/tr_find/tr_find09.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/common_appbar.dart';

/// 2021.02.08
/// 성과 TOP 페이지(시그널 메인에서)
class SignalMTopPage extends StatefulWidget {
  static const routeName = '/page_signal_m_top';
  static const String TAG = "[SignalMTopPage]";

  const SignalMTopPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SignalMTopPageState();
}

class SignalMTopPageState extends State<SignalMTopPage> {
  String TAG_NAME = '조건별_';
  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  ListSort selectSort = ListSort.SORT_A;
  bool topHit = false,
      topPrf = false,
      topSta = false,
      topMax = false,
      topAvg = false,
      topSht = false,
      topTpc = false,
      topEmpty = false;
  List<Find01> _vList1 = [];
  List<Find02> _vList2 = [];
  List<Find03> _vList3 = [];
  List<Find04> _vList4 = [];
  List<Find05> _vList5 = [];
  List<Find07> _vList7 = [];
  List<Find09> _vList9 = [];

  @override
  void initState() {
    super.initState();

    _loadPrefData().then(
      (_) => {
        Future.delayed(
          Duration.zero,
          () {
            PgData args = ModalRoute.of(context)!.settings.arguments as PgData;
            if (_userId != '' && args != null) {
              String sTr = '';
              if (args.pgData == 'CUR_B') {
                TAG_NAME = '조건별_매수후급등';
                sTr = TR.FIND01;
              } else if (args.pgData == 'HIT_H') {
                TAG_NAME = '조건별_승률탑매수';
                sTr = TR.FIND02;
              } else if (args.pgData == 'HIT_W') {
                TAG_NAME = '조건별_승률탑관망';
                sTr = TR.FIND03;
              } else if (args.pgData == 'AVG_H') {
                TAG_NAME = '조건별_평균수익탑매수';
                sTr = TR.FIND04;
              } else if (args.pgData == 'AVG_W') {
                TAG_NAME = '조건별_평균수익탑관망';
                sTr = TR.FIND05;
              } else if (args.pgData == 'SHT_S') {
                TAG_NAME = '조건별_평균보유기간짧은매매신호발생많이';
                sTr = TR.FIND07;
              } else if (args.pgData == 'TPC_S') {
                TAG_NAME = '조건별_주간토픽중최근매수종목';
                sTr = TR.FIND09;
              }
              CustomFirebaseClass.logEvtScreenView(TAG_NAME);

              _fetchPosts(
                sTr,
                jsonEncode(
                  <String, String>{
                    'userId': _userId,
                    'selectCount': '50',
                  },
                ),
              );
            }
          },
        ),
      },
    );
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  @override
  void dispose() {
    _bYetDispose = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: _getPageTitle(),
        elevation: 1,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            if (topHit) _setTopList1(context),
            if (topPrf) _setTopList2(context),
            if (topSta) _setTopList3(context),
            if (topMax) _setTopList4(context),
            if (topAvg) _setTopList5(context),
            if (topSht) _setTopList7(context),
            if (topTpc) _setTopList9(context),
            if (topEmpty) _setEmptyText(),
          ],
        ),
      ),
    );
  }

  Widget _setTopList1(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _vList1.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _setHeaderView();
            return TileFindV01(_vList1[index - 1]);
          }),
    );
  }

  Widget _setTopList2(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _vList2.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _setHeaderView();
            return TileFindV02(_vList2[index - 1]);
          }),
    );
  }

  Widget _setTopList3(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _vList3.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _setHeaderView();
            return TileFindV03(_vList3[index - 1]);
          }),
    );
  }

  Widget _setTopList4(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _vList4.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _setHeaderView();
            return TileFindV04(_vList4[index - 1]);
          }),
    );
  }

  Widget _setTopList5(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _vList5.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _setHeaderView();
            return TileFindV05(_vList5[index - 1]);
          }),
    );
  }

  Widget _setTopList7(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _vList7.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _setHeaderView();
            return TileFindV07(_vList7[index - 1]);
          }),
    );
  }

  Widget _setTopList9(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _vList9.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _setHeaderView();
            return TileFindV09(_vList9[index - 1]);
          }),
    );
  }

  Widget _setEmptyText() {
    return Container(
      child: const Center(
        child: Text(
          '발생한 종목이 없습니다.',
          style: TStyle.textGreyDefault,
        ),
      ),
    );
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(SignalMTopPage.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    final http.Response response = await http.post(
      url,
      body: json,
      headers: Net.headers,
    );

    if (_bYetDispose) _parseTrData(trStr, response);
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(SignalMTopPage.TAG, response.body);

    //3일내에 매수 후 급등 (FIND01)
    if (trStr == TR.FIND01) {
      final TrFind01 resData = TrFind01.fromJson(jsonDecode(response.body));
      if (resData.listData != null) {
        DLog.d(SignalMTopPage.TAG, resData.listData[0].toString());
        _vList1 = resData.listData;
      } else {
        topEmpty = true;
      }
      topHit = true;
      setState(() {});
    }
    //승률 높은 최근 매수 (FIND02)
    else if (trStr == TR.FIND02) {
      final TrFind02 resData = TrFind02.fromJson(jsonDecode(response.body));
      if (resData.listData != null) {
        DLog.d(SignalMTopPage.TAG, resData.listData[0].toString());
        _vList2 = resData.listData;
      } else {
        topEmpty = true;
      }
      topPrf = true;
      setState(() {});
    }
    //승률 높은 최근 관망 (FIND03)
    else if (trStr == TR.FIND03) {
      final TrFind03 resData = TrFind03.fromJson(jsonDecode(response.body));
      if (resData.listData != null) {
        DLog.d(SignalMTopPage.TAG, resData.listData[0].toString());
        _vList3 = resData.listData;
      } else {
        topEmpty = true;
      }
      topSta = true;
      setState(() {});
    }
    //평균수익률 높은 최근 매수 (FIND04)
    else if (trStr == TR.FIND04) {
      final TrFind04 resData = TrFind04.fromJson(jsonDecode(response.body));
      if (resData.listData != null) {
        DLog.d(SignalMTopPage.TAG, resData.listData[0].toString());
        _vList4 = resData.listData;
      } else {
        topEmpty = true;
      }
      topMax = true;
      setState(() {});
    }
    //평균수익률 높은 관망 (FIND05)
    else if (trStr == TR.FIND05) {
      final TrFind05 resData = TrFind05.fromJson(jsonDecode(response.body));
      if (resData.listData != null) {
        DLog.d(SignalMTopPage.TAG, resData.listData[0].toString());
        _vList5 = resData.listData;
      } else {
        topEmpty = true;
      }
      topAvg = true;
      setState(() {});
    }
    //평균보유기간 짧은 종목 (FIND07)
    else if (trStr == TR.FIND07) {
      final TrFind07 resData = TrFind07.fromJson(jsonDecode(response.body));
      if (resData.listData != null) {
        DLog.d(SignalMTopPage.TAG, resData.listData[0].toString());
        _vList7 = resData.listData;
      } else {
        topEmpty = true;
      }
      topSht = true;
      setState(() {});
    }
    //주간토픽 중 최근 매수 종목 (FIND09)
    else if (trStr == TR.FIND09) {
      final TrFind09 resData = TrFind09.fromJson(jsonDecode(response.body));
      if (resData.listData != null) {
        DLog.d(SignalMTopPage.TAG, resData.listData[0].toString());
        _vList9 = resData.listData;
      } else {
        topEmpty = true;
      }
      topTpc = true;
      setState(() {});
    }
  }

  Widget _setHeaderView() {
    return Container(
      width: double.infinity,
      height: 250,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (topHit) _setHeaderTextT1(),
          if (topPrf) _setHeaderTextT2(),
          if (topSta) _setHeaderTextT3(),
          if (topMax) _setHeaderTextT4(),
          if (topAvg) _setHeaderTextT5(),
          if (topSht) _setHeaderTextT7(),
          if (topTpc) _setHeaderTextT9(),
          Column(
            children: [
              //라디오 버튼
              _setSortRadio(),
              // 컬럼 타이틀
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.black, width: 1.5),
                    bottom: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 50,
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '종목명',
                          style: TStyle.commonSTitle,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 50,
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _getColumnMiddle(),
                          style: TStyle.commonSTitle,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          _getColumnEnd(),
                          style: TStyle.commonSTitle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _setHeaderTextT1() {
    return Container(
      margin: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 7,
          ),
          Row(
            children: const [
              Text(
                '최근 3일',
                style: TStyle.defaultTitle,
              ),
              Text(
                '내에',
                style: TStyle.defaultContent,
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            '매수 신호가 발생한',
            style: TStyle.defaultContent,
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            '종목 중',
            style: TStyle.defaultContent,
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            '급등한 종목',
            style: TStyle.textBBuy,
          ),
        ],
      ),
    );
  }

  Widget _setHeaderTextT2() {
    return Container(
      margin: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 7,
          ),
          Row(
            children: const [
              Text(
                '적중률',
                style: TStyle.defaultTitle,
              ),
              Text(
                ' 높은',
                style: TStyle.defaultContent,
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            '종목중 최근 3일 이내',
            style: TStyle.defaultContent,
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            '매수 신호가',
            style: TStyle.defaultContent,
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            '발생한 종목',
            style: TStyle.textBBuy,
          ),
        ],
      ),
    );
  }

  Widget _setHeaderTextT3() {
    return Container(
      margin: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 7,
          ),
          Row(
            children: const [
              Text(
                '적중률',
                style: TStyle.defaultTitle,
              ),
              Text(
                ' 높은',
                style: TStyle.defaultContent,
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            '종목중 현재 관망',
            style: TStyle.defaultContent,
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            '상태인 종목',
            style: TStyle.textBBuy,
          ),
        ],
      ),
    );
  }

  Widget _setHeaderTextT4() {
    return Container(
      margin: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 7,
          ),
          Row(
            children: const [
              Text(
                '매매시 ',
                style: TStyle.defaultContent,
              ),
              Text(
                '평균수익률이',
                style: TStyle.defaultTitle,
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            '높은 종목 중',
            style: TStyle.defaultContent,
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            '최근 3일 이내 매수 신호가',
            style: TStyle.defaultTitle,
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            '발생한 종목',
            style: TStyle.textBBuy,
          ),
        ],
      ),
    );
  }

  Widget _setHeaderTextT5() {
    return Container(
      margin: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 7,
          ),
          Row(
            children: const [
              Text(
                '매매시 ',
                style: TStyle.defaultContent,
              ),
              Text(
                '평균수익률이',
                style: TStyle.defaultTitle,
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            '높은 종목 중',
            style: TStyle.defaultContent,
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            '현재 관망',
            style: TStyle.defaultTitle,
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            '상태인 종목',
            style: TStyle.textBBuy,
          ),
        ],
      ),
    );
  }

  Widget _setHeaderTextT7() {
    return Container(
      margin: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 7,
          ),
          const Text(
            '평균 보유 기간이',
            style: TStyle.defaultTitle,
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: const [
              Text(
                '짧은',
                style: TStyle.textBBuy,
              ),
              Text(
                ' 상대적으로',
                style: TStyle.defaultTitle,
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            '매매신호 발생이 빈번한 100종목',
            style: TStyle.defaultTitle,
          ),
        ],
      ),
    );
  }

  Widget _setHeaderTextT9() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 7,
          ),
          const Text(
            '최근 5주간 올라온',
            style: TStyle.defaultTitle,
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            '라씨 매매비서의 주간토픽종목 중',
            style: TStyle.defaultTitle,
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: const [
              Text(
                '최근 매수 종목',
                style: TStyle.textBBuy,
              ),
              Text(
                ' 입니다.',
                style: TStyle.commonTitle,
              ),
            ],
          )
        ],
      ),
    );
  }

  //라디오 버튼 SET
  Widget _setSortRadio() {
    return Container(
      height: 50,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Radio(
                value: ListSort.SORT_A,
                groupValue: selectSort,
                activeColor: RColor.sigBuy,
                onChanged: (value) {
                  _setListSortA();
                  setState(() {
                    selectSort = value!;
                  });
                },
              ),
              Text(_getRadioLabelA()),
            ],
          ),
          const SizedBox(
            width: 7.0,
          ),
          Row(
            children: [
              Radio(
                value: ListSort.SORT_B,
                groupValue: selectSort,
                activeColor: RColor.sigBuy,
                onChanged: (value) {
                  _setListSortB();
                  setState(() {
                    selectSort = value!;
                  });
                },
              ),
              Text(_getRadioLabelB()),
            ],
          ),
          const SizedBox(
            width: 15.0,
          ),
        ],
      ),
    );
  }

  //리스트 정렬 A
  _setListSortA() {
    if (topHit) {
      _vList1.sort((a, b) {
        return double.parse(b.profitRate).compareTo(double.parse(a.profitRate));
      });
    } else if (topPrf) {
      _vList2.sort((a, b) {
        return int.parse(b.winningRate).compareTo(int.parse(a.winningRate));
      });
    } else if (topSta) {
      _vList3.sort((a, b) {
        return double.parse(b.winningRate)
            .compareTo(double.parse(a.winningRate));
      });
    } else if (topMax) {
      _vList4.sort((a, b) {
        return double.parse(b.avgProfitRate)
            .compareTo(double.parse(a.avgProfitRate));
      });
    } else if (topAvg) {
      _vList5.sort((a, b) {
        return double.parse(b.avgProfitRate)
            .compareTo(double.parse(a.avgProfitRate));
      });
    } else if (topSht) {
      _vList7.sort((a, b) {
        return double.parse(a.holdingDays)
            .compareTo(double.parse(b.holdingDays));
      });
    } else if (topTpc) {
      _vList9.sort((a, b) {
        return double.parse(b.tradeDate).compareTo(double.parse(a.tradeDate));
      });
    }
  }

  //리스트 정렬 B
  _setListSortB() {
    if (topHit) {
      _vList1.sort((a, b) {
        return int.parse(b.tradeDttm).compareTo(int.parse(a.tradeDttm));
      });
    } else if (topPrf) {
      _vList2.sort((a, b) {
        return int.parse(b.tradeDttm).compareTo(int.parse(a.tradeDttm));
      });
    } else if (topSta) {
      _vList3.sort((a, b) {
        return int.parse(b.waitingDays).compareTo(int.parse(a.waitingDays));
      });
    } else if (topMax) {
      _vList4.sort((a, b) {
        return int.parse(b.tradeDttm).compareTo(int.parse(a.tradeDttm));
      });
    } else if (topAvg) {
      _vList5.sort((a, b) {
        return int.parse(b.waitingDays).compareTo(int.parse(a.waitingDays));
      });
    } else if (topSht) {
      _vList7.sort((a, b) {
        return double.parse(a.elapsedDays)
            .compareTo(double.parse(b.elapsedDays));
      });
    } else if (topTpc) {
      _vList9.sort((a, b) {
        return double.parse(b.regDttm).compareTo(double.parse(a.regDttm));
      });
    }
  }

  String _getRadioLabelA() {
    if (topHit) {
      return '수익률 순';
    } else if (topPrf) {
      return '적중률 순';
    } else if (topSta) {
      return '적중률 순';
    } else if (topMax) {
      return '평균수익률 순';
    } else if (topAvg) {
      return '평균수익률 순';
    } else if (topSht) {
      return '평균 보유기간 순';
    } else if (topTpc) {
      return '매수일 순';
    }
    return '';
  }

  String _getRadioLabelB() {
    if (topHit) {
      return '매수일 순';
    } else if (topPrf) {
      return '매수일 순';
    } else if (topSta) {
      return '관망기간 순';
    } else if (topMax) {
      return '매수일 순';
    } else if (topAvg) {
      return '관망기간 순';
    } else if (topSht) {
      return '최근 신호 발생 순';
    } else if (topTpc) {
      return '최근 주간 토픽 순';
    }
    return '';
  }

  String _getColumnMiddle() {
    if (topHit) {
      return '수익률';
    } else if (topPrf) {
      return '적중률';
    } else if (topSta) {
      return '적중률';
    } else if (topMax) {
      return '평균수익률';
    } else if (topAvg) {
      return '평균수익률';
    } else if (topSht) {
      return '평균보유기간';
    } else if (topTpc) {
      return '매수일';
    }
    return '';
  }

  String _getColumnEnd() {
    if (topHit) {
      return '매수일';
    } else if (topPrf) {
      return '매수일';
    } else if (topSta) {
      return '관망기간';
    } else if (topMax) {
      return '매수일';
    } else if (topAvg) {
      return '관망기간';
    } else if (topSht) {
      return '신호상태';
    } else if (topTpc) {
      return '주간토픽';
    }
    return '';
  }

  String _getPageTitle() {
    if (topHit) {
      return '매수 후 급등 종목';
    } else if (topPrf) {
      return '적중률 높은 종목 중 최근 매수 종목';
    } else if (topSta) {
      return '적중률 높은 종목 중 관망 상태인 종목';
    } else if (topMax) {
      return '평균수익률 높은 종목 중 최근 3일 매수 종목';
    } else if (topAvg) {
      return '평균수익률 높은 종목 중 관망 상태인 종목';
    } else if (topSht) {
      return '평균 보유 기간 짧은 종목';
    } else if (topTpc) {
      return '라씨 매매비서의 주간 토픽 중 최근 매수 종목';
    }
    return '';
  }
}

enum ListSort { SORT_A, SORT_B }
