import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/stock_status.dart';
import 'package:rassi_assist/models/tr_issue04.dart';
import 'package:rassi_assist/models/tr_issue05.dart';
import 'package:rassi_assist/ui/tiles/tile_stock_status.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 2020.11.19
/// 이슈 상세 페이지
class IssueViewer extends StatelessWidget {
  static const routeName = '/page_issue_detail';
  static const String TAG = "[IssueViewer]";
  static const String TAG_NAME = '이슈상세보기';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: RColor.deepStat,
        elevation: 0,
      ),
      body: IssueDetailWidget(),
    );
  }
}

class IssueDetailWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IssueDetailState();
}

class IssueDetailState extends State<IssueDetailWidget> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;

  String stkName = "";
  String stkCode = "";
  String keyword = '';
  String newsSn = '';
  String _issueSn = '';
  String _issueTitle = "";
  String _issueDate = "";
  String _issueCont = "";
  Color statColor = Colors.grey;

  List<StockStatus> _stkList = [];
  int _stkListPageNum = 2;

  final List<Issue05> _issueList = [];
  int pageNum = 0;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(IssueViewer.TAG_NAME);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      DLog.d(IssueViewer.TAG, "delayed user id : $_userId");
      if (_userId != '') {
        _fetchPosts(
            TR.ISSUE04,
            jsonEncode(<String, String>{
              'userId': _userId,
              'newsSn': newsSn,
            }));
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
  Widget build(BuildContext context) {
    // final textTheme = Theme.of(context).textTheme;
    args = ModalRoute.of(context)!.settings.arguments as PgData;
    if (newsSn.isEmpty) {
      stkName = args.stockName;
      stkCode = args.stockCode;
      newsSn = args.pgSn;
      _issueSn = args.pgData;
    }
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: _setLayout(),
    );
  }

  Widget _setLayout() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: RColor.bgBlueCatch,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(null),
          ),
          const SizedBox(
            width: 10.0,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            _setHeaderInfo(),
            ListView.builder(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              itemCount: _issueList.length,
              itemBuilder: (context, index) {
                return _setIssueItem(_issueList[index]);
              },
            ),
            const SizedBox(
              height: 15,
            ),
            _setMoreButton('히스토리', ' 더보기 +'),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  //컨텐츠와 주요관련주
  Widget _setHeaderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          color: RColor.bgBlueCatch,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(
                label: Text(
                  keyword,
                  style: TStyle.btnTextWht15,
                ),
                backgroundColor: RColor.bgBlueIssueBtn,
              ),
              const SizedBox(
                height: 15.0,
              ),
              Text(
                _issueTitle,
                style: TStyle.btnTextWht17,
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                children: [
                  Image.asset(
                    'images/rassibs_pk_icon_clk.png',
                    height: 14,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(TStyle.getDateFormat(_issueDate),
                    style: const TextStyle(
                      //작은 그레이 텍스트
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15.0,
              ),
              // Text('$_issueCont', style: TStyle.commonSTitle,),
              Html(
                data: _issueCont,
                style: {
                  "body": Style(
                    fontSize: FontSize(15.0),
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    lineHeight: LineHeight.percent(125),
                  ),
                  "a": Style(
                    color: RColor.kakao,
                  ),
                },
                onLinkTap: (url, attributes, element) {
                  commonLaunchURL(url!);
                },
              ),
              const SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),

        //주요 관련주
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            _setSubTitle(
              "주요 관련주",
            ),
            Text(
              '(총 ${_stkList.length}종목)',
              style: TStyle.textSGrey,
            ),
          ],
        ),
        const SizedBox(
          height: 5.0,
        ),

        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _stkList.length ~/ (10 * _stkListPageNum) > 0
              ? 10 * _stkListPageNum
              : _stkList.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return TileStockStatus(_stkList[index]);
          },
        ),

        const SizedBox(
          height: 10.0,
        ),
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
        const SizedBox(
          height: 5.0,
        ),

        /*  GridView.count(
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          childAspectRatio: 2,
          children: List.generate(_stkList.length, (index) =>
              TileStockStatus(_stkList[index]),
          ),
        ),*/

        _setSubTitle(
          '이슈 관련 히스토리',
        ),
        const SizedBox(
          height: 5.0,
        ),
      ],
    );
  }

  //이슈 관련 히스토리
  Widget _setIssueItem(Issue05 item) {
    return InkWell(
      highlightColor: Colors.transparent,
      child: Container(
        decoration: UIStyle.boxRoundLine6(),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TStyle.getDateSFormat(item.issueDttm),
              style: const TextStyle(
                //메인 컬러 작은.
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: RColor.mainColor,
              ),
            ),
            Text(
              item.title,
              style: TStyle.textGrey15,
            ),
            const SizedBox(
              height: 2,
            ),
          ],
        ),
      ),
      onTap: () {
        _showDialogIssue(item.title, item.content);
      },
    );
  }

  //더보기 버튼
  Widget _setMoreButton(String title, String subText) {
    return Visibility(
      visible: true,
      child: Column(
        children: [
          MaterialButton(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              width: 170,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      //작은 밝은 그린 (마켓뷰 ~시간전)
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xff58ceb6),
                    ),
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    subText,
                    style: TStyle.commonSTitle,
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

  //히스토리 데이터
  void _requestData() {
    pageNum = pageNum + 1;
    _fetchPosts(
        TR.ISSUE05,
        jsonEncode(<String, String>{
          'userId': _userId,
          'issueSn': _issueSn,
          'pageNo': pageNum.toString(),
          'pageItemSize': '10',
        }));
  }

  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 5),
      child: Text(
        subTitle,
        style: TStyle.defaultTitle,
      ),
    );
  }

  void _showDialogIssue(
    String iTitle,
    String iContent,
  ) {
    showDialog(
        context: context,
        barrierDismissible: true,
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
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              //height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    iTitle,
                    style: TStyle.defaultTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                  const SizedBox(
                    height: 25.0,
                  ),
                  Container(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Html(
                          data: iContent,
                          style: {
                            "body": Style(
                              fontSize: FontSize(15.0),
                            )
                          },
                          onLinkTap: (url, attributes, element) {
                            commonLaunchURL(url!);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
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
                  const SizedBox(
                    height: 5.0,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 10, right: 10),
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
  void _fetchPosts(String trStr, String json) async {
    DLog.d(IssueViewer.TAG, '$trStr $json');

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
      DLog.d(IssueViewer.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(IssueViewer.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(IssueViewer.TAG, response.body);

    if (trStr == TR.ISSUE04) {
      final TrIssue04 resData = TrIssue04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Issue04? item = resData.retData;
        if(item != null) {
          DLog.d(IssueViewer.TAG, item.issueInfo.toString());
          keyword = item.issueInfo!.keyword;
          _issueTitle = item.issueInfo!.title;
          _issueDate = item.issueInfo!.issueDttm;
          _issueCont = item.issueInfo!.content;
          _stkList = item.stkList;
          setState(() {});
        }
      }

      _fetchPosts(
          TR.ISSUE05,
          jsonEncode(<String, String>{
            'userId': _userId,
            'issueSn': _issueSn,
            'pageNo': pageNum.toString(),
            'pageItemSize': '10',
          }));
    } else if (trStr == TR.ISSUE05) {
      final TrIssue05 resData = TrIssue05.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (_issueList != null) {
          _issueList.addAll(resData.listData as Iterable<Issue05>);

          setState(() {});
        }
      }
    }
  }

  void cheangeIssue(vNewsSn) {
    setState(() {
      stkName = '';
      stkCode = '';
      newsSn = vNewsSn;
      _issueSn = '';
    });

    _fetchPosts(
        TR.ISSUE04,
        jsonEncode(<String, String>{
          'userId': _userId,
          'newsSn': newsSn,
        }));
  }
}
