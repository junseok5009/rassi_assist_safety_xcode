import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_honor01.dart';
import 'package:rassi_assist/models/tr_honor02.dart';
import 'package:rassi_assist/models/tr_honor03.dart';
import 'package:rassi_assist/models/tr_honor04.dart';
import 'package:rassi_assist/models/tr_honor05.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/common_appbar.dart';
import '../../common/strings.dart';
import '../../common/ui_style.dart';

/// 2020.11.18
/// 성과 TOP 페이지
class SignalTopPage extends StatefulWidget {
  static const routeName = '/page_signal_top';
  static const String TAG = "[SignalTopPage]";
  SignalTopPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => SignalTopPageState();
}

class SignalTopPageState extends State<SignalTopPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전
  String TAG_NAME = '성과TOP_';
  ListSort selectSort = ListSort.SORT_A;
  bool topHit = false,
      topPrf = false,
      topSta = false,
      topMax = false,
      topAvg = false;
  List<Honor01> _hList1 = [];
  List<Honor02> _hList2 = [];
  List<Honor03> _hList3 = [];
  List<Honor04> _hList4 = [];
  List<Honor05> _hList5 = [];

  @override
  void initState() {
    super.initState();

    _loadPrefData().then(
      (_) {
        Future.delayed(
          Duration.zero,
          () {
            PgData args = ModalRoute.of(context)!.settings.arguments as PgData;
            if (_userId != '' && args != null) {
              String sTr = '';
              if (args.pgData == 'HIT') {
                TAG_NAME = '성과TOP_적중률';
                sTr = TR.HONOR01;
              } else if (args.pgData == 'PRF') {
                TAG_NAME = '성과TOP_수익매매';
                sTr = TR.HONOR02;
              } else if (args.pgData == 'STA') {
                TAG_NAME = '성과TOP_누적수익률';
                sTr = TR.HONOR03;
              } else if (args.pgData == 'MAX') {
                TAG_NAME = '성과TOP_최대수익률';
                sTr = TR.HONOR04;
              } else if (args.pgData == 'AVG') {
                TAG_NAME = '성과TOP_평균수익률';
                sTr = TR.HONOR05;
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
        );
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
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: CommonAppbar.basicColorWithAction(
          context,
          '성과 TOP 종목',
          RColor.mainColor,
          Colors.white,
          0,
          [
            IconButton(
              icon: const ImageIcon(
                AssetImage('images/rassi_icon_qu_bl.png'),
                color: Colors.white,
                size: 22,
              ),
              onPressed: (){
                _showDialogTopDesc();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            children: [
              Visibility(
                visible: topHit,
                child: _setTopList1(context),
              ),
              Visibility(
                visible: topPrf,
                child: _setTopList2(context),
              ),
              Visibility(
                visible: topSta,
                child: _setTopList3(context),
              ),
              Visibility(
                visible: topMax,
                child: _setTopList4(context),
              ),
              Visibility(
                visible: topAvg,
                child: _setTopList5(context),
              ),
              // Text('================'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _setTopList1(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 2750,
      color: Colors.grey.shade50,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _hList1.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _setHeaderView();
            return TileHonor01(_hList1[index - 1]);
          }),
    );
  }

  Widget _setTopList2(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 2750,
      color: Colors.grey.shade50,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _hList2.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _setHeaderView();
            return TileHonor02(_hList2[index - 1]);
          }),
    );
  }

  Widget _setTopList3(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 2750,
      color: Colors.grey.shade50,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _hList3.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _setHeaderView();
            return TileHonor03(_hList3[index - 1]);
          }),
    );
  }

  Widget _setTopList4(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 2750,
      color: Colors.grey.shade50,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _hList4.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _setHeaderView();
            return TileHonor04(_hList4[index - 1]);
          }),
    );
  }

  Widget _setTopList5(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 2750,
      color: Colors.grey.shade50,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _hList5.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _setHeaderView();
            return TileHonor05(_hList5[index - 1]);
          }),
    );
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(SignalTopPage.TAG, '$trStr $json');

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
    DLog.d(SignalTopPage.TAG, response.body);

    if (trStr == TR.HONOR01) {
      final TrHonor01 resData = TrHonor01.fromJson(jsonDecode(response.body));
      // DLog.d(SignalTopPage.TAG, resData.retData[0].toString());
      _hList1 = resData.retData;
      topHit = true;
      setState(() {});
    } else if (trStr == TR.HONOR02) {
      final TrHonor02 resData = TrHonor02.fromJson(jsonDecode(response.body));
      // DLog.d(SignalTopPage.TAG, resData.retData[0].toString());
      _hList2 = resData.retData;
      topPrf = true;
      setState(() {});
    } else if (trStr == TR.HONOR03) {
      final TrHonor03 resData = TrHonor03.fromJson(jsonDecode(response.body));
      // DLog.d(SignalTopPage.TAG, resData.retData[0].toString());
      _hList3 = resData.retData;
      topSta = true;
      setState(() {});
    } else if (trStr == TR.HONOR04) {
      final TrHonor04 resData = TrHonor04.fromJson(jsonDecode(response.body));
      // DLog.d(SignalTopPage.TAG, resData.retData[0].toString());
      _hList4 = resData.retData;
      topMax = true;
      setState(() {});
    } else if (trStr == TR.HONOR05) {
      final TrHonor05 resData = TrHonor05.fromJson(jsonDecode(response.body));
      // DLog.d(SignalTopPage.TAG, resData.retData[0].toString());
      _hList5 = resData.retData;
      topAvg = true;
      setState(() {});
    }
  }

  Widget _setHeaderView() {
    return Container(
      width: double.infinity,
      height: 250,
      color: RColor.mainColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Image.asset(
                _getImagePath(),
                fit: BoxFit.cover,
                height: 70,
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                _getPageTitle(),
                style: const TextStyle(
                  //좀 더 작은(리스트) 소항목 타이틀 (bold)
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
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
                              right: BorderSide(color: Colors.grey, width: 1)),
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
      _hList1.sort((a, b) {
        return double.parse(b.winningRate)
            .compareTo(double.parse(a.winningRate));
      });
    } else if (topPrf) {
      _hList2.sort((a, b) {
        return int.parse(b.tradeCount).compareTo(int.parse(a.tradeCount));
      });
    } else if (topSta) {
      _hList3.sort((a, b) {
        return double.parse(b.sumProfitRate)
            .compareTo(double.parse(a.sumProfitRate));
      });
    } else if (topMax) {
      _hList4.sort((a, b) {
        return double.parse(b.maxProfitRate)
            .compareTo(double.parse(a.maxProfitRate));
      });
    } else if (topAvg) {
      _hList5.sort((a, b) {
        return double.parse(b.avgProfitRate)
            .compareTo(double.parse(a.avgProfitRate));
      });
    }
  }

  //리스트 정렬 B
  _setListSortB() {
    if (topHit) {
      _hList1.sort((a, b) {
        return int.parse(b.tradeCount).compareTo(int.parse(a.tradeCount));
      });
    } else if (topPrf) {
      _hList2.sort((a, b) {
        return int.parse(b.holdingDays).compareTo(int.parse(a.holdingDays));
      });
    } else if (topSta) {
      _hList3.sort((a, b) {
        return int.parse(b.tradeCount).compareTo(int.parse(a.tradeCount));
      });
    } else if (topMax) {
      _hList4.sort((a, b) {
        return int.parse(b.holdingDays).compareTo(int.parse(a.holdingDays));
      });
    } else if (topAvg) {
      _hList5.sort((a, b) {
        return int.parse(b.tradeCount).compareTo(int.parse(a.tradeCount));
      });
    }
  }

  String _getRadioLabelA() {
    if (topHit) {
      return '적중률 높은 순';
    } else if (topPrf) {
      return '매매횟수 순';
    } else if (topSta) {
      return '누적수익률 순';
    } else if (topMax) {
      return '최대수익률 순';
    } else if (topAvg) {
      return '평균수익률 순';
    }
    return '';
  }

  String _getRadioLabelB() {
    if (topHit) {
      return '매매횟수 순';
    } else if (topPrf) {
      return '보유기간 순';
    } else if (topSta) {
      return '매매횟수 순';
    } else if (topMax) {
      return '보유기간 순';
    } else if (topAvg) {
      return '매매횟수 순';
    }
    return '';
  }

  String _getImagePath() {
    if (topHit) {
      return 'images/main_hnr_win_trade.png';
    } else if (topPrf) {
      return 'images/main_hnr_avg_ratio.png';
    } else if (topSta) {
      return 'images/main_hnr_max_ratio.png';
    } else if (topMax) {
      return 'images/main_hnr_win_ratio.png';
    } else if (topAvg) {
      return 'images/main_hnr_acc_ratio.png';
    }
    return '';
  }

  String _getPageTitle() {
    if (topHit) {
      return '적중률 TOP 50';
    } else if (topPrf) {
      return '수익난 매매 TOP 50';
    } else if (topSta) {
      return '누적수익률 TOP 50';
    } else if (topMax) {
      return '최대수익률 TOP 50';
    } else if (topAvg) {
      return '평균수익률 TOP 50';
    }
    return '';
  }

  String _getColumnMiddle() {
    if (topHit) {
      return '적중률';
    } else if (topPrf) {
      return '매매횟수';
    } else if (topSta) {
      return '누적수익률';
    } else if (topMax) {
      return '최대수익률';
    } else if (topAvg) {
      return '평균수익률';
    }
    return '';
  }

  String _getColumnEnd() {
    if (topHit) {
      return '매매횟수';
    } else if (topPrf) {
      return '보유기간';
    } else if (topSta) {
      return '매매횟수';
    } else if (topMax) {
      return '보유기간';
    } else if (topAvg) {
      return '매매횟수';
    }
    return '';
  }

  //성과 TOP 내용 다이얼로그
  void _showDialogTopDesc() {
    String title = '';
    String content = '';
    if (topHit) {
      title = '적중률 TOP 50';
      content = RString.desc_signal_top_hit;
    }
    else if (topPrf) {
      title = '수익난 매매 TOP 50';
      content = RString.desc_signal_top_prf;
    }
    else if (topSta) {
      title = '누적수익률 TOP 50';
      content = RString.desc_signal_top_sta;
    }
    else if (topMax) {
      title = '최대수익률 TOP 50';
      content = RString.desc_signal_top_max;
    }
    else if (topAvg) {
      title = '평균수익률 TOP 50';
      content = RString.desc_signal_top_avg;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: UIStyle.borderRoundedDialog(),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'images/rassibs_img_infomation.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: 25.0,
                ),
                Text(
                  title,
                  style: TStyle.title20,
                  textAlign: TextAlign.center,
                  
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Text(
                  content,
                  style: TStyle.defaultContent,
                  textAlign: TextAlign.center,
                  
                ),
                const SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

enum ListSort { SORT_A, SORT_B }
