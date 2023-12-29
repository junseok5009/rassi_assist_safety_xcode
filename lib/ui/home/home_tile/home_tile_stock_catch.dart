import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/const.dart';
import '../../../common/d_log.dart';
import '../../../common/net.dart';
import '../../../common/tstyle.dart';
import '../../../common/ui_style.dart';
import '../../../models/none_tr/app_global.dart';
import '../../../models/tr_stk_catch03.dart';
import '../../common/common_popup.dart';
import '../../common/common_swiper_pagination.dart';
import '../../main/base_page.dart';

/// 라씨 매매비서가 캐치한 종목 (종목캐치)
class HomeTileStockCatch extends StatefulWidget {
  static const String TAG = "[HomeTileStockCatch]";
  const HomeTileStockCatch({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeTileStockCatchState();
}

class HomeTileStockCatchState extends State<HomeTileStockCatch>
    with AutomaticKeepAliveClientMixin<HomeTileStockCatch> {
  late SharedPreferences _prefs;
  final AppGlobal _appGlobal = AppGlobal();
  String _userId = '';

  final List<StkCatch03> _listCatch = [];     //종목캐치_외인기관
  final List<StkCatch03> _listCatchTop = [];  //종목캐치_성과TOP

  bool _isFirstBtn = true;

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

  void _requestTr() {
    _fetchPosts(
        TR.STKCATCH03,
        jsonEncode(<String, String>{
          'userId': _userId,
        }));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //없을 경우에는 ???

    return Column(
      children: [
        Container(
          color: RColor.new_basic_grey,
          height: 15.0,
        ),

        Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '라씨 매매비서가 캐치한 종목',
                style: TStyle.commonTitle,
              ),
              InkWell(
                onTap: () async {
                  DefaultTabController.of(context).animateTo(2);
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: const Text(
                  '더보기',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff999999),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20,),

        _setDivButtons(),

        //외국인, 기관 종목캐치
        Visibility(
          visible: _isFirstBtn,
          child: _listCatch.isNotEmpty
              ? TileStkCatch03N(_listCatch[0])
              : Container(),
        ),

        //성과TOP 종목캐치
        Visibility(
          visible: !_isFirstBtn,
          child: Container(
            width: double.infinity,
            height: 250,
            margin: const EdgeInsets.only(bottom: 10,),
            child: Swiper(
              controller: SwiperController(),
              pagination: CommonSwiperPagenation.getNormalSP(9.0),
              loop: false,
              autoplay: false,
              itemCount: _listCatchTop.length,
              itemBuilder: (BuildContext context, int index) {
                return TileStkCatch03N(_listCatchTop[index]);
              },
            ),
          ),
        ),

      ],
    );
  }

  //종목캐치 선택 버튼
  Widget _setDivButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: InkWell(
            child: Container(
              width: 180,
              height: 40,
              decoration: _isFirstBtn
                  ? UIStyle.boxRoundLine25c(Colors.black)
                  : UIStyle.boxRoundLine25c(RColor.new_basic_line_grey),
              padding: const EdgeInsets.symmetric(
                vertical: 4,
              ),
              alignment: Alignment.center,
              child: Text(
                '외국인/기관 종목캐치',
                style: TextStyle(
                  color: _isFirstBtn
                      ? Colors.black
                      : RColor.new_basic_text_color_strong_grey,
                  fontWeight: _isFirstBtn ? FontWeight.bold : FontWeight.w500,
                  fontSize: _isFirstBtn ? 15 : 14,
                ),
              ),
            ),
            onTap: () {
              setState(() {
                if(!_isFirstBtn) {
                  setState(() {
                    _isFirstBtn = true;
                  });
                }
              });
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: InkWell(
            child: Container(
              width: 180,
              height: 40,
              margin: const EdgeInsets.only(left: 15),
              decoration: _isFirstBtn
                  ? UIStyle.boxRoundLine25c(RColor.new_basic_line_grey)
                  : UIStyle.boxRoundLine25c(Colors.black),
              padding: const EdgeInsets.symmetric(
                vertical: 4,
              ),
              alignment: Alignment.center,
              child: Text(
                '성과 TOP 종목캐치',
                style: TextStyle(
                  color: _isFirstBtn
                      ? RColor.new_basic_text_color_strong_grey
                      : Colors.black,
                  fontWeight: _isFirstBtn ? FontWeight.w500 : FontWeight.bold,
                  fontSize: _isFirstBtn ? 14 : 15,
                ),
              ),
            ),
            onTap: () {
              if(_isFirstBtn) {
                setState(() {
                  _isFirstBtn = false;
                });
              }
            },
          ),
        ),
      ],
    );
  }


  Future<void> _fetchPosts(String trStr, String json) async {
    DLog.d(HomeTileStockCatch.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);

    } on TimeoutException catch (_) {
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup().showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    //이 시간 종목캐치
    if (trStr == TR.STKCATCH03) {
      _listCatch.clear();
      _listCatchTop.clear();

      final TrStkCatch03 resData = TrStkCatch03.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        if (resData.retData.isNotEmpty) {
          List<StkCatch03> rtList = resData.retData;
          for(StkCatch03 tmp in rtList) {
            if(tmp.contentDiv == 'BIG') {
              _listCatch.add(tmp);
            } else {
              _listCatchTop.add(tmp);
            }
          }
          setState(() {});
        }
      }
    }
  }

}


//화면구성 NEW - 홈_홈 매매비서가 캐치한 종목
class TileStkCatch03N extends StatelessWidget {
  final StkCatch03 catch03;
  const TileStkCatch03N(this.catch03, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.all(10),
      child: _setThemeBox(
        catch03.stkList[0],
        catch03.stkList.length > 1 ? catch03.stkList[1] : null,
      ),
    );
  }

  Widget _setThemeBox(StockDiv item1, StockDiv? item2,) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Column(
        children: [
          if (item1 != null) _setInfoBox(item1, true),
          item2 != null ? _setInfoBox(item2, false) : _setEmptyBox(),
        ],
      ),
    );
  }

  Widget _setEmptyBox() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
        child: Container(
          padding: const EdgeInsets.all(5.0),
          child: const Center(
            child: Text(
              '발생한 종목이 없습니다.',
              style: TStyle.textGreyDefault,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _setInfoBox(StockDiv tItem, bool bImg) {
    return Container(
      width: double.infinity,
      height: 80,
      margin: const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 5),
      decoration: UIStyle.boxWithOpacityNew(),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          padding: const EdgeInsets.all(9.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _setCardIcons(tItem.selectDiv, bImg),
                  const SizedBox(width: 10,),
                  _setDivInfo(tItem.stockName, tItem.selectDiv, tItem.tradeFlag),
                ],
              ),

              _setStockInfo(tItem),
            ],
          ),
        ),
        onTap: () {
          basePageState.goStockHomePage(
            tItem.stockCode,
            tItem.stockName,
            Const.STK_INDEX_SIGNAL,
          );
        },
      ),
    );
  }

  Widget _setStockInfo(StockDiv item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          TStyle.getLimitString(item.stockName, 10),
          style: TStyle.defaultContent,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          item.stockCode,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xff999999),
          ),
        ),
      ],
    );
  }


  Widget _setDivInfo(String stkName, String div, String flag) {
    String fText = '';
    Color fColor;
    if (flag == 'B') {
      fText = '매수';
      fColor = RColor.sigBuy;
    } else {
      fText = '매도';
      fColor = RColor.sigSell;
    }

    if (div == 'FRN') {
      return _setDescText(
        '외국인과 라씨 매매비서가',
        '함께 ',
        fText,
        fColor,
      );
    } else if (div == 'ORG') {
      return _setDescText(
        '기관과 라씨 매매비서가',
        '함께 ',
        fText,
        fColor,
      );
    } else if (div == 'AVG') {
      return _setDescText(
        '적중률과 평균 수익률이',
        '모두 높은 종목 중 ',
        fText,
        fColor,
      );
    } else if (div == 'SUM') {
      return _setDescText(
        '적중률과 누적 수익률이',
        '모두 높은 종목 중 ',
        fText,
        fColor,
      );
    } else if (div == 'WIN') {
      return _setDescText(
        '적중률과 수익난 매매횟수가',
        '모두 높은 종목 중 ',
        fText,
        fColor,
      );
    }

    return const Text('');
  }

  Widget _setDescText(String txt1, String txt2, String fText, Color bsColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(txt1,
          style: TStyle.content,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(txt2,
              style: TStyle.content,),
            Text(fText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: bsColor,
              ),),
            const Text('한 종목',
              style: TStyle.content,)
          ],
        )
      ],
    );
  }


  Widget _setCardIcons(String div, bool bImg) {
    if (div == 'FRN') {
      return Image.asset(
        'images/img_foreigner_b.png',
        fit: BoxFit.cover,
        scale: 4,
      );
    } else if (div == 'ORG') {
      return Image.asset(
        'images/img_inst.png',
        fit: BoxFit.cover,
        scale: 4,
      );
    } else if (div == 'AVG') {
      return Image.asset(
        bImg ? 'images/main_hnr_avg_ratio.png' : 'images/main_hnr_win_ratio.png',
        fit: BoxFit.cover,
        scale: 7,
      );
    } else if (div == 'SUM') {
      return Image.asset(
        bImg ? 'images/main_hnr_acc_ratio.png' : 'images/main_hnr_win_ratio.png',
        fit: BoxFit.cover,
        scale: 7,
      );
    } else if (div == 'WIN') {
      return Image.asset(
        bImg ? 'images/main_hnr_win_trade.png' : 'images/main_hnr_win_ratio.png',
        fit: BoxFit.cover,
        scale: 7,
      );
    }

    return const Text('');
  }
}
