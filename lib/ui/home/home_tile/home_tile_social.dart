import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/const.dart';
import '../../../common/d_log.dart';
import '../../../common/net.dart';
import '../../../common/tstyle.dart';
import '../../../common/ui_style.dart';
import '../../../models/none_tr/app_global.dart';
import '../../../models/pg_data.dart';
import '../../../models/tr_sns07.dart';
import '../../common/common_popup.dart';
import '../../common/common_view.dart';
import '../../main/base_page.dart';
import '../../sub/social_list_page.dart';

/// 커뮤니티 활동 급상승(소셜지수)
class HomeTileSocial extends StatefulWidget {
  const HomeTileSocial({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => HomeTileSocialState();
}

class HomeTileSocialState extends State<HomeTileSocial>
    with AutomaticKeepAliveClientMixin<HomeTileSocial> {
  final AppGlobal _appGlobal = AppGlobal();
  late SharedPreferences _prefs;
  String _userId = '';

  final List<Sns07Elapsed> _timelineList = [];
  final List<SnsStock> _socialList = [];
  var _agoText = '';
  var _currentSliderValue = 0.0;
  var _alignVal = 0.0;
  var _isGen = false;

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? _appGlobal.userId;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPrefData().then((_) {
      _requestTr();
    });
  }

  @override
  void setState(VoidCallback fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  void _requestTr() {
    _fetchPosts(
        TR.SNS07,
        jsonEncode(<String, String>{
          'userId': _userId,
        }));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20),
          color: const Color(
            0xffF5F5F5,
          ),
          height: 13,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            _setSubTitle('커뮤니티 활동 급상승'),
            Container(
              margin: const EdgeInsets.only(right: 20),
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: const Text(
                  '더보기',
                  style: TextStyle(
                    color: RColor.greyMore_999999,
                  ),
                ),
                onTap: () async {
                  Navigator.pushNamed(context, SocialListPage.routeName,
                      arguments: PgData(pgSn: ''));
                },
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),

        // 시간 전 슬라이더
        Stack(
          children: [
            _setTimeAgoSlider(context, _timelineList),

            /* IgnorePointer(
          child: */
            Align(
              alignment: Alignment(_alignVal, 0.0),
              child: Visibility(
                visible: _isGen,
                child: Container(
                  width: 70,
                  height: 35,
                  margin: const EdgeInsets.only(
                    top: 7,
                    left: 20,
                    right: 20,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: UIStyle.boxRoundFullColor16c(
                    RColor.mainColor,
                  ),
                  child: Text(
                    _agoText,
                    style: const TextStyle(
                      // fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            // ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),

        // 종목 리스트
        _socialList.isNotEmpty
            ? SizedBox(
                height: 90,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.zero,
                  itemCount: _socialList.length,
                  itemBuilder: (context, index) {
                    return TileSns03N(_socialList[index], index);
                  },
                ),
              )
            : CommonView.setNoDataTextView(
                130, '현재 커뮤니티 활동이\n평소보다 급상승한 종목이 없습니다.'),
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }

  Widget _setTimeAgoSlider(BuildContext context, List<Sns07Elapsed> timelineList) {
    return Stack(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 9.0,
            activeTrackColor: RColor.yonbora,
            inactiveTrackColor: RColor.greySliderBar_ebebeb,
            inactiveTickMarkColor: Colors.transparent,
            // trackShape: const RoundedRectSliderTrackShape(),
            // overlayShape: RoundSliderOverlayShape(overlayRadius: 32.0),
            // valueIndicatorShape: PaddleSliderValueIndicatorShape(),
            thumbColor: Colors.transparent,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0.0,),
          ),
          child: Slider(
            value: _currentSliderValue,
            min: 0.0,
            max: 3.0,
            divisions: 3,
            onChanged: (double value) {
              _setSliderValue(value);
            },
          ),
        ),
      ],
    );
  }

  _setSliderValue(double value) {
    // DLog.w('####Value:  $value | $_isGen | $_alignVal');
    if(_timelineList.isNotEmpty) {
      if(_timelineList.length <= value.round()){
        return;
      }

      _currentSliderValue = value;
      _socialList.clear();
      if(_timelineList[value.round()] != null) {
        _socialList.addAll(_timelineList[value.round()].listData);
        _agoText = _timelineList[value.round()].elapsedTmTx;
      }
      if (value == 0.0) {
        _alignVal = -1.0;
        _isGen = true;
      } else if (value == 1.0) {
        _alignVal = -0.33;
        _isGen = true;
      } else if (value == 2.0) {
        _alignVal = 0.33;
        _isGen = true;
      } else if (value == 3.0) {
        _alignVal = 1.0;
        _isGen = true;
      } else {
      }
      setState(() {});
    }
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
      child: Text(
        subTitle,
        style: TStyle.title18T,
      ),
    );
  }

  Future<void> _fetchPosts(String trStr, String json) async {
    DLog.w('$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
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
    if (trStr == TR.SNS07) {
      _timelineList.clear();
      final TrSns07 resData = TrSns07.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData != null) {
          var timeList = resData.retData.listTimeline;
          if(timeList.isNotEmpty){
            _timelineList.addAll(List.from(timeList.reversed));
            _setSliderValue(timeList.length.toDouble() - 1.0);
          }
          setState(() {});
        }
      }
    }
  }
}


//화면구성
class TileSns03N extends StatelessWidget {
  final SnsStock item;
  final int index;

  const TileSns03N(this.item, this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // height: 70,
      margin: EdgeInsets.only(
        top: index == 0 ? 0 : 10,
        left: 20,
        right: 20,
      ),
      alignment: Alignment.centerLeft,
      child: InkWell(
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    item.stockName,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  Text(
                    item.stockCode,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xff999999),
                    ),
                  ),
                ],
              ),
              Text(
                TStyle.getPercentString(item.fluctuationRate),
                style: TextStyle(
                  fontSize: 16,
                  color: TStyle.getMinusPlusColor(item.fluctuationRate),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          // 종목홈
          basePageState.goStockHomePage(
            item.stockCode,
            item.stockName,
            Const.STK_INDEX_HOME,
          );
        },
      ),
    );
  }
}
