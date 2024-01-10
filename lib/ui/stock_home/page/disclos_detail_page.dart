import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cross_scroll/cross_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/tr_disclos02.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/pg_data.dart';

/// 2023.02.10
/// 공시 리스트 상세 페이지
class DisclosDetailPage extends StatefulWidget {
  static const String TAG_NAME = '공시_상세';

  const DisclosDetailPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DisclosDetailPageState();
}

class _DisclosDetailPageState extends State<DisclosDetailPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;
  String title = "";
  String _issueDate = "";
  Color statColor = Colors.grey;
  //InAppWebViewController _controller;
  double webHeight = 0.0;
  String _strHtml = '';
  double _moreWidth = 0;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      DisclosDetailPage.TAG_NAME,
    );
    _loadPrefData().then((value) => {
          _initRequestTr(),
        });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  _initRequestTr() {
    Future.delayed(Duration.zero, () {
      PgData args = ModalRoute.of(context)!.settings.arguments as PgData;
      DLog.e('newsSn : ${args.pgData} / stockCode : ${args.stockCode}');
      _fetchPosts(
        TR.DISCLOS02,
        jsonEncode(
          <String, String>{
            'userId': _userId,
            'stockCode': args.stockCode,
            'newsSn': args.pgData,
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: CommonAppbar.simpleNoTitleWithExit(
          context,
          Colors.white,
          Colors.black,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _setTitleDate(),
                const SizedBox(
                  height: 10,
                ),
                /* Expanded(
                  child: Container(
                    decoration: UIStyle.boxRoundLine17(),
                    padding: const EdgeInsets.all(5.0),
                    //margin: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: double.infinity,
                      //height: 100,
                      child: InAppWebView(
                        initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions(
                            supportZoom: true,
                            javaScriptEnabled: true,
                            disableHorizontalScroll: false,
                            disableVerticalScroll: false,
                          ),
                        ),
                        onWebViewCreated: (controller) {
                          _controller = controller;
                          _loadHTML();
                        },
                      ),
                    ),
                  ),
                ),*/
                /*Container(
                  decoration: UIStyle.boxRoundLine17(),
                  padding: const EdgeInsets.all(5.0),
                  //margin: const EdgeInsets.all(10.0),
                  width: double.infinity,
                  height: 200,
                  child: InAppWebView(
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        supportZoom: true,
                        javaScriptEnabled: true,
                        disableHorizontalScroll: false,
                        disableVerticalScroll: false,
                      ),
                    ),
                    onWebViewCreated: (controller) {
                      _controller = controller;
                      _loadHTML();
                    },
                  ),
                ),*/
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: RColor.lineGrey,
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    padding: const EdgeInsets.all(5.0),
                    child: CrossScroll(
                      horizontalBar: const CrossScrollBar(
                        thickness: 2,
                      ),
                      verticalBar: const CrossScrollBar(
                        thickness: 2,
                      ),
                      child: SizedBox(
                        width:
                            _moreWidth > MediaQuery.of(context).size.width - 42
                                ? _moreWidth + 10
                                : MediaQuery.of(context).size.width - 42,
                        child: Html(
                          data: _strHtml,
                          shrinkWrap: true,
                          style: {
                            "html": Style(
                              fontSize: FontSize(14.0),
                              width: Width.auto(),
                              height: Height.auto(),
                            ),
                            "body": Style(
                              fontSize: FontSize(14.0),
                              width: Width.auto(),
                              height: Height.auto(),
                            ),
                            "div": Style(
                              fontSize: FontSize(14.0),
                              width: Width.auto(),
                              height: Height.auto(),
                            ),
                            "span": Style(
                              fontSize: FontSize(14.0),
                              width: Width.auto(),
                              height: Height.auto(),
                            ),
                            "table": Style(
                              fontSize: FontSize(14.0),
                              //width: Width.auto(),
                              height: Height.auto(),
                            ),
                            "colgroup": Style(
                              fontSize: FontSize(14.0),
                              width: Width.auto(),
                              height: Height.auto(),
                            ),
                            "col": Style(
                              fontSize: FontSize(14.0),
                              width: Width.auto(),
                              height: Height.auto(),
                            ),
                            "nb": Style(
                              fontSize: FontSize(14.0),
                              width: Width.auto(),
                              height: Height.auto(),
                            ),
                            "tbody": Style(
                              fontSize: FontSize(14.0),
                              //width: Width.auto(),
                              height: Height.auto(),
                            ),
                            "tr": Style(
                                //width: Width.auto(),
                                height: Height.auto(),
                                ),
                            "th": Style(
                              //width: Width.auto(),
                              height: Height.auto(),
                              border: const Border(
                                left:
                                    BorderSide(color: Colors.black, width: 0.5),
                                bottom:
                                    BorderSide(color: Colors.black, width: 0.5),
                                top:
                                    BorderSide(color: Colors.black, width: 0.5),
                              ),
                            ),
                            "TH": Style(
                              //width: Width.auto(),
                              height: Height.auto(),
                              border: const Border(
                                left:
                                    BorderSide(color: Colors.black, width: 0.5),
                                bottom:
                                    BorderSide(color: Colors.black, width: 0.5),
                                top:
                                    BorderSide(color: Colors.black, width: 0.5),
                              ),
                            ),
                            "td": Style(
                              //width: Width.auto(),
                              height: Height.auto(),
                              border: const Border(
                                left:
                                    BorderSide(color: Colors.black, width: 0.5),
                                bottom:
                                    BorderSide(color: Colors.black, width: 0.5),
                                top:
                                    BorderSide(color: Colors.black, width: 0.5),
                                right:
                                    BorderSide(color: Colors.black, width: 0.5),
                              ),
                            ),
                            "TD": Style(
                              //width: Width.auto(),
                              height: Height.auto(),
                              border: const Border(
                                left:
                                    BorderSide(color: Colors.black, width: 0.5),
                                bottom:
                                    BorderSide(color: Colors.black, width: 0.5),
                                top:
                                    BorderSide(color: Colors.black, width: 0.5),
                                right:
                                    BorderSide(color: Colors.black, width: 0.5),
                              ),
                            ),
                          },
                          extensions: [
                            const TableHtmlExtension(),
                            TagExtension(
                              tagsToExtend: {"p", "pre"},
                              builder: (extensionContext) {
                                return Text(
                                  extensionContext.element!.text,
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ],
                          onLinkTap: (url, attributes, element) {
                            //TODO @@@@@
                            // Platform.isIOS
                            //     ? commonLaunchURL(url)
                            //     : commonLaunchUrlApp(url);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*_loadHTML() async {
    _controller.loadData(
      mimeType: 'text/html',
      encoding: 'utf-8',
      data: '''
    $_strHtml
    ''',
    );
    setState(() {});
  }*/

  Widget _setTitleDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TStyle.title18,
        ),
        const SizedBox(
          height: 7.0,
        ),
        Text(
          TStyle.getDateSFormat(_issueDate),
          style: TStyle.subTitle,
        ),
      ],
    );
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
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
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    //DLog.w(response.body);

    if (trStr == TR.DISCLOS02) {
      final TrDisclos02 resData =
          TrDisclos02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _strHtml = resData.retData!.content;
        if (_strHtml.contains('a:active')) {
          String a = '';
          String b = '';
          a = _strHtml.substring(0, _strHtml.indexOf('a:active'));
          b = _strHtml.substring(
            _strHtml.indexOf('a:active') + 10,
          );
          _strHtml = a + b;
        }
        if (_strHtml.contains('<style') &&
            _strHtml.contains('\u003c/style\u003e')) {
          String c = _strHtml.substring(_strHtml.indexOf('\u003cstyle'),
              _strHtml.indexOf('\u003c/style\u003e'));
          if (_strHtml.contains('WIDTH')) {
            String a1 =
                c.substring(c.indexOf('WIDTH'), c.indexOf('WIDTH') + 10);
            _moreWidth =
                double.tryParse(a1.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            //DLog.e('_moreWidth : $_moreWidth');
          }
        }
        if (_strHtml.contains('<style') &&
            _strHtml.contains('\u003c/style\u003e')) {
          String a = '';
          String b = '';
          a = _strHtml.substring(0, _strHtml.indexOf('\u003cstyle'));
          b = _strHtml.substring(_strHtml.indexOf('\u003c/style\u003e'));
          _strHtml = a + b;
        }

        if (_strHtml.contains('<tr>') && _strHtml.contains('</tr>')) {
          String checkTr = _strHtml;
          while (checkTr.contains('<tr>') && checkTr.contains('</tr>')) {
            int first = checkTr.indexOf('<tr>');
            int last = checkTr.indexOf('</tr>');
            double sumTrWidth = 0;
            //DLog.e('tr ~ /tr : ${checkTr.substring(first, last+5)}');
            String checkTd = checkTr.substring(first, last + 5);
            DLog.e('checkTd : $checkTd');
            while (checkTd.contains('<td') && checkTd.contains('</td>')) {
              int firstTd = checkTd.indexOf('<td');
              int lastTd = checkTd.indexOf('</td>');
              String strTd = checkTd.substring(firstTd, lastTd + 5);
              if (strTd.contains('width=')) {
                //int firstOp = strTd.indexOf('width="');
                //int lastOp = strTd.indexOf('"', firstOp);
                String strOp = strTd.substring(
                    strTd.indexOf('"', strTd.indexOf('width=')),
                    strTd.indexOf('"', strTd.indexOf('width="') + 7));

                int tdWidth =
                    int.tryParse(strOp.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                //DLog.e('strTd : $strTd / strOp : $strOp / tdWidth : $tdWidth');
                sumTrWidth += tdWidth;
              }
              checkTd = checkTd.substring(lastTd + 5);
            }

            DLog.e('sumTrWidth : $sumTrWidth');

            if (sumTrWidth > _moreWidth) {
              _moreWidth = sumTrWidth;
            }
            checkTr = checkTr.substring(last + 5);
          }
        }
        DLog.e('_moreWidth : $_moreWidth / MediaQuery.of(context).size.width - 42 : ${MediaQuery.of(context).size.width - 42}');
        title = resData.retData!.title;
        _issueDate = resData.retData!.issueDate;
        setState(() {});
      }
    }
  }
}
