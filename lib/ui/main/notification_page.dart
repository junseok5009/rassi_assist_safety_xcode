import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/routes.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_push_list01.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/sub/notification_list.dart';
import 'package:rassi_assist/ui/sub/notification_setting_new.dart';
import 'package:rassi_assist/ui/sub/stk_catch_big.dart';
import 'package:rassi_assist/ui/sub/stk_catch_top.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/common_appbar.dart';


/// 2020.10.26
/// 알림내역 => 상단 Collapse bar 없이 다시 시작
class NotificationPage extends StatefulWidget {
  static const routeName = '/page_notification';
  static const String TAG = "[NotificationPage]";
  static const String TAG_NAME = '알림_메인';

  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  var appGlobal = AppGlobal();
  late SharedPreferences _prefs;
  String _userId = '';
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  final List<PushList01> _pushListA = []; // 일시
  final int oneHeight = 170;

  late ScrollController _scrollController;
  String strPreDate = '';
  int pageNum = 0;

  bool isNoData = false;
  bool visibleDiv1 = true; //종목명, 종목코드, Div
  bool visibleDiv2 = true; //타이틀

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(NotificationPage.TAG_NAME);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _loadPrefData().then(
      (value) {
        strPreDate = TStyle.getTodayString();
        if (_userId != '') {
          _fetchPosts(
            TR.PUSH_LIST01,
            jsonEncode(
              <String, String>{
                'userId': _userId,
                'issueDate': strPreDate,
                'pageItemSize': '5',
              },
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bYetDispose = false;
    super.dispose();
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

  //리스트뷰 하단 리스너
  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      //리스트뷰 하단 도착 / 새로운 데이터 요청
      _requestListDate();
    } else {}
  }

  _requestListDate() {
    String endDay = _pushListA[_pushListA.length - 1].issueDate;
    if (endDay != null) {
      _fetchPosts(
          TR.PUSH_LIST01,
          jsonEncode(<String, String>{
            'userId': _userId,
            'issueDate': _getPreDate(endDay),
            'pageItemSize': '5',
          }));
    }
  }

  String _getPreDate(String strLast) {
    DateTime lastDate = DateTime.parse(strLast);
    DateTime pDate = lastDate.subtract(const Duration(days: 1));
    final df = DateFormat('yyyyMMdd');
    return df.format(pDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: CommonAppbar.simpleWithAction(
        '알림',
        [
          //알림필터
          IconButton(
            icon: const ImageIcon(
              AssetImage(
                'images/rassibs_pk_icon_ee.png',
              ),
              color: Colors.black,
              size: 19,
            ),
            onPressed: () {
              _showScrollableSheet();
            },
          ),
          //알림수신 설정
          IconButton(
            icon: const ImageIcon(
              AssetImage(
                'images/main_arlim_icon_mdf.png',
              ),
              color: Colors.black,
              size: 20,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationSettingN()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: _pushListA.length, //_divList.length,
            itemBuilder: (context, index) {
              return _mainListTile(index);
            },
          ),
          Visibility(
            visible: isNoData,
            child: Container(
              margin: const EdgeInsets.only(top: 40.0),
              width: double.infinity,
              alignment: Alignment.topCenter,
              child: const Text('아직 발생한 알림 목록이 없습니다.'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainListTile(int index) {
    var blockWidgets = <Widget>[];
    var blockList =
        _pushListA[index].divList; //리스트에서 하루에 해당하는 데이터가 하나의 인덱스값에 해당
    String dateStr =
        '${TStyle.getDateKorFormat(_pushListA[index].issueDate)} (${_pushListA[index].weekday})';
    blockWidgets.add(
      Container(
        margin: const EdgeInsets.only(left: 10, top: 20),
        child: Text(
          dateStr,
          style: TStyle.titleGrey,
        ),
      ),
    );

    for (int i = 0; i < blockList.length; i++) {
      if (blockList[i].pushList.length == 1) {
        blockWidgets.add(_buildOneItem(blockList[i].pushDiv1,
            blockList[i].pushCount, blockList[i].pushList[0]));
      } else {
        blockWidgets.add(_buildListItem(
            blockList[i].pushDiv1, blockList[i].pushCount, blockList[i]));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blockWidgets,
    );
  }

  // 아이템 한줄
  Widget _buildListItem(String div, String divCnt, PushDiv pList) {
    return SizedBox(
      width: double.infinity,
      height: 210,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getDivTitle(div),
                  style: TStyle.defaultTitle,
                ),
                Text('$divCnt건'),
              ],
            ),
          ),
          SizedBox(
            height: 170,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: pList.pushList.length,
              itemBuilder: (context, subIdx) => _buildItem(
                pList.pushDiv1,
                pList.pushList[subIdx],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 아이템 하나
  Widget _buildItem(String div, PushInfo item) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 8, top: 10, bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      height: 200,
      width: 250,
      decoration: item.pushDiv2 == 'USER'
          ? UIStyle.boxRoundLine6bgColor(RColor.bgSkyBlue)
          : UIStyle.boxRoundLine6bgColor(Colors.white),
      child: _setListItem(div, item),
    );
  }

  // ItemList 하나일 경우
  Widget _buildOneItem(String div, String divCnt, PushInfo item) => SizedBox(
        width: double.infinity,
        height: 210,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getDivTitle(div),
                    style: TStyle.defaultTitle,
                  ),
                  Text('$divCnt건'),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 15,
                right: 15,
                top: 10,
                bottom: 15,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              width: double.infinity,
              height: 145,
              decoration: item.pushDiv2 == 'USER'
                  ? UIStyle.boxRoundLine6bgColor(RColor.bgSkyBlue)
                  : UIStyle.boxRoundLine6bgColor(
                      Colors.white,
                    ),
              child: _setListItem(div, item),
            ),
          ],
        ),
      );

  // 리스트 아이템
  Widget _setListItem(String div, PushInfo item) {
    //종목명/종목코드/분류 visible
    if (div == 'BS' ||
        div == 'CB' ||
        div == 'IS' ||
        div == 'HK' ||
        div == 'CS' ||
        div == 'NT') {
      visibleDiv1 = false;
    } else {
      visibleDiv1 = true;
    }
    //타이틀 visible
    if (div == 'TS' || div == 'SN' || div == 'SB' || div == 'RN') {
      visibleDiv2 = false;
    } else {
      visibleDiv2 = true;
    }

    return InkWell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //종목명, 종목코드
              Visibility(
                visible: visibleDiv1,
                child: _setStockDiv(div, item),
              ),
              //타이틀
              Visibility(
                visible: visibleDiv2,
                child: Text(
                  item.pushTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TStyle.commonSTitle,
                ),
              ),
              const SizedBox(
                height: 4.0,
              ),
              //컨텐츠
              Text(
                item.pushContent,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          //발생일자
          Text(getDateFormat(item.regDttm)),
        ],
      ),
      onTap: () {
        DLog.d(NotificationPage.TAG, '랜딩페이지 이동 $div  ${item.toString()}');
        if (div == 'TS') {
          //나의종목-AI매매신호 -> 포켓SN 있으면 포켓으로 이동, 없으면 종목홈_시그널
          if (item.pushDiv2 == 'USER') {
            // [포켓 > 나만의 신호 탭]
            basePageState.goPocketPage(Const.PKT_INDEX_SIGNAL,);
          } else {
            basePageState.goStockHomePage(
              item.stockCode,
              item.stockName,
              Const.STK_INDEX_SIGNAL,
            );
          }
        }
         else if(div == 'RN' || div == 'SN' || div == 'SB') {
           //나의종목-AI속보 -> 종목홈 AI속보
           //나의종목-소셜지수 -> 종목홈 소셜지수
           //나의종목-종목소식 -> 종목홈 종목소식
          basePageState.goStockHomePage(
            item.stockCode,
            item.stockName,
            Const.STK_INDEX_HOME,
          );
        }
        else if (div == 'IS') {
          //종목캐치-이슈&이슈 -> 마켓뷰로 이동
          basePageState.goLandingPage(LD.market_page, '', '', '', '');
        } else if (div == 'CB') {
          //종목캐치-캐치브리핑 -> AI 매매신호로 이동
          basePageState.goLandingPage(LD.main_signal, '', '', '', '');
        } else if (div == 'BS') {
          //종목캐치-신규매수 -> AI 매매신호로 이동
          basePageState.goLandingPage(LD.main_signal, '', '', '', '');
        } else if (div == 'SC_BIG') {
          //종목캐치-큰손매매 ->
          appGlobal.pageData = 'FRN';
          Navigator.pushNamed(context, StkCatchBigPage.routeName,
              arguments: PgData(pgSn: ''));
        } else if (div == 'SC_TOP') {
          //종목캐치-성과TOP ->
          Navigator.pushNamed(context, StkCatchTopPage.routeName,
              arguments: PgData(pgSn: ''));
        } else if (div == 'SC_THEME') {
          //종목캐치-테마 ->
          // basePageState.goLandingPage(LD.main_signal, '', '', '', '');
        } else if (div == 'NT') {
          //라씨 소식
        }
      },
    );
  }

  //종목명, 종목코드, Div
  Widget _setStockDiv(String div, PushInfo item) {
    String strFlag = '';
    Color colorFlag = Colors.grey;
    if (div == 'TS') {
      if (item.tradeFlag != null) {
        if (item.tradeFlag == 'B') {
          strFlag = '매수\n신호';
          colorFlag = RColor.bgBuy;
        }
        if (item.tradeFlag == 'S') {
          strFlag = '매도\n신호';
          colorFlag = RColor.bgSell;
        }
      }
    }
    // item.
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  '${TStyle.getLimitString(item.stockName, 8)}',
                  style: TStyle.commonSTitle,
                ),
                Text(
                  '${item.stockCode}',
                  style: TStyle.textSGrey,
                ),
              ],
            ),

            //분류 태그 표시
            Stack(
              children: [
                Visibility(
                  visible: (div == 'RN' || div == 'SN' || div == 'SB')
                      ? true
                      : false,
                  child: Chip(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.white),
                    ),
                    label: Text(getTypeString(div)),
                    backgroundColor: getTypeColor(div),
                  ),
                ),

                //매수신호/매도신호
                Visibility(
                  visible: (div == 'TS') ? true : false,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: colorFlag,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Center(
                      child: Text(
                        strFlag,
                        style: TStyle.btnTextWht13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  //분류 메뉴 BottomSheet
  void _setModalBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '알림 항목',
                    style: TStyle.commonSTitle,
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
                style: TStyle.commonTitle,
              ),
              const SizedBox(
                height: 15.0,
              ),
              const InkWell(
                child: Text('    라씨 매매비서의 AI매매신호'),
              ),
              const SizedBox(
                height: 10.0,
              ),
              const InkWell(
                child: Text('    AI속보'),
              ),
              const SizedBox(
                height: 10.0,
              ),
              const InkWell(
                child: Text('    소셜지수'),
              ),
              const SizedBox(
                height: 10.0,
              ),
              const InkWell(
                child: Text('    종목소식'),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                '종목 캐치 알림',
                style: TStyle.commonTitle,
              ),
              const SizedBox(
                height: 10.0,
              ),
              const InkWell(
                child: Text('    신규 매수'),
              ),
              const SizedBox(
                height: 10.0,
              ),
              const InkWell(
                child: Text('    캐치브리핑(매도성과, 인기종목)'),
              ),
              const SizedBox(
                height: 10.0,
              ),
              const InkWell(
                child: Text('    이슈&이슈'),
              ),
            ],
          ),
        );
      },
    );
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
                        style: TStyle.defaultTitle,
                        textScaleFactor: Const.TEXT_SCALE_FACTOR,
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
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
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
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
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
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
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

  Widget _setSheetMenu(BuildContext sheetContext, String menu, String toDiv) {
    return InkWell(
      child: Text(
        '    $menu',
        style: TStyle.defaultContent,
        textScaleFactor: Const.TEXT_SCALE_FACTOR,
      ),
      onTap: () {
        Navigator.pop(sheetContext);
        Navigator.push(
          context,
          _createPageRouteData(
            NotiListPage(),
            RouteSettings(
              arguments: PgData(pgData: toDiv),
            ),
          ),
        );
      },
    );
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(NotificationPage.TAG, '$trStr $json');

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
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(NotificationPage.TAG, response.body);

    if (trStr == TR.PUSH_LIST01) {
      final TrPushList01 resData =
          TrPushList01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (resData.listData != null && resData.listData.length > 0) {
          DLog.d(NotificationPage.TAG, _pushListA.toString());
          _pushListA.addAll(_setRecombineList(resData.listData));
          // _pushListA..addAll(resData.listData);
        }
      } else if (resData.retCode == RT.NO_DATA) {
        if (_pushListA.length == 0) isNoData = true;
      }
      setState(() {});
    }
  }

  //종목캐치(큰손/TOP/THEME) 데이터 가공해서 처리
  List<PushList01> _setRecombineList(List<PushList01> resList) {
    if (resList.length > 0) {
      for (int i = 0; i < resList.length; i++) {
        for (int j = 0; j < resList[i].divList.length; j++) {
          if (resList[i].divList[j].pushDiv1 == 'SC') {
            List<PushInfo> bigList = [];
            List<PushInfo> topList = [];
            List<PushInfo> themeList = [];

            for (int k = 0; k < resList[i].divList[j].pushList.length; k++) {
              if (resList[i].divList[j].pushList[k].pushDiv2 == 'BIGHAND') {
                bigList.add(resList[i].divList[j].pushList[k]);
              }
              if (resList[i].divList[j].pushList[k].pushDiv2 == 'SCORETOP') {
                topList.add(resList[i].divList[j].pushList[k]);
              }
              if (resList[i].divList[j].pushList[k].pushDiv2 == 'THEME') {
                themeList.add(resList[i].divList[j].pushList[k]);
              }
            }

            //SC 항목을 지우고
            var result = resList[i].divList.removeAt(j);
            //새로운 항목을 만들어 리스트 다시 추가 (리스트 끝에 추가)
            if (bigList.length > 0) {
              resList[i].divList.add(PushDiv(
                  pushDiv1: 'SC_BIG',
                  pushDiv1Name: '',
                  pushCount: '${bigList.length}',
                  pushList: bigList));
            }
            if (topList.length > 0) {
              resList[i].divList.add(PushDiv(
                  pushDiv1: 'SC_TOP',
                  pushDiv1Name: '',
                  pushCount: '${topList.length}',
                  pushList: topList));
            }
            if (themeList.length > 0) {
              resList[i].divList.add(PushDiv(
                  pushDiv1: 'SC_THEME',
                  pushDiv1Name: '',
                  pushCount: '${themeList.length}',
                  pushList: themeList));
            }
          }
        }
      }
    }

    return resList;
  }

  String getDivTitle(String div) {
    if (div == 'TS') {
      return '나의 종목-AI매매신호';
    } else if (div == 'RN') {
      return '나의 종목 - AI속보';
    } else if (div == 'SN') {
      return '나의 종목 - 소셜지수';
    } else if (div == 'SB') {
      return '나의 종목 - 종목소식';
    } else if (div == 'BS') {
      return '종목캐치 - 신규매수';
    } else if (div == 'CB') {
      return '라씨 소식 - 캐치브리핑(인기종목)';
    } else if (div == 'IS') {
      return '라씨 소식 - 이슈';
    } else if (div == 'HK') {
      return '종목캐치 - HOT';
    } else if (div == 'CS') {
      return '종목캐치 - 캐치';
    } else if (div == 'NT') {
      return '라씨 소식';
    } else if (div == 'SC_BIG') {
      return '큰손들의 종목캐치';
    } else if (div == 'SC_THEME') {
      return '테마캐치';
    } else if (div == 'SC_TOP') {
      return '성과 TOP 종목캐치';
    } else {
      return '';
    }
  }

  String getTypeString(String div) {
    if (div == 'TS') {
      return '';
    } else if (div == 'RN') {
      return 'AI속보';
    } else if (div == 'SN') {
      return '소셜지수';
    } else if (div == 'SB') {
      return ' 시세 ';
    } else if (div == 'BS') {
      return '';
    } else if (div == 'CB') {
      return '';
    } else if (div == 'IS') {
      return '';
    } else if (div == 'HK') {
      return '';
    } else if (div == 'CS') {
      return '';
    } else if (div == 'NT') {
      return '';
    } else {
      return '';
    }
  }

  Color getTypeColor(String div) {
    if (div == 'TS') {
      return Colors.white;
    } else if (div == 'RN') {
      return RColor.yonbora;
    } else if (div == 'SN') {
      return RColor.bgMintIssue;
    } else if (div == 'SB') {
      return RColor.bgMustard;
    } else if (div == 'BS') {
      return Colors.white;
    } else if (div == 'CB') {
      return Colors.white;
    } else if (div == 'IS') {
      return Colors.white;
    } else if (div == 'HK') {
      return Colors.white;
    } else if (div == 'CS') {
      return Colors.white;
    } else if (div == 'NT') {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }

  Route _createPageRouteData(Widget instance, RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
      settings: settings,
    );
  }

  //날짜 형식 표시
  String getDateFormat(String date) {
    String rtStr = '';
    if (date.length > 8) {
      rtStr = '${date.substring(0, 4)}.${date.substring(4, 6)}.'
          '${date.substring(6, 8)}  ${date.substring(8, 10)}:'
          '${date.substring(10, 12)}';
      return rtStr;
    }
    return '';
  }
}
