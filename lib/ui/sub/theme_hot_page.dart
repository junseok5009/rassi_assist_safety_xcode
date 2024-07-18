import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/theme_top_data.dart';
import 'package:rassi_assist/models/tr_theme/tr_theme02.dart';
import 'package:rassi_assist/models/tr_theme/tr_theme03.dart';
import 'package:rassi_assist/ui/common/common_date_picker.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_swiper_pagination.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/common_appbar.dart';

/// 2022.04.22
/// 핫테마 전체보기
class ThemeHotPage extends StatefulWidget {
  static const routeName = '/page_theme_hot';
  static const String TAG = "[ThemeHotPage]";
  static const String TAG_NAME = '핫테마_전체보기';

  const ThemeHotPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ThemeHotPageState();
}

class ThemeHotPageState extends State<ThemeHotPage> {
  late SharedPreferences _prefs;
  String _userId = "";

  final SwiperController _swiperWController = SwiperController();
  final List<ThemeTopData> _tmList = []; //위클리 HOT3
  String _startDate = '';
  String _endDate = '';

  final List<Theme03> _dataList = []; //데일리 HOT3
  DateTime _dateTime = DateTime.now();
  final _dateFormat = DateFormat('yyyyMM');

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      ThemeHotPage.TAG_NAME,
    );
    _loadPrefData().then(
      (_) => _fetchPosts(
        TR.THEME02,
        jsonEncode(
          <String, String>{
            'userId': _userId,
            'selectCount': '3',
          },
        ),
      ),
    );
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  void _requestTrTheme03() {
    _fetchPosts(
        TR.THEME03,
        jsonEncode(<String, String>{
          'userId': _userId,
          'selectMonth': _dateFormat.format(_dateTime),
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: '핫테마 전체 보기',
        elevation: 1,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  _setSubTitle('주간 테마 TOP3'),
                  Visibility(
                    visible: _tmList.isNotEmpty,
                    child: Text(
                      '${TStyle.getDateDivFormat(_startDate)}~'
                      '${TStyle.getDateDivFormat(_endDate)} 누적상승률',
                      style: TStyle.textGrey14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _tmList.isEmpty
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: CommonView.setNoDataView(170, '주간 테마 TOP3 데이터가 없습니다.'),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 290,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Swiper(
                          controller: _swiperWController,
                          pagination: _tmList.length < 2 ? null : CommonSwiperPagenation.getNormalSP(8),
                          itemCount: _tmList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return TileTheme02(_tmList[index], '${index + 1}');
                          },
                        ),

                        //좌우 스크롤 Arrow
/*                        Container(
                          width: double.infinity,
                          height: 230,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Image.asset(
                                  'images/main_jm_aw_l_g.png',
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _swiperWController.previous(animation: true);
                                },
                              ),
                              IconButton(
                                icon: Image.asset(
                                  'images/main_jm_aw_r_g.png',
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _swiperWController.next(animation: true);
                                },
                              ),
                            ],
                          ),
                        ),*/
                      ],
                    ),
                  ),
            const SizedBox(height: 20),

            //일간 테마 TOP3
            _setDailyHeader(),

            _dataList.isEmpty
                ? Container(
                    margin: const EdgeInsets.all(15),
                    child: CommonView.setNoDataView(170, '일간 테마 TOP3 데이터가 없습니다.'),
                  )
                : Column(
                    children: [
                      //테마리스트
                      ListView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        itemCount: _dataList.length,
                        itemBuilder: (context, index) {
                          if(_dataList[index].listData.isEmpty){
                            return const SizedBox();
                          }else{
                            return TileTheme03(_dataList[index]);
                          }
                        },
                      ),

                      const SizedBox(height: 15),
                      const Padding(
                        padding: EdgeInsets.only(left: 15.0, bottom: 15.0),
                        child: Text(
                          '※상승률은 해당 일자의 상승률입니다.',
                          style: TStyle.textGreyDefault,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  //일간 테마 TOP3
  Widget _setDailyHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '일간 테마 TOP3',
            style: TStyle.title18T,
          ),
          CommonView.setCalendarPickerBtnView(
            TStyle.getDateLongYmKorFormat(_dateFormat.format(_dateTime)),
            () async {
              await CommonDatePicker.showYearMonthPicker(context, _dateTime).then((value) {
                if(value!=null){
                  _dateTime = value;
                  _requestTrTheme03();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 5),
      child: Text(
        subTitle,
        style: TStyle.title18T,
      ),
    );
  }

  //2024/05
  String getDateYmFormat(String date) {
    String rtStr = '';
    if (date.length > 5) {
      rtStr = '${date.substring(0, 4)}/${date.substring(4, 6)}';
      return rtStr;
    }
    return '';
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(ThemeHotPage.TAG, '$trStr $json');

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
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(ThemeHotPage.TAG, response.body);

    // 주간 HOT3 테마
    if (trStr == TR.THEME02) {
      final TrTheme02 resData = TrTheme02.fromJson(jsonDecode(response.body));
      _tmList.clear();
      if (resData.retCode == RT.SUCCESS) {
        _tmList.addAll(resData.retData.listData);
        _startDate = resData.retData.startDate;
        _endDate = resData.retData.endDate;
      }
      setState(() {});

      _fetchPosts(
          TR.THEME03,
          jsonEncode(<String, String>{
            'userId': _userId,
            'selectMonth': '',
          }));
    }

    // 월간 테마 리스트 조회
    else if (trStr == TR.THEME03) {
      final TrTheme03 resData = TrTheme03.fromJson(jsonDecode(response.body));
      _dataList.clear();
      if (resData.retCode == RT.SUCCESS && resData.retData.isNotEmpty) {
        _dataList.addAll(resData.retData);
      }
      setState(() {});
    }
  }
}
