import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/none_tr/user_join_info.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/login/join_route_page.dart';
import 'package:rassi_assist/ui/sub/web_page.dart';

// 24.01.04 [회원가입-약관동의]

class TermsOfUsePage extends StatefulWidget {
  final UserJoinInfo userJoinInfo;

  const TermsOfUsePage(
    this.userJoinInfo, {
    Key? key,
  }) : super(key: key);

  @override
  State<TermsOfUsePage> createState() => _TermsOfUsePageState();
}

class _TermsOfUsePageState extends State<TermsOfUsePage> {
  final List<bool> _checkBoolList = [false, false, false];
  bool _checkAll = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: '',
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              RichText(
                textAlign: TextAlign.start,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: '서비스 이용을 위해\n이용 약관을 확인해 주세요.\n\n',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text:
                          '라씨 매매비서는 서비스 제공을 위해\n최소한의 정보만을 수집하여\n수집된 정보 보안을 위해 최선을 다합니다.',
                      style: TextStyle(
                        //본문 내용 - 기준
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _setBtns(),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: BottomSheet(
        backgroundColor: Colors.white,
        builder: (bsContext) => InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            if (!_checkBoolList[0]) {
              CommonPopup.instance
                  .showDialogBasic(context, '알림', '서비스 이용약관에 동의해 주세요.');
            } else if (!_checkBoolList[1]) {
              CommonPopup.instance
                  .showDialogBasic(context, '알림', '개인정보 수집 및 이용에 동의해 주세요.');
            } else if (!_checkBoolList[2]) {
              CommonPopup.instance
                  .showDialogBasic(context, '알림', '만 14세 이상을 확인해 주세요.');
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => JoinRoutePage(widget.userJoinInfo),
                ),
              );
            }
          },
          child: Container(
            width: double.infinity,
            height: 86,
            margin: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: MediaQuery.of(_scaffoldKey.currentState!.context)
                      .viewPadding
                      .bottom +
                  10,
            ),
            child: Column(
              children: [
                const Text('시작하기를 하시면 서비스가 바로 시작됩니다.'),
                Container(
                  width: double.infinity,
                  height: 50,
                  //color: RColor.mainColor,
                  decoration: const BoxDecoration(
                    color: RColor.purpleBasic_6565ff,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  margin: const EdgeInsets.only(
                    top: 15,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '시작하기',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onClosing: () {},
        enableDrag: false,
      ),
    );
  }

  Widget _setBtns() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 전체 동의
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              setState(() {
                if (_checkAll) {
                  _checkBoolList[0] = false;
                  _checkBoolList[1] = false;
                  _checkBoolList[2] = false;
                } else {
                  _checkBoolList[0] = true;
                  _checkBoolList[1] = true;
                  _checkBoolList[2] = true;
                }
                _checkAll = !_checkAll;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    _checkAll
                        ? 'images/icon_circle_check_y.png'
                        : 'images/icon_circle_check_n.png',
                    fit: BoxFit.cover,
                    width: 22,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    '전체동의',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: double.infinity,
            height: 1,
            color: RColor.greyBox_dcdfe2,
            margin: const EdgeInsets.symmetric(
              vertical: 10,
            ),
          ),

          // 서비스 이용약관
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              setState(() {
                _checkBoolList[0] = !_checkBoolList[0];
                _funcCheckAll();
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    _checkBoolList[0]
                        ? 'images/icon_circle_check_y.png'
                        : 'images/icon_circle_check_n.png',
                    fit: BoxFit.cover,
                    width: 22,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    '서비스 이용약관',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      Navigator.push(
                        context,
                        CustomNvRouteClass.createRouteData(
                          WebPage(),
                          RouteSettings(
                            arguments: PgData(
                              pgData: Net.AGREE_TERMS,
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5,
                      ),
                      child: Text(
                        '내용보기',
                        style: TextStyle(
                          fontSize: 13,
                          color: RColor.greyMore_999999,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 개인정보 수집 및 이용
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              setState(() {
                _checkBoolList[1] = !_checkBoolList[1];
                _funcCheckAll();
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    _checkBoolList[1]
                        ? 'images/icon_circle_check_y.png'
                        : 'images/icon_circle_check_n.png',
                    fit: BoxFit.cover,
                    width: 22,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    '개인정보 수집 및 이용',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      Navigator.push(
                        context,
                        CustomNvRouteClass.createRouteData(
                          WebPage(),
                          RouteSettings(
                            arguments: PgData(
                              pgData: Net.AGREE_POLICY_INFO,
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5,
                      ),
                      child: Text(
                        '내용보기',
                        style: TextStyle(
                          fontSize: 13,
                          color: RColor.greyMore_999999,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 만 14세 이상
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              setState(() {
                _checkBoolList[2] = !_checkBoolList[2];
                _funcCheckAll();
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    _checkBoolList[2]
                        ? 'images/icon_circle_check_y.png'
                        : 'images/icon_circle_check_n.png',
                    fit: BoxFit.cover,
                    width: 22,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    '만 14세 이상입니다.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _funcCheckAll() {
    if (_checkBoolList[0] && _checkBoolList[1] && _checkBoolList[2]) {
      _checkAll = true;
    } else {
      _checkAll = false;
    }
  }
}
