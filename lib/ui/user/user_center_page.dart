import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/tr_qna02.dart';
import 'package:rassi_assist/models/tr_qna03.dart';
import 'package:rassi_assist/ui/user/write_qna_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// 2021.02.16
/// 고객센터 1:1 문의
class UserCenterPage extends StatelessWidget {
  static const routeName = '/page_user_center';
  static const String TAG = "[UserCenterPage]";
  static const String TAG_NAME = '1대1문의';

  const UserCenterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: RColor.deepStat,
        elevation: 0,
      ),
      body: UserCenterWidget(),
    );
  }
}

class UserCenterWidget extends StatefulWidget {
  const UserCenterWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => UserCenterState();
}

class UserCenterState extends State<UserCenterWidget> {
  String _userId = '';

  String strType = '';
  int pageNum = 0;
  List<QnaItem> _listData = [];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      UserCenterPage.TAG_NAME,
    );

    _userId = AppGlobal().userId;
    DLog.d(WriteQnaPage.TAG, '페이지 시작 ID : $_userId');
    if (_userId != '') {
      _fetchPosts(
          TR.QNA02,
          jsonEncode(<String, String>{
            'userId': _userId,
            'pageNo': pageNum.toString(),
            'pageItemSize': '20',
          }));
    }
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
      appBar: AppBar(
        title: const Text(
          '1:1문의',
          style: TStyle.commonTitle,
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          _setListHeader(),
          ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: _listData.length,
            itemBuilder: (context, index) {
              return _setTileList(_listData[index]);
            },
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget _setTileList(QnaItem item) {
    if (item.qnaStatus == '1') strType = '질문중';
    if (item.qnaStatus == '2') strType = '재질문';
    if (item.qnaStatus == '3') strType = '문제 해결';
    if (item.qnaStatus == '4') strType = '답변 완료';

    return Container(
      width: double.infinity,
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strType,
                style: TStyle.textMGrey,
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Q : ${item.title}',
                style: TStyle.contentSBLK,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(
                height: 15,
              ),
              const Divider(
                height: 1,
              ),
            ],
          ),
        ),
        onTap: () {
          _fetchPosts(
              TR.QNA03,
              jsonEncode(<String, String>{
                'userId': _userId,
                'qnaSn': item.qnaSn,
              }));
        },
      ),
    );
  }

  Widget _setListHeader() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          _setBoxBtn('1:1문의 등록하기'),
          _setSubTitle('나의 질문 리스트'),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            height: 1,
          ),
          // const SizedBox(height: 15,),
        ],
      ),
    );
  }

  //Custom Button
  Widget _setBoxBtn(String title) {
    return InkWell(
      child: Container(
        width: double.infinity,
        height: 45,
        margin: const EdgeInsets.only(
          left: 15.0,
          right: 15.0,
          top: 10.0,
        ),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: RColor.lineGrey,
            width: 0.7,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title),
          ],
        ),
      ),
      onTap: () {
        _navigateRefreshData(context, const WriteQnaPage());
      },
    );
  }

  void _navigateRefreshData(BuildContext context, Widget instance) async {
    // final result = await Navigator.push(context, _createRoute(instance));
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => instance));
    if (result == 'cancel') {
      DLog.d(UserCenterPage.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(UserCenterPage.TAG, '*** navigateRefresh');
      // _fetchPosts(TR.USER04,
      //     jsonEncode(<String, String>{
      //       'userId': _userId,
      //     }));
    }
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
      child: Text(
        subTitle,
        style: TStyle.commonTitle,
      ),
    );
  }

  //QNA 상세내용 다이얼로그
  void _showDialogQna(Qna03 qItem) {
    String answer = '';
    if (qItem.answer.isNotEmpty) {
      for (int i = 0; i < qItem.answer.length; i++) {
        answer = answer + qItem.answer[i].content;
      }
    } else {
      answer = '답변 미완료';
      DLog.d(UserCenterPage.TAG, 'answer list null');
    }

    List<String> answerStrList = [];
    List<TextSpan> spanList = [];
    if (answer.isNotEmpty && answer.contains('http')) {
      answerStrList.add(answer.substring(0, answer.indexOf('http')));
      spanList.add(
        TextSpan(
          text: answerStrList[0],
        ),
      );
      answer = answer.substring(answer.indexOf('http'));
      answerStrList.add(answer.substring(0, answer.indexOf('\r')));
      spanList.add(
        TextSpan(
            text: answerStrList[1],
            style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                //on tap code here, you can navigate to other page or URL
                Uri uri = Uri.parse(
                  answerStrList[1],
                );
                var urlLaunchable = await canLaunchUrl(
                    uri); //canLaunch is from url_launcher package
                if (urlLaunchable) {
                  await launchUrl(
                      uri); //launch is from url_launcher package to launch URL
                } else {
                  DLog.e(answerStrList[1]);
                }
              }),
      );
      answer = answer.substring(answer.indexOf('\r'));
      answerStrList.add(answer);
      spanList.add(
        TextSpan(
          text: answerStrList[2],
        ),
      );
    } else {
      spanList.add(
        TextSpan(
          text: answer,
        ),
      );
    }

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('1:1 문의'),
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
                  //Q
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q',
                        style: TStyle.puplePlainStyle(),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              qItem.title,
                              style: TStyle.commonSTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              qItem.content,
                              style: TStyle.textGrey14,
                              maxLines: 200,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    height: 1.5,
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  //A
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A',
                        style: TStyle.puplePlainStyle(),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            style: TStyle.textGrey14,
                            children: spanList,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 25.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //재질문
                      InkWell(
                        child: Container(
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: RColor.lineGrey,
                              width: 0.7,
                            ),
                            borderRadius: const BorderRadius.all(
                                Radius.circular(10.0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('재질문'),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateRefreshData(context, const WriteQnaPage());
                        },
                      ),
                      const SizedBox(
                        width: 20,
                      ),

                      //문제해결
                      InkWell(
                        child: Container(
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: RColor.lineGrey,
                              width: 0.7,
                            ),
                            borderRadius: const BorderRadius.all(
                                Radius.circular(10.0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('문제해결'),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _fetchPosts(
                              TR.QNA04,
                              jsonEncode(<String, String>{
                                'userId': _userId,
                                'qnaSn': qItem.qnaSn,
                              }));
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        });
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
                    padding:
                        EdgeInsets.only(top: 20, left: 10, right: 10),
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
                  InkWell(
                    child: Container(
                      width: 140,
                      height: 36,
                      decoration: UIStyle.roundBtnStBox(),
                      child: const Center(
                        child: Text(
                          '확인',
                          style: TStyle.btnTextWht15,
                          
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

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(UserCenterPage.TAG, trStr + ' ' + json);

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
      DLog.d(UserCenterPage.TAG, 'ERR : TimeoutException (12 seconds)');
      _showDialogNetErr();
    } on SocketException catch (_) {
      DLog.d(UserCenterPage.TAG, 'ERR : SocketException');
      _showDialogNetErr();
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(UserCenterPage.TAG, response.body);

    if (trStr == TR.QNA02) {
      final TrQna02 resData = TrQna02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _listData = resData.retData.listData;
        setState(() {});
      }
    }

    //QNA 상세 조회
    else if (trStr == TR.QNA03) {
      final TrQna03 resData = TrQna03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _showDialogQna(resData.retData);
      }
    } else if (trStr == TR.QNA04) {
      _fetchPosts(
          TR.QNA02,
          jsonEncode(<String, String>{
            'userId': _userId,
            'pageNo': pageNum.toString(),
            'pageItemSize': '20',
          }));
    }
  }
}
