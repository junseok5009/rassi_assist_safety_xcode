import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/provider/signal_provider.dart';
import 'package:rassi_assist/ui/common/common_view.dart';
import 'package:rassi_assist/ui/main/search_page.dart';

import '../../common/const.dart';
import '../../common/tstyle.dart';
import '../../common/ui_style.dart';
import '../../models/stock_pkt_signal.dart';
import '../common/common_layer.dart';
import '../common/common_popup.dart';
import '../main/base_page.dart';

/// 2023.10
/// 포켓_나만의신호
class SliverPocketSignalWidget extends StatefulWidget {
  static const routeName = '/page_pocket_signal_sliver';
  static const String TAG = "[SliverPocketSignalWidget] ";
  static const String TAG_NAME = '포켓_나만의신호';
  static final GlobalKey<SliverPocketSignalWidgetState> globalKey = GlobalKey();

  SliverPocketSignalWidget({Key? key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() => SliverPocketSignalWidgetState();
}

class SliverPocketSignalWidgetState extends State<SliverPocketSignalWidget> {
  late SignalProvider _signalProvider;
  bool _isFaVisible = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(SliverPocketSignalWidget.TAG_NAME);
    CustomFirebaseClass.logEvtMyPocketView(SliverPocketSignalWidget.TAG_NAME);
    _signalProvider = Provider.of<SignalProvider>(context, listen: false);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _signalProvider.setList();
    });
  }

  reload() {
    // 결제 이후 해야하는 부분들 여기에 적어주세요.
    setState(() {});
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
            SliverFillRemaining(
              child: AppGlobal().isPremium
                  ? Consumer<SignalProvider>(
                      builder: (_, provider, __) {
                        List<StockPktSignal> signalList = provider.getSignalList;
                        if (signalList.isEmpty) {
                          return InkWell(
                              onTap: () {
                                basePageState.callPageRouteUP(
                                  const SearchPage(
                                    landWhere: SearchPage.addSignalLayer,
                                    pocketSn: '',
                                  ),
                                );
                              },
                              child: _setEmptySignalView());
                        } else {
                          return Column(
                            children: [
                              /*Container(
                                width: double.infinity,
                                height: 50,
                                child: FittedBox(
                                  child: Row(
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _signalProvider.getSortIndex == 0,
                                            onChanged: (value) async {
                                              if (value != (_signalProvider.getSortIndex == 0)) {
                                                bool result = await _signalProvider.filterListBuyRegDttm;
                                                _scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
                                              }
                                            },
                                          ),
                                          const Text('추가순'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _signalProvider.getSortIndex == 1,
                                            onChanged: (value) async {
                                              if (value != (_signalProvider.getSortIndex == 1)) {
                                                bool result = await _signalProvider.filterListProfitRate;
                                                _scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
                                              }
                                            },
                                          ),
                                          const Text('수익률순'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _signalProvider.getSortIndex == 2,
                                            onChanged: (value) async {
                                              if (value != (_signalProvider.getSortIndex == 2)) {
                                                bool result = await _signalProvider.filterListSellDttm;
                                                _scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
                                              }
                                            },
                                          ),
                                          const Text('신호발생순'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _signalProvider.getSortIndex == 3,
                                            onChanged: (value) async {
                                              if (value != (_signalProvider.getSortIndex == 3)) {
                                                bool result = await _signalProvider.filterListStockName;
                                                _scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
                                              }
                                            },
                                          ),
                                          const Text('종목명순'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),*/
                              Expanded(
                                child: Stack(
                                  children: [
                                    ListView.builder(
                                      controller: _scrollController,
                                      itemCount: signalList.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        bool isUserSig = false;
                                        if (signalList[index].sellPrice.isNotEmpty) {
                                          signalList[index].myTradeFlag == 'S' ? isUserSig = true : isUserSig = false;
                                        }
                                        return Visibility(
                                          visible: !(_signalProvider.getSortIndex == 2 &&
                                              signalList[index].myTradeFlag == 'H'),
                                          child: _setListItem(
                                            index == 0,
                                            index == signalList.length - 1,
                                            signalList[index],
                                            isUserSig,
                                          ),
                                        );
                                      },
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: InkWell(
                                        child: AnimatedContainer(
                                          width: double.infinity,
                                          height: _isFaVisible ? 50 : 0,
                                          duration: const Duration(milliseconds: 200),
                                          decoration: UIStyle.boxRoundLine6bgColor(
                                            RColor.bgBasic_fdfdfd,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 20,
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
                                                '나만의 매도신호 만들기',
                                                style: TextStyle(
                                                    //fontSize: 14,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          basePageState.callPageRouteUP(
                                            const SearchPage(
                                              landWhere: SearchPage.addSignalLayer,
                                              pocketSn: '',
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    )
                  : InkWell(
                      onTap: () async {
                        String result = await CommonPopup.instance.showDialogPremium(context);
                        if (result == CustomNvRouteResult.landPremiumPage) {
                          basePageState.navigateAndGetResultPayPremiumPage();
                        }
                      },
                      child: _setEmptySignalView()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _setListItem(bool isFirst, bool isLast, StockPktSignal item, bool isUserSig) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        basePageState.goStockHomePage(
          item.stockCode,
          item.stockName,
          Const.STK_INDEX_HOME,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.fromLTRB(20, isFirst ? 15 : 15, 20, isLast ? 15 : 0),
        decoration: UIStyle.boxShadowColor(
          16,
          isUserSig ? Colors.white : const Color(0xfff7f7f8),
        ),
        // height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 분석중 + 매도가 수정 / 매도신호 발생 + 신호 발생 날짜, 시간
            _setTradeFlag(
              item,
              isUserSig,
            ),

            const SizedBox(
              height: 8,
            ),

            // 종목명 + 종목코드
            _setStockInfoText(item),

            const SizedBox(
              height: 3,
            ),

            // 현재가 + 장 상황 + 나의 매수가 / 매도가
            _setStockPriceText(
              item,
              isUserSig,
            ),

            // 등락률 + 매수, 매도가
            _setMyPriceText(
              item,
              isUserSig,
            ),

            const SizedBox(
              height: 10,
            ),

            // 분석중입니다 / 매도하셨나요?
            _setSubInfoWidget(item, isUserSig),
          ],
        ),
      ),
    );
  }

  // 분석중 + 매도가 수정 / 매도신호 발생 + 신호 발생 날짜, 시간
  Widget _setTradeFlag(
    StockPktSignal item,
    bool tradeFlag,
  ) {
    // 매도신호 발생
    if (tradeFlag) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 1.5,
            ),
            decoration: UIStyle.boxRoundFullColor6c(RColor.purpleBasic_6565ff),
            child: const Text(
              '매도신호발생',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.5,
              ),
            ),
          ),
          Text(
            TStyle.getDateTdFormat(item.sellDttm),
            style: const TextStyle(
              color: RColor.purpleBasic_6565ff,
            ),
          ),
        ],
      );
    }
    // 분석중 + 매수가 수정
    else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 1.5,
            ),
            decoration: UIStyle.boxRoundFullColor6c(RColor.greyBox_dcdfe2),
            child: const Text(
              '분석중',
              style: TextStyle(
                fontSize: 11.5,
              ),
            ),
          ),
          InkWell(
            child: Container(
              decoration: UIStyle.boxRoundLine25c(
                RColor.greyBoxLine_c9c9c9,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 2,
              ),
              child: const Text(
                '매수가 수정',
                style: TextStyle(
                  fontSize: 12,
                  color: RColor.greyBasic_8c8c8c,
                ),
              ),
            ),
            onTap: () {
              _showDialogModBuyInfo(
                item,
              );
            },
          ),
        ],
      );
    }
  }

  // 종목명 + 종목코드
  Widget _setStockInfoText(StockPktSignal item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            item.stockName,
            style: TStyle.title18T,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          item.stockCode,
          style: const TextStyle(
            fontSize: 12,
            color: RColor.greyMore_999999,
          ),
        ),
      ],
    );
  }

  // 현재가 + 장 상황 + 나의 매수가 / 매도가
  Widget _setStockPriceText(
    StockPktSignal item,
    bool tradeFlag,
  ) {
    return Row(
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
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              _signalProvider.getTimeDivTxt,
              style: const TextStyle(
                fontSize: 12,
                color: RColor.greyMore_999999,
              ),
            ),
          ],
        ),
        Text(
          tradeFlag ? '매도가' : '나의 매수가',
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // 등락률 + 매수, 매도가
  Widget _setMyPriceText(StockPktSignal item, bool tradeFlag) {
    if (tradeFlag) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        textBaseline: TextBaseline.alphabetic,
        children: [
          CommonView.setFluctuationRateBox(value: item.profitRate, fontSize: 14,),
          const SizedBox(
            width: 6,
          ),
          Text(
            TStyle.getMoneyPoint(item.sellPrice),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        textBaseline: TextBaseline.alphabetic,
        children: [
          CommonView.setFluctuationRateBox(value: item.profitRate, fontSize: 14,),
          const SizedBox(
            width: 6,
          ),
          Text(
            TStyle.getMoneyPoint(item.buyPrice),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      );
    }
  }

  //라씨 개인화 정보
  Widget _setSubInfoWidget(StockPktSignal item, bool tradeFlag) {
    //매도신호 발생
    if (tradeFlag) {
      return Container(
        decoration: UIStyle.boxRoundFullColor8c(
          RColor.purpleBgBasic_dbdbff,
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Text(
                    '라씨',
                    style: TextStyle(
                      color: RColor.purpleBasic_6565ff,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Image.asset(
                    'images/icon_talk_purple.png',
                    height: 14,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Expanded(
                    child: AutoSizeText(
                      '추적이 완료되었습니다.',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                InkWell(
                  child: Container(
                    decoration: UIStyle.boxRoundFullColor25c(
                      RColor.purpleBasic_6565ff,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    child: const Text(
                      '삭제',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () async {
                    String result =
                        await CommonPopup.instance.showDialogBasicConfirm(context, '알림', '나만의 매도신호를 삭제하시겠습니까?');
                    if (context.mounted && result == CustomNvRouteResult.landing) {
                      _delSignalAndResult(item);
                    }
                  },
                ),
                const SizedBox(
                  width: 5,
                ),
                InkWell(
                  child: Container(
                    decoration: UIStyle.boxRoundLine25c(
                      RColor.purpleBasic_6565ff,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    child: const Text(
                      '재설정',
                      style: TextStyle(
                        color: RColor.purpleBasic_6565ff,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () {
                    //매도신호 재설정
                    _showChangeSignalLayerAndResult(item);
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }
    //보유중 (분석중)
    else {
      return Container(
        decoration: UIStyle.boxRoundFullColor8c(
          RColor.greyBox_dcdfe2,
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const Text(
              '라씨',
              style: TextStyle(
                color: RColor.purpleBasic_6565ff,
                fontSize: 12,
              ),
            ),
            const SizedBox(
              width: 2,
            ),
            Image.asset(
              'images/icon_talk_purple.png',
              height: 14,
            ),
            const SizedBox(
              width: 10,
            ),
            Flexible(
              child: AutoSizeText(
                item.listTalk[0].achieveText,
                style: const TextStyle(
                    //fontSize: 13,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _setEmptySignalView() {
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
              const Text(
                '회원님을 위한 라씨 매매비서의 제안',
                style: TStyle.commonTitle,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                '현재 보유중인 종목 매수가를 입력하세요.\n회원님만을 위한 매도신호를 알려드립니다.',
                textAlign: TextAlign.center,
                //style: TStyle.textGreyDefault,
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: UIStyle.boxRoundLine25c(Colors.black54),
                child: const Text(
                  '+ 나만의 매도신호 만들기',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //매수정보수정 레이어
  _showChangeSignalLayerAndResult(StockPktSignal stockPktSignal) async {
    await CommonLayer.instance
        .showLayerChangeSignal(
      context,
      stockPktSignal,
    )
        .then((result) {
      _resultAfterPopup(result);
    });
  }

  //매수정보수정 팝업
  void _showDialogModBuyInfo(StockPktSignal item) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext popupContext) {
          return AlertDialog(
            shape: UIStyle.borderRoundedDialog(),
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
                  const Text(
                    '나만의 매도 신호 수정',
                    style: TStyle.title18T,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text('원하시는 기능을 선택하세요.'),
                  const SizedBox(
                    height: 30.0,
                  ),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 200,
                        height: 40,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text(
                            '매수가 변경하기',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showChangeSignalLayerAndResult(item);
                    },
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  MaterialButton(
                    child: Center(
                      child: Container(
                        width: 200,
                        height: 40,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text(
                            '나만의 매도신호 삭제하기',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(popupContext);
                      String result =
                          await CommonPopup.instance.showDialogBasicConfirm(context, '알림', '나만의 매도신호를 삭제하시겠습니까?');
                      if (context.mounted && result == CustomNvRouteResult.landing) {
                        _delSignalAndResult(item);
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          );
        });
  }

  _delSignalAndResult(StockPktSignal stockPktSignal) async {
    //String result = CustomNvRouteResult.fail;
    if (stockPktSignal.resultDiv == 'S') {
      await Provider.of<SignalProvider>(context, listen: false)
          .delSignalS(
            stockPktSignal.pocketSn,
            stockPktSignal.stockCode,
          )
          .then((value) => _resultAfterPopup(value));
    } else if (stockPktSignal.resultDiv == 'P') {
      await Provider.of<SignalProvider>(context, listen: false)
          .delSignalP(
            stockPktSignal.pocketSn,
            stockPktSignal.stockCode,
          )
          .then((value) => _resultAfterPopup(value));
    }
  }

  void _resultAfterPopup(String result) {
    if (result == CustomNvRouteResult.refresh) {
      // reload();
    } else if (result == CustomNvRouteResult.cancel) {
      //
    } else if (result == CustomNvRouteResult.fail) {
      CommonPopup.instance.showDialogBasic(context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
    } else {
      CommonPopup.instance.showDialogBasic(context, '알림', result);
    }
  }
}
