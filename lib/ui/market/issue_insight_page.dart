import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_status.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue04.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue10.dart';
import 'package:rassi_assist/models/tr_issue/tr_issue11.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/market/issue_calendar_page.dart';
import 'package:rassi_assist/ui/market/issue_new_viewer.dart';
import 'package:rassi_assist/ui/tiles/tile_related_stock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

/// 2024.07
/// 이슈 인사이트
class IssueInsightPage extends StatefulWidget {
  static const routeName = '/page_issue_insight';
  static const String TAG = "[IssueInsightPage] ";
  static const String TAG_NAME = '';

  const IssueInsightPage({super.key});

  @override
  State<StatefulWidget> createState() => IssueInsightState();
}

class IssueInsightState extends State<IssueInsightPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;

  final String yearMonth = TStyle.getYearMonthString();

  IssueDivType subType = IssueDivType.OCCUR;
  List<IssueGenMonth> _issMonthTopList = [];
  List<IssueTopDay> _issDayTopList = [];
  List<NewIssue> _newIssueList = [];

  String _trendTitle1 = '';
  String _trendTitle2 = '';
  String _trendContent1 = '';
  String _trendContent2 = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      IssueInsightPage.TAG_NAME,
    );
    _loadPrefData().then((value) {
      Future.delayed(Duration.zero, () {
        DLog.d(IssueInsightPage.TAG, "delayed user id : $_userId");
        DLog.d(IssueInsightPage.TAG, "delayed subType : ${subType.name}");

        if (_userId != '') {
          //월별 발생 순위
          _fetchPosts(
              TR.ISSUE11,
              jsonEncode(<String, String>{
                'userId': _userId,
                'issueMonth': yearMonth,
                'menuDiv': IssueDivType.OCCUR.name,
                'pageNo': '0',
                'pageItemSize': '10',
              }));

          //트랜드
          _fetchPosts(
              TR.ISSUE11,
              jsonEncode(<String, String>{
                'userId': _userId,
                'issueMonth': yearMonth,
                'menuDiv': IssueDivType.TREND.name,
              }));

          //일별 상승 랭킹
          _fetchPosts(
              TR.ISSUE11,
              jsonEncode(<String, String>{
                'userId': _userId,
                'issueMonth': yearMonth,
                'menuDiv': IssueDivType.UPDAY.name,
                'pageNo': '0',
                'pageItemSize': '10',
              }));

          /// (전문 개발중??)
          // _fetchPosts(
          //     TR.ISSUE11,
          //     jsonEncode(<String, String>{
          //       'userId': _userId,
          //       'issueMonth': yearMonth,
          //       'menuDiv': IssueDivType.UPMON.name,
          //       'pageNo': '0',
          //       'pageItemSize': '10',
          //     }));

          _fetchPosts(
              TR.ISSUE10,
              jsonEncode(<String, String>{
                'userId': _userId,
                'issueMonth': yearMonth,
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
        '이슈 인사이트',
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

              //
              _setMonthTopIssue,
              const SizedBox(height: 10),
              CommonView.setDivideLine,
              const SizedBox(height: 10),

              //
              _setMonthTrend,
              CommonView.setDivideLine,
              const SizedBox(height: 10),

              // 하루 동안 상승 랭킹
              _setDayTopIssue,
              const SizedBox(height: 25),

              //
              _setNewIssueList,
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // 한달동안 많이 발섕한 이슈
  Widget get _setMonthTopIssue {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '한달동안 가장 많이 발생했던 이슈는?',
            style: TStyle.defaultTitle,
          ),
          const SizedBox(height: 15),
          const Text('한달간 오늘의 이슈 등록 횟수가 가장 많았던 뜨거운 이슈를 살펴보세요'),
          const SizedBox(height: 15),

          //
          _setTreeMap,
          const SizedBox(height: 15),

          ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: _issMonthTopList.length > 10 ? 10 : _issMonthTopList.length,
            itemBuilder: (context, index) {
              return TileMonthTopIssue(_issMonthTopList[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget get _setTreeMap {
    return Container(
      width: double.infinity,
      height: 330,
      child: _issMonthTopList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SfTreemap(
              dataCount: _issMonthTopList.length > 20 ? 20 : _issMonthTopList.length,
              weightValueMapper: (int index) {
                return double.parse(_issMonthTopList[index].occurCount);
              },
              levels: <TreemapLevel>[
                TreemapLevel(
                  groupMapper: (int index) {
                    return _issMonthTopList[index].keyword;
                  },
                  labelBuilder: (BuildContext context, TreemapTile tile) {
                    return Padding(
                      padding: const EdgeInsets.all(2.5),
                      child: Text(
                        tile.group,
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  },
                  tooltipBuilder: (BuildContext context, TreemapTile tile) {
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text('''theme  : ${tile.group}\n횟수 : ${tile.weight}회''',
                          style: const TextStyle(color: Colors.black)),
                    );
                  },
                ),
              ],
            ),
    );
  }

  // 한달동안 이슈 트랜드
  Widget get _setMonthTrend {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '한달동안의 이슈 트랜드는?',
            style: TStyle.defaultTitle,
          ),
          const SizedBox(height: 15),
          const Text('매월 1일부터 말일까지 발생된 이슈의 트랜드와 지수'),
          const SizedBox(height: 15),

          Text(_trendTitle1),
          Text(_trendContent1),
          Text(_trendTitle2),
          Text(_trendContent2),

          // ListView.builder(
          //   physics: const ScrollPhysics(),
          //   shrinkWrap: true,
          //   itemCount: _issMonthTopList.length > 10 ? 10 : _issMonthTopList.length,
          //   itemBuilder: (context, index) {
          //     return TileMonthTopIssue(_issMonthTopList[index], index);
          //   },
          // ),
        ],
      ),
    );
  }

  // 하루에 크게 상승한 이슈
  Widget get _setDayTopIssue {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이슈로 선정되고 하루 동안 크게 상승했던 이슈는?',
            style: TStyle.defaultTitle,
          ),
          const SizedBox(height: 15),
          const Text('이슈가 발생된 하루 동안 가장 상승폭이 컷던 이슈를 살펴 보세요.'),
          const SizedBox(height: 15),
          ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: _issDayTopList.length > 10 ? 10 : _issDayTopList.length,
            itemBuilder: (context, index) {
              return TileDayTopIssue(_issDayTopList[index]);
            },
          ),
        ],
      ),
    );
  }

  // 한달간 가장 많이 상승한 이슈는? => TODO 개발중???

  // 새롭게 등장한 이슈
  Widget get _setNewIssueList {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '새롭게 등장한 이슈',
            style: TStyle.defaultTitle,
          ),
          const SizedBox(height: 15),
          ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: _newIssueList.length,
            itemBuilder: (context, index) {
              return TileNewIssue(_newIssueList[index]);
            },
          ),
        ],
      ),
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

  void _requestData(String sYearMonth) {
    _fetchPosts(
        TR.ISSUE11,
        jsonEncode(<String, String>{
          'userId': _userId,
          'issueMonth': sYearMonth,
          'menuDiv': IssueDivType.OCCUR.name,
          'pageNo': '0',
          'pageItemSize': '10',
        }));

    //트랜드
    _fetchPosts(
        TR.ISSUE11,
        jsonEncode(<String, String>{
          'userId': _userId,
          'issueMonth': yearMonth,
          'menuDiv': IssueDivType.TREND.name,
        }));

    //일별 상승 랭킹
    _fetchPosts(
        TR.ISSUE11,
        jsonEncode(<String, String>{
          'userId': _userId,
          'issueMonth': yearMonth,
          'menuDiv': IssueDivType.UPDAY.name,
          'pageNo': '0',
          'pageItemSize': '10',
        }));

    // _fetchPosts(
    //     TR.ISSUE11,
    //     jsonEncode(<String, String>{
    //       'userId': _userId,
    //       'issueMonth': sYearMonth,
    //       'menuDiv': IssueDivType.OCCUR.name,
    //       'pageNo': '0',
    //       'pageItemSize': '10',
    //     }));
  }

  void _fetchPosts(String trStr, String json) async {
    DLog.d(IssueInsightPage.TAG, '$trStr $json');

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
      DLog.d(IssueInsightPage.TAG, 'ERR : TimeoutException (12 seconds)');
      //_showDialogNetErr();
    }
  }

  Future<void> _parseTrData(String trStr, final http.Response response) async {
    DLog.d(IssueInsightPage.TAG, response.body);

    if (trStr == TR.ISSUE11) {
      final TrIssue11 resData = TrIssue11.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Issue11 item = resData.retData;
        DLog.d(IssueInsightPage.TAG, item.menuDiv);

        if (item.menuDiv == IssueDivType.OCCUR.name) {
          _issMonthTopList = item.listGenMonth;
        }
        if (item.menuDiv == IssueDivType.TREND.name) {
          _trendTitle1 = item.title1;
          _trendTitle2 = item.title2;
          _trendContent1 = item.content1;
          _trendContent2 = item.content2;
        }
        if (item.menuDiv == IssueDivType.UPDAY.name) {
          _issDayTopList = item.listDayTop;
        }

        setState(() {});
      }
    }
    //
    else if (trStr == TR.ISSUE10) {
      final TrIssue10 resData = TrIssue10.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Issue10? item = resData.retData;
        if (item != null) {
          _newIssueList = item.issueList;

          setState(() {});
        }
      }
    }
  }
}
