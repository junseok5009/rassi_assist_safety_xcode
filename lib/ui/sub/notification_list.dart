import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_push_list02.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 2021.02.17
/// 알림 항목별 리스트
class NotiListPage extends StatelessWidget {
  static const routeName = '/page_notification_list';
  static const String TAG = "[NotiListPage]";
  static String TAG_NAME = '알림_';

  @override
  Widget build(BuildContext context) {
    PgData args = ModalRoute.of(context)?.settings.arguments as PgData;

    if (args.pgData != null) {
      switch (args.pgData) {
        case 'TS':
        case 'RN':
        case 'SN':
        case 'SB':
          TAG_NAME = '알림_내종목알림';
          break;
        case 'SC_BIG':
        case 'SC_TOP':
        case 'BS':
          TAG_NAME = '알림_종목캐치';
          break;
        case 'NT':
        case 'CB':
        case 'IS':
          TAG_NAME = '알림_소식';
          break;
      }
    }

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(Const.TEXT_SCALE_FACTOR),
      ),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: RColor.deepStat,
          elevation: 0,
        ),
        body: NotiListWidget(),
      ),
    );
  }
}

class NotiListWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NotiListState();
}

class NotiListState extends State<NotiListWidget> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  bool _bInit = false;
  String _divType = '';
  String _divTitle = '';
  String _div2Type = '';
  final List<PushInfoDv> _dataList = [];
  late ScrollController _scrollController;
  int _pageNum = 0;
  String deviceModel = '';

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(NotiListPage.TAG_NAME);

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      args = ModalRoute.of(context)!.settings.arguments as PgData;
      if (args != null && !_bInit) _divType = args.pgData;

      _bInit = true; //초기화 완료
      _setDivTitle();

      if (_userId != '') {
        _requestData(true);
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
  void dispose() {
    _bYetDispose = false;
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
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      //리스트뷰 하단 도착 / 새로운 데이터 요청
      _pageNum = _pageNum + 1;
      _requestData(false);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _setAppBar(),
      body: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        itemCount: _dataList.length,
        itemBuilder: (context, index) {
          return TilePushListDv(_dataList[index]);
        },
      ),
    );
  }

  PreferredSizeWidget _setAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        height: 50,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: RColor.lineGrey, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              iconSize: 20,
              onPressed: () => Navigator.of(context).pop(null),
            ),
            InkWell(
              child: Row(
                children: [
                  Text(
                    _divTitle,
                    style: TStyle.title17,
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: Colors.grey,
                    size: 35,
                  ),
                ],
              ),
              onTap: () {
                _showScrollableSheet();
              },
            ),
            const SizedBox(
              width: 15,
            )
          ],
        ),
      ),
    );
  }

  //항목별 타이틀 설정
  void _setDivTitle() {
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

  Widget? _showScrollableSheet() {
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
              padding: const EdgeInsets.all(10),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '알림 항목',
                        style: TStyle.title17,
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
                    height: 1,
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
        style: TStyle.content15,
        
      ),
      onTap: () {
        setState(() {
          _divType = toDiv;
          switch (_divType) {
            case 'TS':
            case 'RN':
            case 'SN':
            case 'SB':
              NotiListPage.TAG_NAME = '알림_내종목알림';
              break;
            case 'SC_BIG':
            case 'SC_TOP':
            case 'BS':
              NotiListPage.TAG_NAME = '알림_종목캐치';
              break;
            case 'NT':
            case 'CB':
            case 'IS':
              NotiListPage.TAG_NAME = '알림_소식';
              break;
          }
          CustomFirebaseClass.logEvtScreenView(NotiListPage.TAG_NAME);
        });
        _setDivTitle();
        _requestData(true);
        Navigator.of(context).pop(null);
      },
    );
  }

  void _requestData(bool init) {
    //TODO Test 아이패드 경우에는 10개 이상의 리스트는 볼 수 없는지 테스트
    if (init) {
      _pageNum = 0;
      _dataList.clear();
      _div2Type = '';
    }

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

      if (_bYetDispose) _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      DLog.d(NotiListPage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(NotiListPage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(NotiListPage.TAG, response.body);

    if (trStr == TR.PUSH_LIST02) {
      final TrPushList02 resData =
          TrPushList02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _dataList.addAll(resData.retData?.pushList as Iterable<PushInfoDv>);
        setState(() {});
      } else if (resData.retCode == RT.NO_DATA) {}
    }
  }
}
