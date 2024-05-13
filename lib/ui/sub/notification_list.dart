import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_push_list02.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2021.02.17
/// 알림 항목별 리스트
class NotiListPage extends StatefulWidget {
  const NotiListPage({super.key});

  @override
  State<StatefulWidget> createState() => NotiListPageState();
  static const routeName = '/page_noti_list';
  static const String TAG = "[NotiListPage]";
}

class NotiListPageState extends State<NotiListPage> {
  String tagName = '알림_';
  late SharedPreferences _prefs;
  String _userId = "";
  String _divType = '';
  String _divTitle = '';
  String _div2Type = '';
  final List<PushInfoDv> _dataList = [];
  late ScrollController _scrollController;
  int _pageNum = 0;
  String deviceModel = '';
  bool _isFirstNodata = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _loadPrefData().then((_) {
      Future.delayed(Duration.zero, () async {
        var arguments = ModalRoute.of(context)?.settings.arguments;
        if (arguments == null || arguments is! PgData) {
          Navigator.pop(context);
        }
        PgData pgData = arguments as PgData;
        _divType = pgData.pgData;
        _setPage().then((value) => setState(() {
              _requestData();
            }));
      });
    });
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  //리스트뷰 하단 리스너
  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      //리스트뷰 하단 도착 / 새로운 데이터 요청
      _pageNum = _pageNum + 1;
      _requestData();
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.white,
          leading: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios_sharp,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _divTitle,
                      style: TStyle.commonTitle,
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: Colors.grey,
                      size: 28,
                    ),
                  ],
                ),
                onTap: () {
                  _showScrollableSheet();
                },
              ),
            ],
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 1,
          centerTitle: true,
          leadingWidth: 40,
          titleSpacing: 5.0,
        ),
      ),
      body: SafeArea(
        child: _isFirstNodata
            ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: CommonView.setNoDataView(150, '$_divTitle 알림 내역이 없습니다.'),
              )
            : ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                itemCount: _dataList.length,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                itemBuilder: (context, index) {
                  return TilePushListDv(_dataList[index]);
                },
              ),
      ),
    );
  }

  Future<void> _setPage() async {
    switch (_divType) {
      case 'TS':
      case 'RN':
      case 'SN':
      case 'SB':
        tagName = '알림_내종목알림';
        break;
      case 'SC_BIG':
      case 'SC_TOP':
      case 'BS':
        tagName = '알림_종목캐치';
        break;
      case 'NT':
      case 'CB':
      case 'IS':
        tagName = '알림_소식';
        break;
    }
    await CustomFirebaseClass.logEvtScreenView(tagName);
    if (_divType == 'TS') {
      _divTitle = 'AI매매신호';
    } else if (_divType == 'RN') {
      _divTitle = 'AI속보';
    } else if (_divType == 'SN') {
      _divTitle = '소셜지수';
    } else if (_divType == 'SB') {
      _divTitle = '종목소식';
    } else if (_divType == 'NT') {
      _divTitle = '라씨소식';
    } else if (_divType == 'BS') {
      _divTitle = '신규 매수';
    } else if (_divType == 'CB') {
      _divTitle = '캐치브리핑(매도성과, 인기종목)';
    } else if (_divType == 'IS') {
      _divTitle = '이슈&이슈';
    } else if (_divType == 'SC') {
      _divTitle = '새로추가';
    } else if (_divType == 'SC_BIG') {
      _divTitle = '큰손들의 종목캐치';
    } else if (_divType == 'SC_THEME') {
      _divTitle = '테마캐치';
    } else if (_divType == 'SC_TOP') {
      _divTitle = '성과 TOP 종목캐치';
    }
  }

  _showScrollableSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.8,
          maxChildSize: 0.8,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '알림 항목',
                        style: TStyle.title18T,
                      ),
                      InkWell(
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    height: 2,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    '나의 종목 알림',
                    style: TStyle.defaultTitle,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  _setSheetMenu(context, '라씨 매매비서의 AI매매신호', 'TS'),
                  const SizedBox(
                    height: 10.0,
                  ),
                  _setSheetMenu(context, 'AI속보', 'RN'),
                  const SizedBox(
                    height: 10.0,
                  ),
                  _setSheetMenu(context, '소셜지수', 'SN'),
                  const SizedBox(
                    height: 10.0,
                  ),
                  _setSheetMenu(context, '종목소식', 'SB'),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    '종목 캐치 알림',
                    style: TStyle.defaultTitle,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  _setSheetMenu(context, '큰손들의 종목 캐치', 'SC_BIG'),
                  const SizedBox(
                    height: 10.0,
                  ),
                  _setSheetMenu(context, '성과 TOP 종목 캐치', 'SC_TOP'),
                  const SizedBox(
                    height: 10.0,
                  ),
                  _setSheetMenu(context, '신규 매수 종목 캐치', 'BS'),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    '라씨 소식 알림',
                    style: TStyle.defaultTitle,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  _setSheetMenu(context, '라씨 브리핑(인기종목)', 'CB'),
                  const SizedBox(
                    height: 10.0,
                  ),
                  _setSheetMenu(context, '오늘의 이슈', 'IS'),
                  const SizedBox(
                    height: 10.0,
                  ),
                  _setSheetMenu(context, '이벤트 및 라씨 소식', 'NT'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _setSheetMenu(BuildContext context, String menu, String toDiv) {
    return InkWell(
      child: Text(
        '    $menu',
        style: TStyle.defaultContent,
      ),
      onTap: () {
        _divType = toDiv;
        _setPage().then((value) => {
              _pageNum = 0,
              _dataList.clear(),
              _div2Type = '',
              setState(() {
                _requestData();
              }),
              Navigator.of(context).pop(),
            });
      },
    );
  }

  void _requestData() {
    //TODO Test 아이패드 경우에는 10개 이상의 리스트는 볼 수 없는지 테스트
    if (_divType == 'SC_BIG') {
      _divType = 'SC';
      _div2Type = 'BIGHAND';
    } else if (_divType == 'SC_TOP') {
      _divType = 'SC';
      _div2Type = 'SCORETOP';
    } else if (_divType == 'SC_THEME') {
      _divType = 'SC';
      _div2Type = 'THEME';
    }
    _fetchPosts(
        TR.PUSH_LIST02,
        jsonEncode(<String, String>{
          'userId': _userId,
          'isPush': 'Y',
          'pushDiv1': _divType,
          'pushDiv2': _div2Type,
          'prodCode': '',
          'pageNo': _pageNum.toString(),
          'pushItemSize': '20',
        }));
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(NotiListPage.TAG, '$trStr $json');

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
      if (mounted) CommonPopup.instance.showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(NotiListPage.TAG, response.body);

    if (trStr == TR.PUSH_LIST02) {
      final TrPushList02 resData = TrPushList02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _dataList.addAll(resData.retData?.pushList as Iterable<PushInfoDv>);
      }
      if (_dataList.isEmpty && _pageNum == 0) {
        _isFirstNodata = true;
      } else {
        _isFirstNodata = false;
      }
      setState(() {});
    }
  }
}
