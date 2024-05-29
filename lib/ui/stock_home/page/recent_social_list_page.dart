import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_sns/tr_sns06.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/const.dart';
import '../../../../common/net.dart';
import '../../common/common_popup.dart';
import '../../../common/d_log.dart';

/// 23.03.15 HJS
/// 종목홈_소셜분석_최근 소셜지수 리스트 화면
class RecentSocialListPage extends StatefulWidget {
  static const String TAG_NAME = '최근_1개월_소셜지수_리스트';
  const RecentSocialListPage({Key? key}) : super(key: key);
  @override
  State<RecentSocialListPage> createState() => _RecentSocialListPageState();
}

class _RecentSocialListPageState extends State<RecentSocialListPage> {
  late SharedPreferences _prefs;
  String _userId = '';
  String _statSns = 'images/rassibs_cht_img_1_1.png';
  String _isNoData = '';
  String _stockName = '';
  String _stockCode = '';
  final List<SNS06ChartData> _listData = [];
  final List<String> _listTitle = ['날짜', '소셜지수', '종가'];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      RecentSocialListPage.TAG_NAME,
    );
    _loadPrefData().then(
      (_) => {
        Future.delayed(Duration.zero, () {
          PgData pgData = ModalRoute.of(context)!.settings.arguments as PgData;
          if (_userId != '' && pgData != null && pgData.isStockDataExist()) {
            _stockName = pgData.stockName;
            _stockCode = pgData.stockCode;
            _fetchPosts(
              TR.SNS06,
              jsonEncode(
                <String, String>{
                  'userId': _userId,
                  'stockCode': _stockCode,
                  "selectDiv": "M1",
                },
              ),
            );
          } else {
            Navigator.pop(context);
          }
        }),
      },
    );
  }

  @override
  void setState(VoidCallback fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _stockName.length > 8
                  ? '${_stockName.substring(0, 8)} 소셜지수'
                  : '$_stockName 소셜지수',
              style: TStyle.title18T,
            ),
            IconButton(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                //horizontal: 10,
              ), // 패딩 설정
              constraints: const BoxConstraints(), // constraints
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              icon: const Icon(
                Icons.close,
                color: Colors.black,
                size: 26,
              ),
            ),
          ],
        ),
        //iconTheme: IconThemeData(color: Colors.black),
        centerTitle: false,
        leadingWidth: 0,
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: _isNoData == 'Y'
              ? const Center(
                  child: Text('최근 소셜지수 내역이 없습니다.'),
                )
              : _isNoData == 'N'
                  ? ListView(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _setSocialIndex(),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          '최근 1개월 소셜지수',
                          style: TStyle.title18T,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _setMarketConditionView(),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                  : const SizedBox(),
        ),
      ),
    );
  }

  Widget _setSocialIndex() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 20,
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: UIStyle.boxRoundLine17(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxHeight: 120,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '참여도\n낮음',
                  textAlign: TextAlign.center,
                ),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Image.asset(
                      _statSns,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const Text(
                  '참여도\n높음',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          const Text(
            '소셜지수',
            style: TStyle.commonTitle,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            RString.social_index_desc,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xdd555555),
            ),
          ),
        ],
      ),
    );
  }

  //시세
  _setMarketConditionView() {
    return Container(
      child: Table(
        /*border: TableBorder.symmetric(
                      outside: BorderSide(color: Colors.redAccent, width: 1, style: BorderStyle.solid, strokeAlign: 10,),
                      inside:  BorderSide(color: Colors.blueAccent, width: 2, style: BorderStyle.solid, strokeAlign:5,),
                    ),*/
        children: List.generate(
          _listData.length + 1,
          (index) => _setTableRow(index),
        ),
      ),
    );
  }

  //시세
  _setTableRow(int row) {
    return TableRow(
      children: List.generate(
        3,
        (index) => _setTableView(row, index),
      ),
    );
  }

  //시세
  _setTableView(int row, int column) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 1,
          color: row == 0 ? RColor.bgTableTextGrey : RColor.lineGrey,
        ),
        row == 0
            ? Container(
                color: RColor.bgTableGrey,
                height: 32,
                alignment: Alignment.center,
                child: _setTitleView(column))
            : _setValueView(row - 1, column),
        Visibility(
          visible: _listData.length == row,
          child: Container(
            height: 1,
            color: RColor.bgTableTextGrey,
          ),
        ),
      ],
    );
  }

  _setTitleView(int column) {
    return Text(
      _listTitle[column],
      style: const TextStyle(
        fontSize: 16,
        color: RColor.bgTableTextGrey,
      ),
    );
  }

  _setValueView(int row, int column) {
    String value = '';
    if (column == 0) {
      value = _listData[row].td;
      return SizedBox(
        height: 50,
        child: Center(
          child: Text(
            TStyle.getDateDivFormat(value),
            style: const TextStyle(
              fontSize: 14,
              color: RColor.bgTableTextGrey,
            ),
          ),
        ),
      );
    } else if (column == 1) {
      if (_listData[row].cg == '1') {
        value = '조용조용';
      } else if (_listData[row].cg == '2') {
        value = '수군수군';
      } else if (_listData[row].cg == '3') {
        value = '왁자지껄';
      } else if (_listData[row].cg == '4') {
        value = '폭발';
      }
      return SizedBox(
        height: 50,
        child: Center(
          child: Text(value),
        ),
      );
    }
    /*else if(column == 2){
      value = _listData[row].ec;
      return SizedBox(height: 40, child: Center(child: Text(TStyle.getMoneyPoint(value),),),);
    }*/
    else if (column == 2) {
      value = _listData[row].tp;
      return SizedBox(
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              TStyle.getMoneyPoint(value),
              //style: TextStyle(color: TStyle.getMinusPlusColor(_listData[row].fr),),
            ),
            Text(
              '${_listData[row].fr}%',
              style: TextStyle(
                color: TStyle.getMinusPlusColor(_listData[row].fr),
              ),
            ),
          ],
        ),
      );
    }
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
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

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    if (trStr == TR.SNS06) {
      final TrSns06 resData = TrSns06.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        //_listData..addAll(resData.retData.listPriceChart);
        _statSns = resData.retData.concernGrade == '1'
            ? 'images/rassibs_cht_img_1_1.png'
            : resData.retData.concernGrade == '2'
                ? 'images/rassibs_cht_img_1_2.png'
                : resData.retData.concernGrade == '3'
                    ? 'images/rassibs_cht_img_1_3.png'
                    : resData.retData.concernGrade == '4'
                        ? 'images/rassibs_cht_img_1_4.png'
                        : 'images/rassibs_cht_img_1_1.png';

        _listData.addAll(
          List.from(
            resData.retData.listPriceChart.reversed,
          ),
        );
        _isNoData = 'N';
        setState(() {});
      } else {
        setState(() {
          _isNoData = 'Y';
        });
      }
    }
  }
}
