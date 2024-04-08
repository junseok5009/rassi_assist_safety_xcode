import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/login/agent/agent_welcome_first_page.dart';
import 'package:rassi_assist/ui/login/agent/agent_welcome_second_page.dart';
import 'package:rassi_assist/ui/login/agent/agent_welcome_third_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgentWelcomePage extends StatefulWidget {
  const AgentWelcomePage({super.key});

  static const String routeName = "/agent_welcome";

  @override
  State<AgentWelcomePage> createState() => _AgentWelcomePageState();
}

class _AgentWelcomePageState extends State<AgentWelcomePage> {
  late SharedPreferences _prefs;
  String _userId = '';
  int _pageIndex = 0; // 0 : 환영합니다 / 1 : 꼭 이용해보세요 / 2 : 확인하세요

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView('에이전트_웰컴');
    _loadPrefData().then((_) {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? AppGlobal().userId;
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppbar.none(
        Colors.white,
      ),
      body: SafeArea(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                  child: _pageIndex == 0
                      ? const AgentWelcomeFirstPage()
                      : _pageIndex == 1
                          ? const AgentWelcomeSecondPage()
                          : const AgentWelcomeThirdPage()),
            ),
            InkWell(
              onTap: () {
                if (_pageIndex >= 2) {
                  _fetchPostsWithParse();
                } else {
                  setState(() {
                    _pageIndex++;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                height: 70,
                alignment: Alignment.center,
                color: RColor.greyBox_dcdfe2,
                child: Text(_pageIndex != 2 ? '다음 > ' : '확인하였습니다.'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _fetchPostsWithParse() async {
    var url = Uri.parse(Net.TR_BASE + TR.USER05);
    await http.post(
      url,
      body: jsonEncode(
        <String, String>{
          "userId": _userId,
        },
      ),
      headers: Net.headers,
    );
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
