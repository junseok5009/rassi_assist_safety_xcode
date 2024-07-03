import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_data.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi13.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2021.03.09
/// 2022.07.14 - JS reportDiv 0 : 증권사 리포트 추가로 인한 수정
/// 2024.07 - 마켓뷰 개편에 따른 디자인 변경
/// 분석리포트
class ReportPage extends StatelessWidget {
  static const routeName = '/page_report';
  static const String TAG = "[ReportPage] ";
  static const String TAG_NAME = '라씨로_분석리포트';
  static const String LD_CODE = '';

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: RColor.deepStat,
          elevation: 0,
        ),
        body: const ReportWidget(),
      ),
    );
  }
}

class ReportWidget extends StatefulWidget {
  const ReportWidget({super.key});

  @override
  State<StatefulWidget> createState() => ReportState();
}

class ReportState extends State<ReportWidget> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  String repDiv = '';
  String repName = '';
  String repDesc = '';

  int pageNum = 0;
  final List<Rassi13> _repList = [];
  final List<StockData> _recentList = [];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(ReportPage.TAG_NAME);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      args = ModalRoute.of(context)!.settings.arguments as PgData;
      repDiv = args.pgSn; //report div
      repName = args.pgData; //report name

      DLog.d(ReportPage.TAG, "delayed user id : $_userId");
      if (_userId != '') {
        _fetchPosts(
            TR.RASSI13,
            jsonEncode(<String, String>{
              'userId': _userId,
              'reportDiv': repDiv,
              'pageNo': pageNum.toString(),
              'pageItemSize': '5',
            }));
      }
    });
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    if (_bYetDispose) {
      setState(() {
        _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      });
    }
  }

  @override
  void dispose() {
    _bYetDispose = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RColor.bgBasic_fdfdfd,
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: repName,
        elevation: 1,
      ),
      body: ListView(
        children: [
          _setPageHeader(),
          ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: _repList.length,
            itemBuilder: (context, index) {
              return TileRassi13(_repList[index], repDiv);
            },
          ),
          const SizedBox(height: 15),

          _setMoreButton('+ 관련 AI속보', '더보기'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  //마켓뷰 헤더
  Widget _setPageHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      color: const Color(0xffF5F5F5),
      child: Column(
        children: [
          Container(
            child: Text(
              repDesc,
              style: TStyle.content16,
            ),
          ),

          // _setRecentStock(), //최근 관련 종목
          _setRecentReport(), // 증권사 리포트 추가
        ],
      ),
    );
  }

  //최근 관련 종목
  Widget _setRecentStock() {
    return Visibility(
      visible: _recentList != null && _recentList.length > 0 && repDiv != '0',
      child: Container(
        padding: const EdgeInsets.only(bottom: 15),
        // color: RColor.bgAiReport,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: UIStyle.boxRoundLine6(),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                '최근 관련 종목',
                style: TStyle.commonTitle,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 7.0,
                alignment: WrapAlignment.center,
                children: List.generate(_recentList.length, (index) => TileChipStock(_recentList[index])),
              )
            ],
          ),
        ),
      ),
    );
  }

  //최근 리포트
  Widget _setRecentReport() {
    return Visibility(
      visible: _repList != null && _repList.length > 0 && repDiv == '0',
      child: Container(
        padding: const EdgeInsets.only(bottom: 15),
        color: RColor.bgAiReport,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: UIStyle.boxRoundLine6(),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                '주목 리포트',
                style: TStyle.commonTitle,
              ),
              const SizedBox(height: 10),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _repList.length,
                itemBuilder: (BuildContext context, int index) {
                  return TileChipReport(_repList[index], repDiv);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //더보기 버튼
  Widget _setMoreButton(
    String title,
    String subText,
  ) {
    return Visibility(
      visible: true,
      child: Column(
        children: [
          MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17.0),
              side: const BorderSide(color: RColor.lineGrey),
            ),
            color: Colors.white,
            textColor: RColor.mainColor,
            padding: const EdgeInsets.all(2.0),
            child: SizedBox(
              width: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TStyle.subTitle,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    subText,
                    style: TStyle.textMGrey,
                  ),
                ],
              ),
            ),
            onPressed: () {
              _requestData();
            },
          ),
        ],
      ),
    );
  }

  void _requestData() {
    pageNum = pageNum + 1;
    _fetchPosts(
        TR.RASSI13,
        jsonEncode(<String, String>{
          'userId': _userId,
          'reportDiv': repDiv,
          'pageNo': pageNum.toString(),
          'pageItemSize': '5',
        }));
  }

  //네트워크 에러 알림
  void _showDialogNetErr() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
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
                  const SizedBox(height: 5),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Text(
                      '안내',
                      style: TStyle.commonTitle,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    RString.err_network,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text(
                            '확인',
                            style: TStyle.btnTextWht16,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(ReportPage.TAG, trStr + ' ' + json);

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http
          .post(
            url,
            body: json,
            headers: Net.headers,
          )
          .timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if (_bYetDispose) _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      DLog.d(ReportPage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(ReportPage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(ReportPage.TAG, response.body);

    if (trStr == TR.RASSI13) {
      final TrRassi13 resData = TrRassi13.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        repDesc = resData.reportDesc;

        if (resData.listData.length > 0) {
          List<Rassi13> rassiList = resData.listData;
          _repList.addAll(rassiList);

          if (pageNum == 0) {
            for (int i = 0; i < rassiList.length; i++) {
              if (rassiList[i].listStock != null && rassiList[i].listStock.length > 0) {
                _recentList.addAll(rassiList[i].listStock);
              }
            }
          }
        }

        setState(() {});
      }
    }
  }
}
