import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/models/tr_disclos02.dart';
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
  late InAppWebViewController _controller;

  double webHeight = 0.0;
  String _strHtml = '';

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

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  _initRequestTr() {
    Future.delayed(Duration.zero, () {
      args = ModalRoute.of(context)!.settings.arguments as PgData;
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.black,
              onPressed: () => Navigator.of(context).pop(null),
            ),
            const SizedBox(
              width: 10.0,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                _setTitleDate(),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _loadHTML() async {
    _controller.loadData(
      mimeType: 'text/html',
      encoding: 'utf-8',
      data: '''
    $_strHtml
    ''',
    );
    setState(() {});
  }

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
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup().showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    //DLog.w(response.body);

    if (trStr == TR.DISCLOS02) {
      final TrDisclos02 resData = TrDisclos02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        final data = resData.retData;
        if(data != null) {
          _strHtml = data.content;
          title = data.title;
          _issueDate = data.issueDate;
        }
        /*if (_strHtml.contains('width:100%')) {
          _strHtml = _strHtml.replaceAll('width:100%', 'max-width:100%');
        }*/
        if (_strHtml.contains('\u003c')) {
          _strHtml = _strHtml.replaceAll('\u003c', '<');
        }
        if (_strHtml.contains('\u003e')) {
          _strHtml = _strHtml.replaceAll('\u003e', '>');
        }
        if (_strHtml.contains('\$')) {
          _strHtml = _strHtml.replaceAll('\u003e', '>');
        }
        if (_strHtml.contains('\$')) {
          _strHtml = _strHtml.replaceAll('\u003e', '>');
        }

        /*_strHtml = _strHtml.replaceAll('WIDTH:600px', 'width:100%');
        _strHtml = _strHtml.replaceAll('width:600px', 'width:100%');
        _strHtml = _strHtml.replaceAll('width:592px', 'width:100%');
        _strHtml = _strHtml.replaceAll('width:338px', 'width:100%');

        _strHtml = _strHtml.replaceAll('width="602"', 'width=100%');
        _strHtml = _strHtml.replaceAll('width="165"', 'width=100%');
        _strHtml = _strHtml.replaceAll('width="173"', 'width=100%');
        _strHtml = _strHtml.replaceAll('width="264"', 'width=100%');
        _strHtml = _strHtml.replaceAll('width="338"', 'width=100%');
        _strHtml = _strHtml.replaceAll('width="729"', 'width=100%');*/

        DLog.w(_strHtml);
        setState(() {
          /*_strDoc = '''
          $_strHtml
          ''';*/
          _loadHTML();
        });
      }
    }
  }
}
