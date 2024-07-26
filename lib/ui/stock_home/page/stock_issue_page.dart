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
import 'package:rassi_assist/models/tr_issue/tr_issue06.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_stock_info_provider.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/market/issue_new_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/net.dart';
import '../../../models/pg_data.dart';
import '../../main/base_page.dart';
import '../../news/issue_viewer.dart';

/// 2023.01.22 - JS
/// 종목홈_이슈상세 페이지
class StockIssuePage extends StatefulWidget {
  static const String TAG_NAME = '종목홈_이슈상세';
  final String stockCode;
  final String stockName;

  const StockIssuePage({this.stockCode='', this.stockName='', Key? key})
      : super(key: key);

  @override
  State<StockIssuePage> createState() => _StockIssuePageState();
}

class _StockIssuePageState extends State<StockIssuePage> {
  late SharedPreferences _prefs;
  String _userId = "";
  final List<Issue06> _issueList = [];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      StockIssuePage.TAG_NAME,
    );
    _loadPrefData().then((_) => {
          if (_userId != '')
            {
              requestTrAll(),
            },
          Provider.of<StockInfoProvider>(context, listen: false)
              .postRequest(widget.stockCode),
        });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppbar.basic(
        buildContext: context,
        title:  widget.stockName.length > 8
            ? '${widget.stockName.substring(0, 8)} 종목이슈'
            : '${widget.stockName} 종목이슈',
        elevation: 1,
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
                if (_issueList.isEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 20.0, left: 20, right: 20,),
                    child: CommonView.setNoDataView(
                      150,
                      '해당 종목의 이슈가 없습니다.',
                    ),
                  )
                else
                  _setStockIssueList(),
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
                  topLeft: Radius.circular(6.0),
                  topRight: Radius.circular(6.0),
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
                    topLeft: Radius.circular(6.0),
                    topRight: Radius.circular(6.0),
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
                          TStyle.getDateSlashFormat2(item.issueDttm),
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
                            const BorderRadius.all(Radius.circular(20.0)),
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
                  children: List.generate(
                    item.stkList.length,
                    (index) {
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
          Navigator.pushNamed(
            context,
            IssueNewViewer.routeName,
            arguments: PgData(
              pgSn: item.newsSn,
              pgData: item.issueSn,
              data: item.keyword,
            ),
          );
        },
      ),
    );
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  requestTrAll() async {
    _fetchPosts(
      TR.ISSUE06,
      jsonEncode(<String, String>{
        'userId': _userId,
        'stockCode': widget.stockCode,
        'selectCount': '10',
        'includeData': 'Y',
      }),
    );
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

      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    if (trStr == TR.ISSUE06) {
      final TrIssue06 resData = TrIssue06.fromJson(jsonDecode(response.body));
      _issueList.clear();
      if (resData.retCode == RT.SUCCESS) {
        _issueList.addAll(resData.listData);
      }
      setState(() {});
    }
  }
}
