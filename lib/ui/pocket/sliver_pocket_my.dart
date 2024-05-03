import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/pocket.dart';
import 'package:rassi_assist/provider/pocket_provider.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/common/common_layer.dart';
import 'package:rassi_assist/ui/main/search_page.dart';
import 'package:rassi_assist/ui/pocket/pocket_setting_page.dart';
import 'package:rassi_assist/ui/pocket/pocket_three_stock_setting_page.dart';

import '../../common/const.dart';
import '../../common/d_log.dart';
import '../../common/net.dart';
import '../../common/tstyle.dart';
import '../../common/ui_style.dart';
import '../../models/none_tr/app_global.dart';
import '../../models/tr_pock/tr_pock08.dart';
import '../common/common_popup.dart';
import '../main/base_page.dart';

/// 2023.10
/// 포켓_나의포켓
class SliverPocketMyWidget extends StatefulWidget {
  static const routeName = '/page_pocket_my_sliver';
  static const String TAG = "[SliverPocketMyWidget] ";
  static const String TAG_NAME = '포켓_나의포켓';
  static final GlobalKey<SliverPocketMyWidgetState> globalKey = GlobalKey();

  SliverPocketMyWidget({Key? key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() => SliverPocketMyWidgetState();
}

//현재가 기준시간 표시 (전문 필요)
//랜딩으로 들어올 경우 특정 포켓으로 이동
class SliverPocketMyWidgetState extends State<SliverPocketMyWidget> {
  final AppGlobal _appGlobal = AppGlobal();

  late Pocket _pocket; // 현재 선택된 포켓
  late PocketProvider _pocketProvider;
  int _pocketListLength = 0; // 포켓 수정,삭제 등 모든 변화에 noti로 받는데, 새로 포켓설정으로 새로 만들었을 경우 새로 만든 포켓으로 셋팅

  final List<PocketSignalStock> _stkList = []; //종목리스트

  String _timeInfo = '';
  bool _beforeOpening = false; // 08 ~ 09 Y
  bool _beforeChart = false; // 09 ~ 09 : 20 Y
  bool _isSignalInfo = false; // true : 매매신호, false : 현재가
  bool _isFaVisible = true;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(SliverPocketMyWidget.TAG_NAME);
    CustomFirebaseClass.logEvtMyPocketView(SliverPocketMyWidget.TAG_NAME);
    _pocketProvider = Provider.of<PocketProvider>(context, listen: false);
    _pocketProvider.addListener(reload);
    if (_appGlobal.pocketSn.isNotEmpty) {
      int tmpIdx = _pocketProvider.getPocketListIndexByPocketSn(_appGlobal.pocketSn);
      _pocket = _pocketProvider.getPocketList[tmpIdx];
      _appGlobal.pocketSn = '';
    } else {
      _pocket = _pocketProvider.getPocketList[0];
    }
    _pocketListLength = _pocketProvider.getPocketList.length;
    _isSignalInfo = _appGlobal.isSignalInfo;
    reload();
  }

  @override
  void dispose() {
    _pocketProvider.removeListener(reload);
    _appGlobal.isSignalInfo = false;
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        if (notification.direction == ScrollDirection.forward && !_isFaVisible) {
          setState(() {
            _isFaVisible = true;
          });
        } else if (notification.direction == ScrollDirection.reverse && _isFaVisible) {
          setState(() {
            _isFaVisible = false;
          });
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: RColor.bgBasic_fdfdfd,
        body: CustomScrollView(
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                margin: const EdgeInsets.only(
                  top: 5,
                ),
                color: RColor.bgBasic_fdfdfd,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //포켓 교체 드롭다운
                    _setDropdownView(),
                    const SizedBox(
                      width: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isSignalInfo)
                          Text(
                            _timeInfo,
                            style: const TextStyle(
                              fontSize: 12,
                              color: RColor.greyMore_999999,
                            ),
                          ),

                        const SizedBox(
                          width: 10,
                        ),
                        // 현재가 / 매매신호
                        InkWell(
                          child: Row(
                            children: [
                              _isSignalInfo
                                  ? Row(
                                      children: [
                                        Image.asset(
                                          'images/icon_pocket_my_select_dn.png',
                                          height: 16,
                                        ),
                                        const Text(
                                          ' 매매신호 ',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: RColor.greyBasicStrong_666666,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Image.asset(
                                          'images/icon_pocket_my_select_up.png',
                                          height: 16,
                                        ),
                                        const Text(
                                          ' 현재가 ',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: RColor.greyBasicStrong_666666,
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _isSignalInfo = !_isSignalInfo;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              child: Stack(
                children: [
                  Provider.of<UserInfoProvider>(context, listen: false).is3StockUser()
                      ? _set3StockUserListWidget()
                      : _setStockListWidget(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      //height: _isFaVisible ? 50 : 0,
                      height: 50,
                      //duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      //color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                var result = await CommonLayer.instance.showLayerMyPocket(
                                  context,
                                  _pocket.pktSn,
                                );
                                if (context.mounted) {
                                  if (result == CustomNvRouteResult.landPremiumPopup) {
                                    String result = await CommonPopup.instance.showDialogPremium(context);
                                    if (result == CustomNvRouteResult.landPremiumPage) {
                                      basePageState.navigateAndGetResultPayPremiumPage();
                                    }
                                  } else if (result == CustomNvRouteResult.landing) {
                                    Future.delayed(const Duration(milliseconds: 300), () async {
                                      // 포켓 설정
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const PocketSettingPage(),
                                        ),
                                      );
                                    });
                                  } else if (result == CustomNvRouteResult.cancel) {
                                    reload();
                                  } else {
                                    int resultPktIndex = _pocketProvider.getPocketListIndexByPocketSn(result);
                                    if (resultPktIndex != -1) {
                                      _pocket = _pocketProvider.getPocketList[resultPktIndex];
                                      reload(changePocketSn: _pocket.pktSn);
                                    } else {
                                      reload();
                                    }
                                  }
                                }
                              },
                              child: Container(
                                decoration: UIStyle.boxRoundLine6bgColor(
                                  RColor.bgBasic_fdfdfd,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'images/icon_arrow_down.png',
                                      height: 8,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text('이동'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                // 포켓 설정
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PocketSettingPage(),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: UIStyle.boxRoundLine6bgColor(
                                  RColor.bgBasic_fdfdfd,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'images/icon_setting_black.png',
                                      height: 16,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text('설정'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                basePageState.callPageRouteUP(
                                  SearchPage(landWhere: SearchPage.addPocketLayer, pocketSn: _pocket.pktSn,),
                                );
                              },
                              child: Container(
                                decoration: UIStyle.boxRoundLine6bgColor(
                                  RColor.bgBasic_fdfdfd,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'images/icon_add_circle_black.png',
                                      height: 16,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text(
                                      '추가',
                                      style: TextStyle(
                                          //fontSize: 14,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _set3StockUserListWidget() {
    return NestedScrollView(
      floatHeaderSlivers: true,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          floating: true,
          snap: true,
          toolbarHeight: 46,
          backgroundColor: Colors.transparent,
          flexibleSpace: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              // 3종목 알림 설정
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PocketThreeStockSettingPage(),
                ),
              );
            },
            child: Container(
              height: 38,
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration: UIStyle.boxRoundFullColor8c(
                RColor.greyBox_f5f5f5,
              ),
              child: Row(
                children: [
                  Image.asset(
                    'images/icon_change_circle_black.png',
                    height: 18,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Flexible(
                    child: Text(
                      'AI매매신호를 이용할 3종목을 변경하고 싶다면?',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      body: _setStockListWidget(),
    );
  }

  Widget _setStockListWidget() {
    if (_stkList.isEmpty) {
      return _setEmptyView();
    }
    return ListView.builder(
      physics: const RangeMaintainingScrollPhysics(),
      itemCount: _stkList.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: EdgeInsets.fromLTRB(20, index == 0 ? 5 : 15, 20, index == _stkList.length - 1 ? 75 : 0),
          child: Ink(
            width: double.infinity,
            decoration: UIStyle.boxShadowBasic(16),
            child: InkWell(
              highlightColor: Colors.black.withOpacity(0.05),
              splashColor: Colors.black.withOpacity(0.07),
              borderRadius: const BorderRadius.all(
                Radius.circular(16),
              ),
              child: Container(
                height: 86,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //종목명, 종목코드
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _stkList[index].stockName,
                            style: TStyle.commonTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            _stkList[index].stockCode,
                            style: const TextStyle(
                              fontSize: 12,
                              color: RColor.greyBasic_8c8c8c,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    if (_isSignalInfo)
                      if (Provider.of<UserInfoProvider>(context, listen: false).isPremiumUser())
                        _setRateCircleText(_stkList[index])
                      else if (Provider.of<UserInfoProvider>(context, listen: false).is3StockUser() &&
                          _stkList[index].signalYn == 'Y')
                        _setRateCircleText(_stkList[index])
                      else
                        _setNoPremiumBlockView()
                    else if (_beforeOpening)
                      _setBeforeOpening(_stkList[index])
                    else if (_beforeChart)
                      _setBeforeChart(_stkList[index])
                    else
                      _setStockInfoText(_stkList[index]),
                  ],
                ),
              ),
              onTap: () async {
                if (_stkList[index].tradingHaltYn != 'T') {
                  basePageState.goStockHomePage(
                    _stkList[index].stockCode,
                    _stkList[index].stockName,
                    _isSignalInfo ? Const.STK_INDEX_SIGNAL : Const.STK_INDEX_HOME,
                  );
                }
              },
              onLongPress: () async {
                if (!_isSignalInfo) {
                  String result =
                      await CommonPopup.instance.showDialogCustomConfirm(context, '알림', '선택하신 종목을\n삭제하시겠습니까?', '삭제하기');
                  if (result == CustomNvRouteResult.landing && context.mounted) {
                    String result = await Provider.of<PocketProvider>(context, listen: false).deleteStock(
                      Stock(
                        stockName: _stkList[index].stockName,
                        stockCode: _stkList[index].stockCode,
                      ),
                      _pocket.pktSn,
                    );
                    if (context.mounted) {
                      if (result == CustomNvRouteResult.refresh) {
                        /*Provider.of<StockInfoProvider>(context, listen: false)
                            .postRequest(stkCode);*/
                      } else if (result == CustomNvRouteResult.fail) {
                        CommonPopup.instance.showDialogBasic(context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
                      } else {
                        CommonPopup.instance.showDialogBasic(context, '안내', result);
                      }
                    }
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  //현재가(20분 지연), 등락금액, 등락률
  Widget _setStockInfoText(PocketSignalStock item) {
    if (item.tradingHaltYn == 'T') {
      return _setDelist();
    } else if (item.tradingHaltYn == 'Y') {
      item.fluctuationAmt = '0';
      item.fluctuationRate = '0.00';
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            //현재가
            Text(
              TStyle.getMoneyPoint(item.currentPrice),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            //등락금액
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'NotoSansKR',
                ),
                children: [
                  TextSpan(
                    text: item.fluctuationAmt.contains('-')
                        ? '▼ '
                        : (double.tryParse(item.fluctuationAmt) ?? 0) == 0
                            ? '- '
                            : '▲ ',
                    style: TextStyle(
                      color: TStyle.getMinusPlusColor(item.fluctuationAmt),
                      fontSize: (double.tryParse(item.fluctuationAmt) ?? 0) == 0 ? 16 : 10,
                      //fontFamily: 'NotoSansKR',
                    ),
                  ),
                  TextSpan(
                    text: item.fluctuationAmt.contains('-')
                        ? TStyle.getMoneyPoint(item.fluctuationAmt.substring(1))
                        : TStyle.getMoneyPoint(item.fluctuationAmt),
                    style: TextStyle(
                      color: TStyle.getMinusPlusColor(item.fluctuationAmt),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Visibility(
              visible: item.tradingHaltYn == 'Y',
              child: const Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Text(
                  '거래정지',
                  style: TextStyle(
                    fontSize: 12,
                    color: RColor.greyMore_999999,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 2,
              ),
              decoration: UIStyle.boxRoundFullColor6c(
                TStyle.getMinusPlusColorBox(item.fluctuationRate),
              ),
              child: Text(
                TStyle.getPercentString(item.fluctuationRate),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: TStyle.getIsZeroBlackNotWhite(item.fluctuationRate),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 관망중 / 보유중
  Widget _setRateCircleText(PocketSignalStock item) {
    if (item.tradingHaltYn == 'T') {
      return _setDelist();
    }
    String statTxt = '';
    String typeText = '';
    Color statColor = RColor.sigWatching;
    Color rateColor;
    String rateText;
    bool isToday = false;

    if (item.tradeFlag == 'B') {
      statTxt = '오늘\n매수';
      statColor = RColor.sigBuy;
      isToday = true;
    } else if (item.tradeFlag == 'S') {
      statTxt = '오늘\n매도';
      statColor = RColor.sigSell;
      isToday = true;
    } else if (item.tradeFlag == 'H') {
      statTxt = '보유중';
      typeText = '보유';
      statColor = RColor.sigHolding;
    } else if (item.tradeFlag == 'W') {
      statTxt = '관망중';
      typeText = '관망';
      statColor = RColor.sigWatching;
    }

    if (item.profitRate.contains('-')) {
      rateText = item.profitRate;
      rateColor = RColor.bgSell;
    } else {
      rateText = '+${item.profitRate}';
      rateColor = RColor.bgBuy;
    }

    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            //오늘 매수/매도 시간 & 가격
            Visibility(
              visible: isToday,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${TStyle.getDtTimeFormat(item.tradeDttm)} ',
                    style: const TextStyle(
                      color: RColor.greyBasicStrong_666666,
                    ),
                  ),
                  Text(
                    '${TStyle.getMoneyPoint(item.tradePrice)} ',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            //보유/관망 몇일째
            Visibility(
              visible: !isToday,
              child: Text(
                '$typeText ${item.elapsedDays}일째 ',
                style: const TextStyle(
                  color: RColor.greyBasicStrong_666666,
                ),
              ),
            ),

            //수익률
            Visibility(
              visible: item.tradeFlag != 'W', //관망이 아닐때만 보여줌
              child: Row(
                children: [
                  Visibility(
                    visible: item.tradeFlag != 'S',
                    child: const Text(
                      '수익률',
                      style: TextStyle(
                        color: RColor.greyBasicStrong_666666,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    '$rateText%',
                    style: TextStyle(
                      color: rateColor,
                    ),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  Visibility(
                    visible: item.tradeFlag == 'S',
                    child: Text(
                      '${item.termOfTrade}일보유',
                      style: const TextStyle(
                        color: RColor.greyBasicStrong_666666,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(
          width: 7,
        ),

        // Circle
        Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            color: statColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              statTxt,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              // style: theme.textTheme.body.apply(color: textColor),
            ),
          ),
        )
      ],
    );
  }

  // 프리미엄 아닐때 매매신호 리스트 아이템들
  _setNoPremiumBlockView() {
    return InkWell(
      onTap: () async {
        String result = await CommonPopup.instance.showDialogPremium(context);
        if (result == CustomNvRouteResult.landPremiumPage) {
          basePageState.navigateAndGetResultPayPremiumPage();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Image.asset(
            'images/icon_lock_grey.png',
            height: 16,
          ),
          const Text(
            '프리미엄으로 업그레이드하시고\n지금 바로 확인해 보세요',
            style: TextStyle(
              fontSize: 12,
              color: RColor.greyMore_999999,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }

  // 리스트 없는 경우
  _setEmptyView() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: UIStyle.boxShadowBasic(16),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          padding: const EdgeInsets.all(
            30,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/icon_folder_plus.png',
                fit: BoxFit.cover,
                height: 30,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                '나의 포켓에 종목을 추가해 보세요.\n라씨 매매비서가 관리해 드립니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: RColor.greyMore_999999,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: UIStyle.boxRoundLine25c(Colors.black54),
                  child: const Text(
                    '+ 종목추가',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
                onTap: () async {
                  basePageState.callPageRouteUP(
                    SearchPage(landWhere: SearchPage.addPocketLayer,pocketSn: _pocket.pktSn,),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  //장 시작 전 입니다.
  _setBeforeOpening(PocketSignalStock item) {
    return Expanded(
      child: InkWell(
        onTap: () {
          basePageState.goStockHomePage(
            item.stockCode,
            item.stockName,
            Const.STK_INDEX_HOME,
          );
        },
        child: const Wrap(
          alignment: WrapAlignment.end,
          //crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '장 시작 전 입니다.',
              style: TextStyle(
                fontSize: 12,
                color: RColor.greyMore_999999,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }

  // 09:00 ~ 09:20 곧 업데이트 됩니다.
  _setBeforeChart(PocketSignalStock item) {
    return Expanded(
      child: InkWell(
        onTap: () {
          basePageState.goStockHomePage(
            item.stockCode,
            item.stockName,
            Const.STK_INDEX_HOME,
          );
        },
        child: const Wrap(
          alignment: WrapAlignment.end,
          //crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '20분부터 업데이트 됩니다.\n(20분 지연)',
              style: TextStyle(
                fontSize: 12,
                color: RColor.greyMore_999999,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }

  // 상장 폐지 종목
  _setDelist() {
    return const Expanded(
      child: Wrap(
        alignment: WrapAlignment.end,
        //crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '상장폐지된 종목입니다.',
            style: TextStyle(
              fontSize: 12,
              color: RColor.greyMore_999999,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }

  //드롭박스 메뉴
  Widget _setDropdownView() {
    return Flexible(
      //fit: FlexFit.tight,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          var result = await CommonLayer.instance.showLayerMyPocket(
            context,
            _pocket.pktSn,
          );
          if (mounted) {
            if (result == CustomNvRouteResult.landPremiumPopup) {
              String result = await CommonPopup.instance.showDialogPremium(context);
              if (result == CustomNvRouteResult.landPremiumPage) {
                basePageState.navigateAndGetResultPayPremiumPage();
              }
            } else if (result == CustomNvRouteResult.landing) {
              Future.delayed(const Duration(milliseconds: 300), () async {
                // 포켓 설정
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PocketSettingPage(),
                  ),
                );
              });
            } else if (result == CustomNvRouteResult.cancel) {
              reload();
            } else {
              int resultPktIndex = _pocketProvider.getPocketListIndexByPocketSn(result);
              if (resultPktIndex != -1) {
                _pocket = _pocketProvider.getPocketList[resultPktIndex];
                reload(changePocketSn: _pocket.pktSn);
              } else {
                reload();
              }
            }
          }
        },
        child: Container(
          decoration: UIStyle.boxRoundLine6(),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _pocket.pktName,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Image.asset(
                'images/icon_arrow_down.png',
                height: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> reload({String changePocketSn = ''}) async {
    if (changePocketSn.isNotEmpty) {
      _pocket = _pocketProvider.getPocketByPocketSn(changePocketSn);
    } else if (_pocketProvider.getPocketListIndexByPocketSn(_pocket.pktSn) == -1) {
      _pocket = _pocketProvider.getPocketList[0];
    } else if (_pocketListLength < _pocketProvider.getPocketList.length) {
      // 포켓을 새로 만든 경우
      _pocket = _pocketProvider.getPocketList.last;
    }
    _pocketListLength = _pocketProvider.getPocketList.length;
    bool result = await _fetchPosts(
        TR.POCK08,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
          'pocketSn': _pocket.pktSn,
        }));
    return result;
  }

  Future<bool> _fetchPosts(String trStr, String json) async {
    DLog.d(SliverPocketMyWidget.TAG, '$trStr $json');

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
      return true;
    } on TimeoutException catch (_) {
      DLog.d(SliverPocketMyWidget.TAG, 'ERR : TimeoutException (12 seconds)');
      CommonPopup.instance.showDialogNetErr(context);
      return false;
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.d(SliverPocketMyWidget.TAG, response.body);
    if (trStr == TR.POCK08) {
      final TrPock08 resData = TrPock08.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Pock08 pock08 = resData.retData;
        _stkList.clear();
        _stkList.addAll(pock08.stkList);
        _timeInfo =
            '${TStyle.getDateDivFormat(pock08.tradeDate)} ${TStyle.getTimeFormat(pock08.tradeTime)} ${pock08.timeDivTxt}';
        _beforeOpening = pock08.beforeOpening == 'Y';
        _beforeChart = pock08.beforeChart == 'Y';
        if (_beforeOpening || _beforeChart) {
          _timeInfo = '';
        }
        _isFaVisible = true;
        setState(() {});
      }
    }
  }
}
