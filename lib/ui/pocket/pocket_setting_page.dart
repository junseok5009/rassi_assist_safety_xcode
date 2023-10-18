import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/rq_pocket_order.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock01.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock03.dart';
import 'package:rassi_assist/ui/sub/notification_setting_new.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2021.01.25
/// 포켓 설정 페이지
class PocketSettingPage extends StatelessWidget {
  static const routeName = '/page_pocket_setting';
  static const String TAG = "[PocketSettingPage]";
  static const String TAG_NAME = '나의_종목_포켓_설정';

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: RColor.deepStat,
          elevation: 0,
        ),
        body: PocketSettingWidget(),
      ),
    );
  }
}

class PocketSettingWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PocketSettingState();
}

class PocketSettingState extends State<PocketSettingWidget> {
  late SharedPreferences _prefs;
  String _userId = "";
  late PgData args;
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  late SwiperController controller;
  List<Pock03> _pktList = []; //포켓리스트
  int pageIdx = 0;

  String stkName = '';
  String stkCode = '';
  String pock01Type = '';

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: PocketSettingPage.TAG_NAME,
      screenClassOverride: PocketSettingPage.TAG_NAME,
    );

    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 400), () {
      DLog.d(PocketSettingPage.TAG, "delayed user id : $_userId");
      if (_userId != '') {
        _fetchPosts(
            TR.POCK03,
            jsonEncode(<String, String>{
              'userId': _userId,
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
  void dispose() {
    _bYetDispose = false;
    super.dispose();
  }

  void _popPrePage() {
    _saveListOrder();
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pop(null);
    });
  }

  void _saveListOrder() {
    List<SeqItem> seqList = [];
    for (int i = 0; i < _pktList.length; i++) {
      seqList.add(SeqItem(_pktList[i].pocketSn, (i + 1).toString()));
    }

    PocketOrder order = PocketOrder(_userId, seqList);
    if (_userId != '') {
      _fetchPosts(TR.POCK02, jsonEncode(order));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _setCustomAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10,),
              width: double.infinity,
              child: const Text(
                '※ 터치 상태에서 상하로 움직여 순서를 변경하실 수 있습니다.',
                style: TStyle.textMGrey,
              ),
            ),
            Expanded(child: _setReorderableList(),),
          ],
        ),
      ),
    );
  }

  //리스트 순서 변경 리스트
  Widget _setReorderableList() {
    return ReorderableListView(
      shrinkWrap: true,
      onReorder: (int start, int current) {
        //dragging from top to bottom
        if (start < current) {
          int end = current - 1;
          Pock03 startItem = _pktList[start];
          int i = 0;
          int local = start;
          do {
            _pktList[local] = _pktList[++local];
            i++;
          } while (i < end - start);
          _pktList[end] = startItem;
        }
        //dragging from bottom to top
        else if (start > current) {
          Pock03 startItem = _pktList[start];
          for (int i = start; i > current; i--) {
            _pktList[i] = _pktList[i - 1];
          }
          _pktList[current] = startItem;
        }
        setState(() {});
      },
      children: _pktList.map((item) => _setListItem(item)).toList(),
    );
  }

  //리스트 아이템 설정
  Widget _setListItem(Pock03 item) {
    return Container(
      key: Key(item.pocketSn),
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7,),
      alignment: Alignment.centerLeft,
      decoration: UIStyle.boxRoundLine15(),
      child: Container(
        width: double.infinity,
        height: 70,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    item.pocketName,
                    style: TStyle.commonTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: RColor.mainColor,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "  설정  ",
                            style: TStyle.puplePlainStyle(),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      _setModalBottomSheet(
                          context, item.pocketSn, item.pocketName);
                    },
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Text('보유'),
                Text(
                  item.holdCount,
                  style: TStyle.commonSTitle,
                ),
                const SizedBox(
                  width: 5.0,
                ),
                const Text('관심'),
                Text(
                  item.waitCount,
                  style: TStyle.commonSTitle,
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Image.asset(
                  'images/main_jm_icon_list_awtb.png',
                  height: 17,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 타이틀바(AppBar)
  PreferredSizeWidget _setCustomAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.black,
              onPressed: () => _popPrePage()),
          const Text(
            '종목 포켓 설정',
            style: TStyle.commonTitle,
          ),
          const SizedBox(
            width: 55.0,
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      toolbarHeight: 50,
      elevation: 1,
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 7),
      child: Text(
        subTitle,
        style: TStyle.commonTitle,
        textScaleFactor: Const.TEXT_SCALE_FACTOR,
      ),
    );
  }

  // 다이얼로그
  void _showDialogMsg(String message, String btnText) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
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
                    height: 25.0,
                  ),
                  Text(
                    '$message',
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),

                  InkWell(
                    child: Container(
                      width: 140,
                      height: 36,
                      decoration: UIStyle.roundBtnStBox(),
                      child: Center(
                        child: Text(
                          btnText,
                          style: TStyle.btnTextWht15,
                          textScaleFactor: Const.TEXT_SCALE_FACTOR,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  //종목 포켓 설정
  void _setModalBottomSheet(context, String pktSn, String pktName) {
    final nameController = TextEditingController();
    bool isNaming = false;
    String strHint = pktName;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),

                  //종목 포켓 설정
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _setSubTitle('종목 포켓 설정'),
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
                    height: 15.0,
                  ),

                  //종목 포켓명
                  _setSubTitle('종목 포켓명'),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextField(
                          enabled: isNaming,
                          controller: nameController,
                          decoration: InputDecoration(hintText: strHint),
                        ),
                      ),
                      Positioned(
                        right: 10.0,
                        top: 6,
                        child: InkWell(
                          child: Container(
                            decoration: UIStyle.boxRoundLine6(),
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 20),
                            child: Stack(
                              children: [
                                Visibility(
                                  visible: !isNaming,
                                  child: const Text(
                                    '변경',
                                    style: TextStyle(fontSize: 14.0),
                                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                                  ),
                                ),
                                Visibility(
                                  visible: isNaming,
                                  child: const Text(
                                    '확인',
                                    style: TextStyle(fontSize: 14.0),
                                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            //이름 변경중
                            if (isNaming) {
                              String chName = nameController.text.trim();
                              if (chName.length > 0) {
                                Navigator.pop(context);
                                requestPocket('U', pktSn, chName);
                              } else {
                                _showDialogMsg('포켓명을 입력해주세요', '확인');
                              }
                            } else {
                              setModalState(() {
                                isNaming = true;
                                strHint = '포켓명을 입력해 주세요.';
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),

                  //알림 설정
                  InkWell(
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius:
                            BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/rassibs_btn_icon.png',
                            height: 24,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '알림설정',
                                style: TStyle.btnTextWht13,
                                textScaleFactor: Const.TEXT_SCALE_FACTOR,
                              ),
                              Text(
                                '매매신호, 종목알림 동의',
                                style: TStyle.btnSsTextWht,
                                textScaleFactor: Const.TEXT_SCALE_FACTOR,
                              ),
                              Text(
                                '수신 설정 화면으로 이동합니다.',
                                style: TStyle.btnSsTextWht,
                                textScaleFactor: Const.TEXT_SCALE_FACTOR,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotificationSettingN()));
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),

                  //종목 포켓 삭제
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: const [
                          Text(
                            '- 종목 포켓 삭제',
                            style: TStyle.commonSTitle,
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
                          ),
                          Text(
                            '(등록된 모든 종목을 삭제하시겠습니까?)',
                            style: TStyle.textSGrey,
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
                          ),
                        ],
                      ),

                      //종목 삭제
                      IconButton(
                        icon: Image.asset(
                          'images/main_my_icon_del.png',
                          height: 17,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showDelPocket(pktSn);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //포켓 삭제 다이얼로그
  void _showDelPocket(String pktSn) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
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
                  const Text(
                    '포켓 및 등록된 모든 종목이 삭제됩니다.\n삭제하시겠습니까?',
                    textAlign: TextAlign.center,
                    style: TStyle.contentMGrey,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  InkWell(
                    child: Container(
                      width: 140,
                      height: 36,
                      decoration: UIStyle.roundBtnStBox(),
                      child: const Center(
                        child: Text(
                          '확인',
                          style: TStyle.btnTextWht15,
                          textScaleFactor: Const.TEXT_SCALE_FACTOR,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      requestPocket('D', pktSn, '');
                    },
                  ),

                ],
              ),
            ),
          );
        });
  }

  //포켓 업데이트/삭제
  requestPocket(String type, String pktSn, String chName) {
    setState(() {
      pock01Type = type;
    });

    _fetchPosts(
        TR.POCK01,
        jsonEncode(<String, String>{
          'userId': _userId,
          'crudType': type,
          'pocketSn': pktSn,
          'pocketName': chName,
        }));
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(PocketSettingPage.TAG, trStr + ' ' + json);

    var url = Uri.parse(Net.TR_BASE + trStr);
    final http.Response response = await http.post(
      url,
      body: json,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (_bYetDispose) _parseTrData(trStr, response);
  }

  // parse
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(PocketSettingPage.TAG, response.body);

    if (trStr == TR.USER04) {
    } else if (trStr == TR.POCK03) {
      final TrPock03 resData = TrPock03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _pktList = resData.listData;
        setState(() {});
      }
    } else if (trStr == TR.POCK01) {
      final TrPock01 resData = TrPock01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (pock01Type == 'U') {
          commonShowToast('포켓명이 변경 되었습니다.');
        } else if (pock01Type == 'D') {
          //포켓 삭제 완료
        }
        _fetchPosts(
            TR.POCK03,
            jsonEncode(<String, String>{
              'userId': _userId,
            }));
      } else {}
    }
  }
}
