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
import 'package:rassi_assist/models/none_tr/stock/stock_data.dart';
import 'package:rassi_assist/models/opinion.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/tag_info.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi03.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/news/news_tag_page.dart';
import 'package:rassi_assist/ui/stock_home/stock_home_tab.dart';
import 'package:rassi_assist/ui/tiles/tile_stock.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2020.11.19 - JY
/// 뉴스 상세 페이지 (BottomSheet 뷰 테스트 하는 동안 임시로 사용)
class NewsViewer extends StatefulWidget {
  static const routeName = '/page_news_detail';
  static const String TAG = "[NewsViewer]";
  static const String TAG_NAME = '라씨로속보_상세_보기';

  const NewsViewer({super.key});

  @override
  State<StatefulWidget> createState() => NewsViewerState();
}

class NewsViewerState extends State<NewsViewer> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgNews args;

  String stkName = "";
  String stkCode = "";
  String reportDiv = "";
  String title = "";
  String nDate = "";
  Color statColor = Colors.grey;

  double webHeight = 0.0;
  String _strHtml = '';
  String _strDoc = '';

  List<Tag> _tagList = [];
  List<StockData> _stkList = [];
  final List<Opinion> _opnList = [];
  bool _bRelatedTag = false;
  bool _bRelatedStock = false;
  bool _bReportRelatedStock = false;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      NewsViewer.TAG_NAME,
    );
    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      DLog.d(NewsViewer.TAG, "delayed user id : $_userId");

      if (_userId != '') {
        String param = '';
        if (reportDiv == '0') {
          param = jsonEncode(<String, String>{
            'userId': _userId,
            'stockCode': stkCode,
            'newsSn': args.newsSn,
            'reportDiv': '0',
          });
        } else {
          param = jsonEncode(<String, String>{
            'userId': _userId,
            'stockCode': stkCode,
            'newsCrtDate': args.createDate,
            'newsSn': args.newsSn,
          });
        }
        _fetchPosts(TR.RASSI03, param);
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
    args = ModalRoute.of(context)!.settings.arguments as PgNews;
    stkName = args.stockName;
    stkCode = args.stockCode;
    reportDiv = args.reportDiv;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(Const.TEXT_SCALE_FACTOR),
      ),
      child: _setLayout(),
    );
  }

  Widget _setLayout() {
    return Scaffold(
      backgroundColor: RColor.bgBasic_fdfdfd,
      appBar: CommonAppbar.simpleNoTitleWithExit(
        context,
        Colors.white,
        Colors.black,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            _setTitleDate(),

            Container(
              decoration: UIStyle.boxRoundLine17(),
              padding: const EdgeInsets.all(5.0),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Html(
                    data: _strDoc,
                    style: {
                      "html": Style(
                        fontSize: FontSize(15.0),
                      ),
                      "div": Style(
                        width: Width.auto(),
                      ),
                    },
                    onLinkTap: (url, attributes, element) {
                      commonLaunchURL(url!);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),
            _setRelatedTag(),
            const SizedBox(height: 15),
            _setRelatedStock(),
            //증권사 레포트 관련 종목 추가 // 22.07.13
            const SizedBox(height: 15),
            _setReportRelatedStock(),
          ],
        ),
      ),
    );
  }

  Widget _setTitleDate() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          Text(
            title,
            style: TStyle.title18,
          ),
          const SizedBox(height: 7),
          Text(
            TStyle.getDateFormat(nDate),
            style: TStyle.subTitle,
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
      alignment: Alignment.centerLeft,
      child: Text(
        subTitle,
        style: TStyle.commonTitle,
      ),
    );
  }

  //관련태그
  Widget _setRelatedTag() {
    return Visibility(
      visible: _bRelatedTag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _setSubTitle(
            "관련 태그",
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Wrap(
              spacing: 5.0,
              alignment: WrapAlignment.start,
              children: List.generate(
                _tagList.length,
                (index) {
                  var item = _tagList[index];
                  return InkWell(
                    child: Text(
                      '#${item.tagName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: RColor.mainColor,
                      ),
                    ),
                    onTap: () {
                      if (NewsTagPage.globalKey.currentState == null) {
                        basePageState.callPageRouteNews(
                          NewsTagPage(),
                          PgNews(tagCode: item.tagCode, tagName: item.tagName),
                        );
                      } else {
                        Navigator.pop(context, item);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  //관련종목
  Widget _setRelatedStock() {
    return Visibility(
      visible: _bRelatedStock,
      child: Column(
        children: [
          _setSubTitle(
            "관련 종목",
          ),
          const SizedBox(
            height: 5.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SizedBox(
              width: double.infinity,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _stkList.length,
                itemBuilder: (context, index) {
                  return TileStock(_stkList[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 증권사 레포트 관련종목
  Widget _setReportRelatedStock() {
    return Visibility(
      visible: _bReportRelatedStock,
      child: Column(
        children: [
          _setSubTitle(
            "관련 종목",
          ),
          Container(
            decoration: UIStyle.boxRoundLine10c(RColor.lineGrey),
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(15),
            child: InkWell(
              onTap: () {
                basePageState.goStockHomePage(
                  stkCode,
                  stkName,
                  Const.STK_INDEX_HOME,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        stkName,
                        style: TStyle.title18T,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        stkCode,
                        style: TStyle.textSGrey,
                      ),
                    ],
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 7),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: _opnList.length,
                        itemBuilder: (BuildContext context, int index) {
                          Opinion item = _opnList[index];
                          return Text(
                            '${TStyle.getDateDivFormat(item.issueDate)} '
                            '${TStyle.getMoneyPoint(item.goalValue)} '
                            '${item.opinion} ${item.orgName}',
                            style: TStyle.content12,
                          );
                        },
                      )),
                ],
              ),
            ),
          )
        ],
      ),
    );
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
    DLog.d(NewsViewer.TAG, '$trStr $json');

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
      DLog.d(NewsViewer.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(NewsViewer.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(NewsViewer.TAG, response.body);

    if (trStr == TR.RASSI03) {
      final TrRassi03 resData = TrRassi03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        DLog.d(NewsViewer.TAG, resData.retData.title);
        _strHtml = resData.retData.content;
        title = resData.retData.title;
        nDate = resData.retData.issueDttm;

        if (resData.retData.listTag != null) {
          _tagList = resData.retData.listTag;
          _bRelatedTag = true;
        }
        if (resData.retData.listStock != null) {
          _stkList = resData.retData.listStock;
          _bRelatedStock = true;
        }
        if (reportDiv == '0' && resData.retData.listOpinion != null) {
          _opnList.addAll(resData.retData.listOpinion);
          _bReportRelatedStock = true;
        }

        if (_strHtml.contains('width:100%')) {
          _strHtml = _strHtml.replaceAll('width:100%', 'max-width:100%');
        }

        setState(() {
          _strDoc = '''<!DOCTYPE html>
            <html>
              <head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
              <body>
                <div>
                  $_strHtml
                </div>
              </body>
            </html>''';
        });
      }
    }
  }
}
