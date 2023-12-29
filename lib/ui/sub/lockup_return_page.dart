import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/tr_invest/tr_invest24.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2023.11.07_HJS
/// 보호예수 페이지
class LockupReturnPage extends StatefulWidget {
  static const String TAG = "[LockupReturnPage]";
  static const String TAG_NAME = '보호예수';
  final Stock stock;

  const LockupReturnPage(this.stock, {Key? key}) : super(key: key);

  //const LockupReturnPage({Key key}) : super(key: key);

  @override
  State<LockupReturnPage> createState() => _LockupReturnPageState();
}

class _LockupReturnPageState extends State<LockupReturnPage> {
  late SharedPreferences _prefs;
  String _userId = '';
  int _divIndex = 0;

  // DEFINE 보호 예수
  Invest24 _invest24 = Invest24.empty();
  final List<Invest24Lockup> _listLockup = [];
  final List<Invest24Lockup> _listReturn = [];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      LockupReturnPage.TAG_NAME,
    );
    _loadPrefData().then((_) => {
          _requestTrInvest24(),
        });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? AppGlobal().userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppbar.basic(
        context,
        widget.stock.stockName.length > 8
            ? '${widget.stock.stockName.substring(0, 8)} 보호예수'
            : '${widget.stock.stockName} 보호예수',
      ),
      body: SafeArea(
        child: Column(
          children: [
            _setDivButtons(),
            _setListWidget(),
          ],
        ),
      ),
    );
  }

  Widget _setDivButtons() {
    return Container(
      width: double.infinity,
      height: 35,
      margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (_, index) => _setDivButtonChild(index),
      ),
    );
  }

  Widget _setDivButtonChild(int index) {
    return InkWell(
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: () {
        if (_divIndex != index) {
          setState(() {
            _divIndex = index;
          });
        }
      },
      splashColor: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (index != 0)
            const SizedBox(
              width: 10,
            ),
          Transform.scale(
            scale: 0.9,
            child: Radio(
              fillColor: _divIndex == index
                  ? MaterialStateColor.resolveWith((states) => Colors.black)
                  : MaterialStateColor.resolveWith(
                      (states) => RColor.greyTitle_cdcdcd),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(
                horizontal: VisualDensity.minimumDensity,
                vertical: VisualDensity.minimumDensity,
              ),
              value: index,
              groupValue: _divIndex,
              onChanged: (value) {
                if (_divIndex != value) {
                  setState(() {
                    _divIndex = value!;
                  });
                }
              },
            ),
          ),
          const SizedBox(
            width: 2,
          ),
          Text(
            index == 0
                ? '전체'
                : index == 1
                    ? '예탁만보기'
                    : index == 2
                        ? '반환만보기'
                        : '전체',
            style: const TextStyle(
                fontSize: 15,
                ),
          ),
        ],
      ),
    );
  }

  Widget _setListWidget() {
    return Expanded(
      child: Column(
        children: [
          if ((_invest24.listInvest24Lockup.isEmpty && _divIndex == 0) ||
              (double.parse(_invest24.lockupCount) == 0 && _divIndex == 1) ||
              (double.parse(_invest24.returnCount) == 0 && _divIndex == 2))
            Expanded(
              child: Center(
                child: Text(
                  (_invest24.listInvest24Lockup.isEmpty && _divIndex == 0)
                      ? '최근 3년간 보호예수 내용이 없습니다.'
                      : (double.parse(_invest24.lockupCount) == 0 &&
                              _divIndex == 1)
                          ? '최근 3년간 예탁 내용이 없습니다.'
                          : (double.parse(_invest24.returnCount) == 0 &&
                                  _divIndex == 2)
                              ? '최근 3년간 반환 내용이 없습니다.'
                              : '최근 3년간 보호예수 내용이 없습니다.',
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10,),
                itemCount: _divIndex == 0
                    ? _invest24.listInvest24Lockup.length
                    : _divIndex == 1
                        ? _listLockup.length
                        : _divIndex == 2
                            ? _listReturn.length
                            : _invest24.listInvest24Lockup.length,
                itemBuilder: (context, index) {
                  return _divIndex == 0
                      ? _invest24.listInvest24Lockup[index]
                          .tileInvest24LockupView()
                      : _divIndex == 1
                          ? _listLockup[index].tileInvest24LockupView()
                          : _divIndex == 2
                              ? _listReturn[index].tileInvest24LockupView()
                              : const SizedBox();
                },
              ),
            ),
        ],
      ),
    );
  }

  _requestTrInvest24() async {
    _fetchPosts(
      TR.INVEST24,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'stockCode': widget.stock.stockCode,
          'selectDiv': "Y3",
        },
      ),
    );
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    //DLog.d(StockHomeHomePage.TAG, trStr + ' ' + json);

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
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

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    // NOTE 보호 예수
    if (trStr == TR.INVEST24) {
      final TrInvest24 resData = TrInvest24.fromJson(jsonDecode(response.body));
      _invest24 = Invest24.empty();
      _listLockup.clear();
      _listReturn.clear();
      if (resData.retCode == RT.SUCCESS) {
        _invest24 = resData.retData!;
        _invest24.listInvest24Lockup.map((e) {
          if (e.workDiv == '반환') {
            _listReturn.add(e);
          } else {
            _listLockup.add(e);
          }
        }).toList();
      }
      setState(() {});
    }
  }
}
