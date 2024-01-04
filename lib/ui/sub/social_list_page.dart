import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/models/tr_sns03.dart';
import 'package:rassi_assist/models/tr_sns04.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/only_web_view.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 2021.02.15
/// 소셜지수 핫 종목 리스트
class SocialListPage extends StatefulWidget {
  static const routeName = '/page_social_list';
  static const String TAG = "[SocialListPage]";
  static const String TAG_NAME = '오늘의_소셜지수_핫_종목';

  @override
  State<StatefulWidget> createState() => SocialListPageState();
}

class SocialListPageState extends State<SocialListPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  String statSns = 'images/rassibs_cht_img_1_4.png';
  List<Sns04> _dataList = [];
  String totCnt = '0';
  bool _snsEmpty = false;
  int iCnt = 0;

  bool FAB_visibility = true;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(SocialListPage.TAG_NAME);
    _loadPrefData();
    Future.delayed(const Duration(milliseconds: 300), () {
      DLog.d(SocialListPage.TAG, "delayed user id : $_userId");
      if (_userId != '') {
        _fetchPosts(
            TR.SNS04,
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

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: _setLayout(),
    );
  }

  Widget _setLayout() {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CommonAppbar.basic(context, '오늘의 소셜지수 핫 종목'),
        body: SafeArea(
          child: ListView.builder(
            itemCount: _dataList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _setHeaderView();
              } else {
                return _buildOneItem(
                    _dataList[index - 1].issueTime,
                    _dataList[index - 1].listData
                );
              }
            },
          ),
        )

        // body: SafeArea(
        //   child: ListView(
        //     children: [
        //       _setHeaderView(),
        //       const SizedBox(height: 15,),
        //
        //       ListView.builder(
        //         physics: ScrollPhysics(),
        //         shrinkWrap: true,
        //         itemCount: _dataList.length,
        //         itemBuilder: (context, index){
        //           return TileSns03(_dataList[index]);
        //         },
        //       ),
        //       const SizedBox(height: 15,),
        //     ],
        //   ),
        // ),
        );
  }

  Widget _setAppBar() {
    return Container(
      height: Const.HEIGHT_APP_BAR,
      decoration: const BoxDecoration(
          border: Border(
        bottom: BorderSide(color: RColor.lineGrey, width: 1),
      )),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            padding: const EdgeInsets.only(
              left: 12,
              right: 3,
            ),
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.arrow_back_ios),
            // iconSize: 20,
            onPressed: () => Navigator.of(context).pop(null),
          ),
          const Text(
            '오늘의 소셜지수 핫 종목',
            style: TStyle.commonTitle,
          ),
          const SizedBox(
            width: 40,
          )
        ],
      ),
    );
  }

  //타임라인 리스트
  Widget _buildOneItem(String strTime, List<SnsFlow> subList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(
            left: 15,
            top: 15,
          ),
          child: Row(
            children: [
              Image.asset(
                'images/rassi_itemar_icon_ar1.png',
                fit: BoxFit.cover,
                scale: 3,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                TStyle.getTimeFormat(strTime),
                style: const TextStyle(
                    fontSize: 14, color: Colors.deepOrangeAccent),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 7, left: 15, right: 15, bottom: 5),
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: subList.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: UIStyle.boxRoundLine6(),
                  child: InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Flexible(
                                    child: Text(
                                      subList[index].stockName,
                                      style: TStyle.defaultTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 3.0,
                                  ),
                                  Text(
                                    subList[index].stockCode,
                                    style: TStyle.textSGrey,
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                ],
                              ),
                              Visibility(
                                visible: subList[index].title.isNotEmpty &&
                                    subList[index].linkUrl.isNotEmpty,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        //TODO @@@@@
                                        // Navigator.push(
                                        //   context,
                                        //   _createRouteData(
                                        //     OnlyWebView(),
                                        //     RouteSettings(
                                        //       arguments: PgNews(
                                        //           linkUrl:
                                        //               subList[index].linkUrl),
                                        //     ),
                                        //   ),
                                        // );
                                      },
                                      child: Text(
                                        subList[index].title,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              subList[index].elapsedTmTx,
                              style: TStyle.commonTitle,
                            ),
                            const Text(
                              '폭발',
                              style: TStyle.defaultContent,
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      // 종목홈으로 이동
                      basePageState.goStockHomePage(
                        subList[index].stockCode,
                        subList[index].stockName,
                        Const.STK_INDEX_HOME,
                      );
                    },
                  ),
                );
              }),
        )
      ],
    );
  }

  Widget _setHeaderView() {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      '   현재 ',
                      style: TStyle.content15,
                    ),
                    Text(
                      '소셜지수',
                      style: TStyle.commonTitle,
                    ),
                    Text(
                      ' 폭발 종목은',
                      style: TStyle.content15,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '   총 ${iCnt.toString()}종목 ',
                      style: TStyle.commonTitle,
                    ),
                    const Text(
                      '입니다.',
                      style: TStyle.content15,
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              icon: const ImageIcon(
                AssetImage(
                  'images/rassi_icon_qu_bl.png',
                ),
                size: 22,
              ),
              color: Colors.grey,
              onPressed: () {
                _showDialogDesc();
              },
            )
          ],
        ),
        const SizedBox(
          height: 25,
        ),
        Container(
          width: double.infinity,
          height: 120,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('참여도\n낮음'),
              const SizedBox(
                width: 10.0,
              ),
              Image.asset(
                statSns,
                fit: BoxFit.cover,
              ),
              const SizedBox(
                width: 10.0,
              ),
              const Text('참여도\n높음'),
            ],
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        Visibility(
          visible: _snsEmpty,
          child: Column(
            children: const [
              Text(
                '현재 발생된 소셜지수 폭발\n종목이 없습니다.',
                style: TStyle.defaultContent,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 15,
              ),

              // MaterialButton(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(17.0),
              //     side: BorderSide(color: RColor.lineGrey),),
              //   color: Colors.white,
              //   textColor: RColor.mainColor,
              //   padding: const EdgeInsets.all(2.0),
              //   child: Container(
              //     width: 200,
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Text('+최근 7일간', style: TStyle.puplePlainStyle(),),
              //         const SizedBox(width: 4.0,),
              //         Text('발생 종목 더보기', style: TStyle.commonSTitle,),
              //       ],
              //     ),
              //   ),
              //   onPressed: (){
              //     // Navigator.pushNamed(context, PocketBoard.routeName,
              //     //     arguments: PgData(pgSn: ''));
              //   },
              // ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDialogDesc() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(25), //전체 margin 동작
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
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
                  const Text(
                    '소셜지수란?',
                    style: TStyle.commonTitle,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  const Text(
                    RString.desc_social_index,
                    style: TStyle.content15,
                    textScaleFactor: Const.TEXT_SCALE_FACTOR,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(SocialListPage.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    final http.Response response = await http.post(
      url,
      body: json,
      headers: Net.headers,
    );

    if (_bYetDispose) _parseTrData(trStr, response);
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(SocialListPage.TAG, response.body);

    //(삭제 예정)
    if (trStr == TR.SNS03) {
      final TrSns03 resData = TrSns03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        // totCnt = resData.listData.length.toString();
        // _dataList = resData.listData;
        setState(() {});
      }
    }

    if (trStr == TR.SNS04) {
      final TrSns04 resData = TrSns04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _snsEmpty = false;
        _dataList = resData.listData;
        for (int i = 0; i < _dataList.length; i++) {
          iCnt = iCnt + _dataList[i].subCount;
        }
        setState(() {});
      } else if (resData.retCode == RT.NO_DATA) {
        _snsEmpty = true;
        setState(() {});
      }
    }
  }

  //페이지 전환 에니메이션 (데이터 전달)
  Route _createRouteData(Widget instance, RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
      settings: settings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.ease));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
