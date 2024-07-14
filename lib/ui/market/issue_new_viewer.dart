import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_status.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue04.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/market/issue_calendar_page.dart';
import 'package:rassi_assist/ui/tiles/tile_related_stock.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2024.07
/// 이슈 상세보기
class IssueNewViewer extends StatefulWidget {
  static const routeName = '/page_issue_calendar';
  static const String TAG = "[IssueCalendarPage] ";
  static const String TAG_NAME = '';

  const IssueNewViewer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IssueNewViewerState();
}

class IssueNewViewerState extends State<IssueNewViewer> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;

  String _stkName = "";
  String _stkCode = "";
  String _keyword = '';
  String _newsSn = '';
  String _issueSn = '';
  String _issueTitle = "";
  String _issueDate = "";
  String _issueCont = "";

  List<StockStatus> _stkList = [];
  int _stkListPageNum = 2;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      IssueNewViewer.TAG_NAME,
    );
    _loadPrefData().then((value) {
      Future.delayed(Duration.zero, () {
        DLog.d(IssueNewViewer.TAG, "delayed user id : $_userId");
        args = ModalRoute.of(context)!.settings.arguments as PgData;
        if (_newsSn.isEmpty) {
          _stkName = args.stockName;
          _stkCode = args.stockCode;
          _newsSn = args.pgSn;
          _issueSn = args.pgData;
          _keyword = args.data;
        }

        if (_userId != '') {
          _fetchPosts(
              TR.ISSUE04,
              jsonEncode(<String, String>{
                'userId': _userId,
                'newsSn': _newsSn,
              }));
        }
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
      backgroundColor: RColor.bgBasic_fdfdfd,
      appBar: CommonAppbar.simpleWithExit(
        context,
        '$_keyword 이슈 상세보기',
        Colors.black,
        RColor.bgBasic_fdfdfd,
        Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              _setRecentIssue,
              const SizedBox(height: 15),
              _setCalendarBanner,
              _setRelatedStocks,
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  // 최근 발생 이슈
  Widget get _setRecentIssue {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '가장 최근 발생된 이슈',
            style: TStyle.defaultTitle,
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            decoration: UIStyle.boxWithOpacity16(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      TStyle.getDateFormat(_issueDate),
                      style: const TextStyle(
                        //작은 그레이 텍스트
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  _issueTitle,
                  style: TStyle.content16T,
                ),
                const SizedBox(height: 15),
                Html(
                  data: _issueCont,
                  style: {
                    "body": Style(
                      fontSize: FontSize(16.0),
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                      lineHeight: LineHeight.percent(125),
                    ),
                    "a": Style(
                      display: Display.none,
                    ),
                  },
                  // onLinkTap: (url, attributes, element) {
                  //   commonLaunchURL(url!);
                  // },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 이슈 캘린더(히스토리) 연결 배너
  Widget get _setCalendarBanner {
    return InkWell(
      onTap: () {
        if (_issueSn.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IssueCalendarPage(),
              settings: RouteSettings(
                arguments: PgData(
                  pgData: _issueSn,
                  data: _keyword,
                ),
              ),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: AppGlobal().isTablet ? 150 : 130,
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xff353b6e),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(1, 1), //changes position of shadow
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_keyword의 이슈 캘린더',
                  style: TStyle.btnTextWht16,
                ),
                const SizedBox(height: 10),
                const Text(
                  '해당 이슈의 히스토리를 확인해보세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Image.asset(
                'images/icon_calendar1.png',
                width: 90,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 관련 종목
  Widget get _setRelatedStocks {
    return Column(
      children: [
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$_keyword 관련 종목',
                style: TStyle.defaultTitle,
              ),
              Text(
                '(총 ${_stkList.length}종목)',
                style: TStyle.textGrey14S,
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _stkList.length ~/ (10 * _stkListPageNum) > 0 ? 10 * _stkListPageNum : _stkList.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return TileRelatedStock(_stkList[index]);
          },
        ),
        const SizedBox(height: 10),
        Visibility(
          visible: _stkList.length ~/ (10 * _stkListPageNum) > 0,
          child: InkWell(
            onTap: () {
              setState(() {
                _stkListPageNum++;
              });
            },
            child: Center(
              child: Container(
                //width: 10,
                width: 150,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: UIStyle.boxRoundLine20(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "+관련 종목",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      " 더보기",
                      style: TStyle.puplePlainStyle(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  //안내 다이얼로그
  void _showDialogDesc(String desc) {
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
                const SizedBox(height: 25),
                const Text(
                  '안내',
                  style: TStyle.title20,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Text(
                  desc,
                  style: TStyle.defaultContent,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  void _requestIssue04(String type) {
    _fetchPosts(
        TR.ISSUE04,
        jsonEncode(<String, String>{
          'userId': _userId,
          // 'themeCode': _themeCode,
        }));
  }

  void _fetchPosts(String trStr, String json) async {
    DLog.d(IssueNewViewer.TAG, '$trStr $json');

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
    } on TimeoutException catch (_) {
      DLog.d(IssueNewViewer.TAG, 'ERR : TimeoutException (12 seconds)');
      //_showDialogNetErr();
    }
  }

  Future<void> _parseTrData(String trStr, final http.Response response) async {
    DLog.d(IssueNewViewer.TAG, response.body);

    if (trStr == TR.ISSUE04) {
      final TrIssue04 resData = TrIssue04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Issue04? item = resData.retData;
        if (item != null) {
          DLog.d(IssueNewViewer.TAG, item.issueInfo.toString());
          _keyword = item.issueInfo!.keyword;
          _issueTitle = item.issueInfo!.title;
          _issueDate = item.issueInfo!.issueDttm;
          _issueCont = item.issueInfo!.content;
          _stkList = item.stkList;
          setState(() {});
        }
      }
    }
  }
}
