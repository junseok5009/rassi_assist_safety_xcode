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
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/tr_catch02.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/news/catch_list_page.dart';

/// 2020.11.19
/// 캐치 상세 페이지
class CatchViewer extends StatelessWidget {
  static const routeName = '/page_catch_viewer';
  static const String TAG = "[CatchViewer]";
  static const String TAG_NAME = '매매비서_캐치_상세보기';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: RColor.deepStat,
        elevation: 0,
      ),
      body: CatchDetailWidget(),
    );
  }
}

class CatchDetailWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CatchDetailState();
}

class CatchDetailState extends State<CatchDetailWidget> {
  var appGlobal = AppGlobal();

  late PgData args;
  String _userId = '';
  String _catchSn = '';
  String _dateTime = '';
  String _catchTitle = '';
  String _catchCont = '';
  List<Stock> _stkList = [];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(CatchViewer.TAG_NAME);
    _userId = appGlobal.userId;

    Future.delayed(const Duration(milliseconds: 300), () {
      DLog.d(CatchViewer.TAG, "delayed user id : $_userId");
      args = ModalRoute.of(context)!.settings.arguments as PgData;
      _catchSn = args.pgSn;

      if (_userId != '') {
        _fetchPosts(
            TR.CATCH02,
            jsonEncode(<String, String>{
              'userId': _userId,
              'catchSn': _catchSn,
            }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(Const.TEXT_SCALE_FACTOR),
      ),
      child: _setLayout(),
    );
  }

  Widget _setLayout() {
    return Scaffold(
      appBar: AppBar(
        // toolbarHeight: 20,
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: RColor.bgBlueCatch,
        shadowColor: Colors.white,
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
            Container(
              padding: const EdgeInsets.all(5.0),
              color: RColor.bgBlueCatch,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_catchTitle',
                          style: TStyle.btnTextWht17,
                        ),
                        const SizedBox(
                          height: 7.0,
                        ),
                        Text(
                          '$_dateTime',
                          style: TStyle.btnSTextWht,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                      ],
                    ),
                  ),
                  Html(
                    data: _catchCont,
                    style: {
                      "html": Style(
                        color: Colors.white,
                        fontSize: FontSize(15.0),
                      ),
                    },
                    onLinkTap: (url, attributes, element) {
                      commonLaunchURL(url!);
                    },
                  ),
                ],
              ),
            ),
            _setSubTitle(
              "토픽 종목",
            ),
            const SizedBox(
              height: 5.0,
            ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              childAspectRatio: 2,
              children: List.generate(
                  _stkList.length, (index) => TileStockCatch(_stkList[index])),
            ),
            const SizedBox(
              height: 15.0,
            ),
            CommonView.setBasicMoreRoundBtnView([
              Text(
                "+ 다른 내용",
                style: TStyle.puplePlainStyle(),
              ),
              const Text(
                " 더보기",
                style: TStyle.commonSTitle,
              ),
            ], () {
              goPocketBoard();
            }),
            const SizedBox(
              height: 25.0,
            ),
          ],
        ),
      ),
    );
  }

  void goPocketBoard() {
    Navigator.of(context).pushReplacementNamed(
      CatchListPage.routeName,
    );
  }

  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Text(
        subTitle,
        style: TStyle.commonTitle,
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
    DLog.d(CatchViewer.TAG, '$trStr $json');

    try {
      var url = Uri.parse(Net.TR_BASE + trStr);
      final http.Response response = await http
          .post(
            url,
            body: json,
            headers: Net.headers,
          )
          .timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      DLog.d(CatchViewer.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(CatchViewer.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(CatchViewer.TAG, response.body);

    if (trStr == TR.CATCH02) {
      final TrCatch02 resData = TrCatch02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Catch02? item = resData.retData;
        if(item != null) {
          _dateTime = item.issueTmTx;
          _catchTitle = item.title;
          _catchCont = item.content;
          _stkList = item.listStock;
          setState(() {});
        }
      }
    }
  }
}
