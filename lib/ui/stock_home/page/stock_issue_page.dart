import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/app_global.dart';
import 'package:rassi_assist/models/tr_issue06.dart';
import 'package:rassi_assist/models/tr_kword01.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_stock_info_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/net.dart';
import '../../../common/strings.dart';
import '../../../models/pg_data.dart';
import '../../main/base_page.dart';
import '../../news/issue_viewer.dart';

/// 2023.01.22 - JS
/// 종목홈_이슈상세 페이지 - 사용하지 않음
class StockIssuePage extends StatefulWidget {
  //const StockIssuePage({Key? key}) : super(key: key);
  static const String TAG_NAME = '종목홈_이슈상세';

  @override
  State<StockIssuePage> createState() => _StockIssuePageState();
}

class _StockIssuePageState extends State<StockIssuePage> {
  final _appGlobal = AppGlobal();
  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  String stkName = "";
  String stkCode = "";

  bool _hasKeywordData = false;
  bool _hasIssueData = false;
  List<KeywordData> _newList = [];
  List<KeywordData> _oldList = [];
  List<Issue06> _issueList = [];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      StockIssuePage.TAG_NAME,
    );
    stkCode = _appGlobal.stkCode;
    stkName = _appGlobal.stkName;
    _loadPrefData().then((_) => {
          if (_userId != '')
            {
              requestTrAll(),
            },
          Provider.of<StockInfoProvider>(context, listen: false)
              .postRequest(stkCode),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Text(
              "종목이슈",
              style: TStyle.title18T,
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: false,
        leadingWidth: 84,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              iconSize: 22,
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              // 패딩 설정
              constraints: const BoxConstraints(),
              // constraints
              onPressed: () => Navigator.of(context).pop(),
            ),
            IconButton(
              icon: const Icon(Icons.home_outlined, color: Colors.black),
              iconSize: 26,
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 5,
              ),
              // 패딩 설정
              constraints: const BoxConstraints(),
              // constraints
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(
                  height: 15.0,
                ),
                Visibility(
                  visible: _hasKeywordData,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _setSubTitle('종목키워드', TStyle.commonTitle),
                      _setStockKeyword(),
                      const SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: _hasIssueData,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _setSubTitle('종목이슈', TStyle.commonTitle),
                      _setStockIssueList(),
                    ],
                  ),
                ),
                Visibility(
                  visible: !_hasKeywordData && !_hasIssueData,
                  child: Container(
                    margin: const EdgeInsets.only(top: 40.0),
                    width: double.infinity,
                    alignment: Alignment.topCenter,
                    child: const Text(
                      '해당 종목의 등록된 키워드 및\n종목 이슈가 없습니다.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //종목키워드
  Widget _setStockKeyword() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 10.0,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      alignment: Alignment.center,
      decoration: UIStyle.boxRoundLine15(),
      child: Column(
        children: [
          Wrap(
            spacing: 7.0,
            alignment: WrapAlignment.center,
            children: List.generate(_newList.length,
                (index) => ChipKeyword(_newList[index], RColor.yonbora2)),
          ),
          Wrap(
            spacing: 7.0,
            alignment: WrapAlignment.center,
            children: List.generate(_oldList.length,
                (index) => ChipKeyword(_oldList[index], RColor.yonbora2)),
          ),
        ],
      ),
    );
  }

  Widget _setSubTitle(String subTitle, TextStyle textStyle) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Text(
        subTitle,
        style: TStyle.commonTitle,
      ),
    );
  }

  //종목 이슈
  Widget _setStockIssueList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: _issueList.length,
      itemBuilder: (context, index) {
        return _tileIssueList(_issueList[index]);
      },
    );
  }

  Widget _tileIssueList(Issue06 item) {
    return Container(
      width: double.infinity,
      height: 260,
      margin: const EdgeInsets.all(10),
      decoration: UIStyle.boxRoundLine6(),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                image: DecorationImage(
                  image: NetworkImage(item.imageUrl),
                  fit: BoxFit.fill,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                  color: Color(0xbb121212),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Visibility(
                          visible:
                              TStyle.getDateDifferenceDyas(item.issueDttm) < 8,
                          child: const Text(
                            '최근이슈',
                            style: TStyle.btnTextWht13,
                          ),
                        ),
                        Text(
                          TStyle.getDateSFormat(item.issueDttm),
                          style: TStyle.btnTextWht12,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 7),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 0.9,
                        ),
                        borderRadius:
                            const BorderRadius.all(const Radius.circular(20.0)),
                      ),
                      child: Text(
                        ' ${item.keyword} ',
                        style: TStyle.btnContentWht15,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      item.title,
                      style: TStyle.btnTextWht15,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Wrap(
                  spacing: 10.0,
                  alignment: WrapAlignment.center,
                  children: List.generate(item.stkList.length, (index) {
                      return InkWell(
                        child: Text(
                          item.stkList[index].stockName,
                          style: TStyle.purpleThinStyle(),
                        ),
                        onTap: () {
                          basePageState.goStockHomePage(
                            item.stkList[index].stockCode,
                            item.stkList[index].stockName,
                            Const.STK_INDEX_HOME,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          //이슈 뷰어
          basePageState.callPageRouteUpData(
              IssueViewer(), PgData(userId: '', pgSn: item.newsSn));
        },
      ),
    );
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    if (_bYetDispose) {
      setState(() {
        _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      });
    }
  }

  requestTrAll() async {
    String _jsonKWORD01 = jsonEncode(<String, String>{
      'userId': _userId,
      'stockCode': stkCode,
    });
    String _jsonISSUE06 = jsonEncode(<String, String>{
      'userId': _userId,
      'stockCode': stkCode,
      'selectCount': '10',
      'includeData': 'Y',
    });

    await Future.wait([
      _fetchPosts(
        TR.KWORD01,
        _jsonKWORD01,
      ),
      _fetchPosts(
        TR.ISSUE06,
        _jsonISSUE06,
      ),
    ]);
  }

  //네트워크 에러 알림
  void _showDialogNetErr() {
    showDialog(
        context: context,
        barrierDismissible: false,
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
                    height: 5.0,
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Text(
                      '안내',
                      style: TStyle.commonTitle,
                    ),
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  const Text(
                    RString.err_network,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
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
  Future<void> _fetchPosts(String trStr, String json) async {
    try {
      var url = Uri.parse(Net.TR_BASE + trStr);
      final http.Response response = await http.post(
        url,
        body: json,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if (_bYetDispose) _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      _showDialogNetErr();
    } on SocketException catch (_) {
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    if (trStr == TR.KWORD01) {
      final TrKWord01 resData = TrKWord01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _newList = resData.retData.listNew;
        _oldList = resData.retData.listOld;
        _hasKeywordData = true;
        setState(() {});
      } else if (resData.retCode == RT.NO_DATA) {
        _hasKeywordData = false;
        setState(() {});
      }
    } else if (trStr == TR.ISSUE06) {
      final TrIssue06 resData = TrIssue06.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _issueList = resData.listData;
        _hasIssueData = true;
        setState(() {});
      } else if (resData.retCode == RT.NO_DATA) {
        _hasIssueData = false;
        setState(() {});
      }
    }
  }
}
