import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_search/tr_search10.dart';
import 'package:rassi_assist/models/tr_shome/tr_shome05.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_swiper_pagination.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/stock_home/page/result_analyze_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// 2023.02.14ㅣ_HJS
/// 종목홈(개편)_홈_실적분석

class StockHomeHomeTileResultAnalyze extends StatefulWidget {
  static final GlobalKey<StockHomeHomeTileResultAnalyzeState> globalKey = GlobalKey();

  const StockHomeHomeTileResultAnalyze({super.key});

  //StockHomeHomeTileResultAnalyze() : super(key: globalKey);

  @override
  State<StockHomeHomeTileResultAnalyze> createState() => StockHomeHomeTileResultAnalyzeState();
}

class StockHomeHomeTileResultAnalyzeState extends State<StockHomeHomeTileResultAnalyze>
    with AutomaticKeepAliveClientMixin<StockHomeHomeTileResultAnalyze> {
  //bool _wantKeepAlive = false;

  final AppGlobal _appGlobal = AppGlobal();

  String _isNoData = '';
  int _divIndex = 0; // 0 : 매출액 / 1 : 영업이익 / 2 : 당기순이익
  bool _isQuart = true;
  bool _isRightYAxisUpUnit = false; // 차트 왼쪽 값의 단위가 false 이면 억, true 이면 천억
  final SwiperController _swiperController = SwiperController();
  int _swipeIndex = 0;

  int _confirmSearch10SalesIndexInListData = -1;
  int _confirmSearch10SalesIndexInListBarData = -1;

  int _highestIndex = -1; //최고값 인덱스
  int _lowestIndex = -1; //최저값 인덱스

  final List<Search10Sales> _listData = [];
  final List<Search10Sales> _listBarData = [];
  final List<bool> _listDivIndexIsNoData = [
    true,
    true,
    true,
  ]; // 매출액, 실적분석, 당기순이익 각각 데이터가 모든 날짜에 다 없으면 true, 하나라도 있으면 false
  final List<Search10Issue> _listIssueData = [];
  late InfoProvider _infoProvider;

  Shome05StructPrice _shome05structPrice = defShome05StructPrice;

  TooltipBehavior? _tooltipBehavior;
  double _seriesAnimation = 1500;
  ChartSeriesController? _chartColumnController;
  ChartSeriesController? _chartLineController;

  // 종목 바뀌면 다른화면에서도 이거 호출해서 갱신해줘야함
  initPage() {
    _isQuart = true;
    //_wantKeepAlive = false;
    if (_divIndex != 0) {
      _divIndex = 0;
    }
    _requestTrAll();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _tooltipBehavior?.hide();
    super.dispose();
  }

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      shouldAlwaysShow: true,
      activationMode: ActivationMode.none,
      opacity: 0.8,
      color: Colors.white,
      borderWidth: 0,
      elevation: 0,
      shadowColor: RColor.chartGreyColor,
      textStyle: const TextStyle(
        fontSize: 12,
        color: Colors.black,
      ),
    );
    super.initState();
    _infoProvider = Provider.of<InfoProvider>(context, listen: false);
    initPage();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_swipeIndex <= _listBarData.length - 1) {
        _tooltipBehavior?.hide();
        _chartColumnController?.animate();
        Timer(Duration(milliseconds: _seriesAnimation.toInt() + 200), () {
          _tooltipBehavior?.showByIndex(0, _swipeIndex);
        });
      }
    });

    if (_isNoData.isEmpty) {
      return const SizedBox(
        width: 0,
        height: 300,
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '실적분석',
                style: TStyle.title18T,
              ),
              const SizedBox(
                height: 20,
              ),
              _setDivButtons(),

              const SizedBox(
                height: 10,
              ),
              _setSubDivView(), // 분기 or 연간 + 장정 실적 발생 !

              const SizedBox(
                height: 10,
              ),
              _isNoData == 'Y' ||
                      (_divIndex == 0 && _listDivIndexIsNoData[0]) ||
                      (_divIndex == 1 && _listDivIndexIsNoData[1]) ||
                      (_divIndex == 2 && _listDivIndexIsNoData[2])
                  ? _setNoDataView()
                  : _listData.isEmpty
                      ? const SizedBox(
                          height: 500,
                        )
                      : Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            // 단위
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _isRightYAxisUpUnit ? '단위:천억원' : '단위:억원',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: RColor.new_basic_text_color_grey,
                                ),
                              ),
                            ),
                            _setChartView(),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: RColor.chartGreyColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  _divIndex == 0
                                      ? '  매출액'
                                      : _divIndex == 1
                                          ? '  영업이익'
                                          : _divIndex == 2
                                              ? '  당기순이익'
                                              : '  매출액',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: RColor.new_basic_text_color_grey,
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  width: 7,
                                  height: 7,
                                  //color: Color(0xff6565FF),
                                  decoration: const BoxDecoration(
                                    color: RColor.chartTradePriceColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const Text(
                                  '  주가',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: RColor.new_basic_text_color_grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            _setInfoViewSwiper(),
                            const SizedBox(
                              height: 10,
                            ),
                            _setNewsView(),
                          ],
                        ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                '주요지표',
                style: TStyle.title18T,
              ),
              const SizedBox(
                height: 20,
              ),
              _shome05structPrice.isEmpty() ? _setNoDataViewShome05() : _setDataViewShome05(),
              InkWell(
                onTap: () {
                  // 실적분석 상세페이지 이동
                  basePageState.callPageRouteData(
                    const ResultAnalyzePage(),
                    PgData(
                      stockName: _appGlobal.stkName,
                      stockCode: _appGlobal.stkCode,
                      booleanData: _isQuart,
                    ),
                  );
                },
                splashColor: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: UIStyle.boxRoundLine6(),
                  alignment: Alignment.center,
                  child: const Text(
                    '실적분석 내용 더보기',
                    style: TStyle.subTitle16,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: RColor.new_basic_grey,
          height: 15.0,
        ),
      ],
    );
  }

  Widget _setNoDataView() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(
        top: 20,
      ),
      decoration: UIStyle.boxRoundLine6(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 1,
                color: RColor.new_basic_text_color_grey,
              ),
              color: Colors.transparent,
            ),
            child: const Center(
              child: Text(
                '!',
                style: TextStyle(fontSize: 18, color: RColor.new_basic_text_color_grey),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            _isQuart ? '실적분석 내용이 없습니다.' : '최근 5년 실적 정보가 없습니다.',
            style: const TextStyle(
              fontSize: 14,
              color: RColor.new_basic_text_color_grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _setNoDataViewShome05() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: UIStyle.boxRoundLine6(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 1,
                color: RColor.new_basic_text_color_grey,
              ),
              color: Colors.transparent,
            ),
            child: const Center(
              child: Text(
                '!',
                style: TextStyle(fontSize: 18, color: RColor.new_basic_text_color_grey),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            '주요 지표가 없습니다.',
            style: TextStyle(
              fontSize: 14,
              color: RColor.new_basic_text_color_grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _setDataViewShome05() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  width: 1,
                  color: RColor.new_basic_line_grey,
                ),
                top: BorderSide(
                  width: 1,
                  color: RColor.new_basic_line_grey,
                ),
                bottom: BorderSide(
                  width: 1,
                  color: RColor.new_basic_line_grey,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  color: RColor.bgTableGrey,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                  ),
                  child: const Text(
                    'PER',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: RColor.new_basic_line_grey,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                  ),
                  child: Text(
                    _shome05structPrice.per.isEmpty
                        ? 'N/A'
                        : TStyle.getMoneyPoint(
                            _shome05structPrice.per,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                border: Border.fromBorderSide(
              BorderSide(
                width: 1,
                color: RColor.new_basic_line_grey,
              ),
            )),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  color: RColor.bgTableGrey,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                  ),
                  child: const Text(
                    'PBR',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: RColor.new_basic_line_grey,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                  ),
                  child: Text(
                    _shome05structPrice.pbr.isEmpty ? 'N/A' : TStyle.getMoneyPoint(_shome05structPrice.pbr),
                  ),
                ),
              ],
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(
                  width: 1,
                  color: RColor.new_basic_line_grey,
                ),
                top: BorderSide(
                  width: 1,
                  color: RColor.new_basic_line_grey,
                ),
                bottom: BorderSide(
                  width: 1,
                  color: RColor.new_basic_line_grey,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  color: RColor.bgTableGrey,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                  ),
                  child: const Text(
                    'EPS',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: RColor.new_basic_line_grey,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                  ),
                  child: Text(
                    _shome05structPrice.eps.isEmpty ? 'N/A' : TStyle.getMoneyPoint(_shome05structPrice.eps),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _setDivButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: InkWell(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 1.4,
                  color: _divIndex == 0 ? Colors.black : RColor.lineGrey,
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(
                    5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '매출액',
                  style: _divIndex == 0
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (_divIndex != 0) {
                setState(
                  () {
                    _divIndex = 0;
                    _isRightYAxisUpUnit = _findMaxValue >= 1000;
                  },
                );
              }
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: InkWell(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.symmetric(
                  horizontal: BorderSide(
                    width: 1.4,
                    color: _divIndex == 1 ? Colors.black : RColor.lineGrey,
                  ),
                  vertical: BorderSide(
                    width: _divIndex == 1 ? 1.4 : 0,
                    color: _divIndex == 1 ? Colors.black : Colors.transparent,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '영업이익',
                  style: _divIndex == 1
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (_divIndex != 1) {
                setState(() {
                  _divIndex = 1;
                  _seriesAnimation = 1000;
                  _isRightYAxisUpUnit = _findMaxValue >= 1000;
                });
              }
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: InkWell(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 1.4,
                  color: _divIndex == 2 ? Colors.black : RColor.lineGrey,
                ),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(
                    5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '당기순이익',
                  style: _divIndex == 2
                      ? TStyle.commonTitle15
                      : const TextStyle(
                          fontSize: 15,
                          color: RColor.lineGrey,
                        ),
                ),
              ),
            ),
            onTap: () {
              if (_divIndex != 2) {
                setState(() {
                  _divIndex = 2;
                  _seriesAnimation = 1000;
                  _isRightYAxisUpUnit = _findMaxValue >= 1000;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _setSubDivView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 4,
              ),
              decoration: _isQuart ? UIStyle.boxNewSelectBtn1() : UIStyle.boxNewUnSelectBtn1(),
              child: InkWell(
                child: Center(
                  child: Text(
                    '분기',
                    style: TextStyle(
                      color: _isQuart ? Colors.black : RColor.btnUnSelectGreyText,
                      fontSize: 15,
                    ),
                  ),
                ),
                onTap: () {
                  if (!_isQuart) {
                    _isQuart = true;
                    _requestTrSearch10();
                  }
                },
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 4,
              ),
              decoration: _isQuart ? UIStyle.boxNewUnSelectBtn1() : UIStyle.boxNewSelectBtn1(),
              child: InkWell(
                child: Center(
                  child: Text(
                    '연간',
                    style: TextStyle(
                      color: _isQuart ? RColor.btnUnSelectGreyText : Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
                onTap: () {
                  if (_isQuart) {
                    _tooltipBehavior?.hide();
                    _isQuart = false;
                    _requestTrSearch10();
                  }
                },
              ),
            ),
          ],
        ),
        Visibility(
          visible: _isQuart && _confirmSearch10SalesIndexInListData != -1,
          child: InkWell(
            onTap: () {
              _showDialogNoConfirm(
                context,
              );
            },
            child: const Row(
              children: [
                Text(
                  '잠정실적발생',
                  style: TextStyle(color: RColor.sigBuy, fontSize: 15),
                ),
                SizedBox(
                  width: 4,
                ),
                Icon(
                  Icons.info_outline,
                  color: RColor.bgBuy,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _setInfoViewSwiper() {
    return SizedBox(
      width: double.infinity,
      height: _listBarData.length < 2 ? 182 : 210,
      child: Swiper(
        controller: _swiperController,
        scale: 0.9,
        pagination: _listBarData.length < 2
            ? null
            : CommonSwiperPagenation.getNormalSpWithMargin(
                8,
                190,
                Colors.black,
              ),
        autoplay: false,
        index: _swipeIndex,
        itemCount: _listBarData.length,
        itemBuilder: (BuildContext context, int index) {
          var item = _listBarData[index];
          return Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            margin: EdgeInsets.only(
                //left: 5, right: 5,
                bottom: _listBarData.length < 2 ? 0 : 28),
            decoration: UIStyle.boxNewBasicGrey10(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isQuart ? '${item.tradeDate.substring(0, 4)}년 ${item.quarter}분기' : '${item.year}년',
                      style: TStyle.subTitle16,
                    ),
                    Visibility(
                      visible: item.confirmYn == 'N',
                      child: const Text(
                        '잠정실적',
                        style: TStyle.textMBuy,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '매출액',
                      style: TextStyle(
                        fontSize: 16,
                        color: RColor.new_basic_text_color_strong_grey,
                      ),
                    ),
                    item.sales.isEmpty
                        ? const Text(
                            '- ',
                            style: TStyle.commonTitle,
                          )
                        : Row(
                            children: [
                              Text(
                                TStyle.getComboUnitWithMoneyPointByDouble(
                                  item.sales,
                                ),
                                style: TStyle.commonTitle,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                item.salesIncRateYoY.isEmpty
                                    ? ''
                                    : '(YoY ${TStyle.getPercentString(item.salesIncRateYoY)})',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: TStyle.getMinusPlusColor(item.salesIncRateYoY),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '영업이익',
                      style: TextStyle(
                        fontSize: 16,
                        color: RColor.new_basic_text_color_strong_grey,
                      ),
                    ),
                    item.salesProfit.isEmpty
                        ? const Text(
                            '- ',
                            style: TStyle.commonTitle,
                          )
                        : Row(
                            children: [
                              Text(
                                TStyle.getBillionUnitWithMoneyPointByDouble(
                                  item.salesProfit,
                                ),
                                style: TStyle.commonTitle,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                item.profitIncRateYoY.isEmpty
                                    ? ''
                                    : '(YoY ${TStyle.getPercentString(item.profitIncRateYoY)})',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: TStyle.getMinusPlusColor(item.profitIncRateYoY),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '당기순이익',
                        style: TextStyle(
                          fontSize: 16,
                          color: RColor.new_basic_text_color_strong_grey,
                        ),
                      ),
                      item.netProfit.isEmpty
                          ? const Text(
                              '- ',
                              style: TStyle.commonTitle,
                            )
                          : Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: FittedBox(
                                      child: Text(
                                        TStyle.getBillionUnitWithMoneyPointByDouble(
                                          item.netProfit,
                                        ),
                                        style: TStyle.commonTitle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Flexible(
                                    child: FittedBox(
                                      child: Text(
                                        item.netIncRateYoY.isEmpty
                                            ? ' '
                                            : '(YoY ${TStyle.getPercentString(item.netIncRateYoY)})',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: TStyle.getMinusPlusColor(
                                            item.netIncRateYoY,
                                          ),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '영업이익률',
                      style: TextStyle(
                        fontSize: 16,
                        color: RColor.new_basic_text_color_strong_grey,
                      ),
                    ),
                    Text(
                      item.profitRate.isEmpty ? '' : TStyle.getPercentString(item.profitRate),
                      style: TStyle.commonTitle,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        onIndexChanged: (int index) {
          _seriesAnimation = 0;
          setState(() => _swipeIndex = index);
        },
      ),
    );
  }

  Widget _setNewsView() {
    if (_listIssueData.isNotEmpty) {
      return InkWell(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_listIssueData[0].issueDate),
              const SizedBox(
                width: 4,
              ),
              Expanded(
                child: Text(
                  _listIssueData[0].title,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        onTap: () {},
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _setChartView() {
    return SizedBox(
      width: double.infinity,
      height: 260,
      child: SfCartesianChart(
        enableMultiSelection: false,
        plotAreaBorderWidth: 0,
        margin: const EdgeInsets.symmetric(
          vertical: 1,
        ),
        primaryXAxis: CategoryAxis(
          axisBorderType: AxisBorderType.withoutTopAndBottom,
          axisLine: const AxisLine(
            width: 1.2,
            color: RColor.chartGreyColor,
          ),
          majorGridLines: const MajorGridLines(
            width: 0,
          ),
          majorTickLines: const MajorTickLines(
            width: 0,
          ),
          axisLabelFormatter: (axisLabelRenderArgs) => ChartAxisLabel(
            _isQuart
                ? (_confirmSearch10SalesIndexInListBarData != -1 &&
                        axisLabelRenderArgs.value == _confirmSearch10SalesIndexInListBarData)
                    ? '${axisLabelRenderArgs.text.substring(2)}Q\n(잠정)'
                    : '${axisLabelRenderArgs.text.substring(2)}Q'
                : axisLabelRenderArgs.text.substring(0, 4),
            const TextStyle(
              fontSize: 10,
              color: RColor.greyBasic_8c8c8c,
            ),
          ),
        ),
        primaryYAxis: const NumericAxis(
          axisBorderType: AxisBorderType.withoutTopAndBottom,
          rangePadding: ChartRangePadding.round,
          isVisible: false,
          plotOffset: 2,
        ),
        axes: <ChartAxis>[
          CategoryAxis(
            name: 'xAxis',
            opposedPosition: true,
            isVisible: false,
            axisBorderType: AxisBorderType.withoutTopAndBottom,
            labelPlacement: LabelPlacement.onTicks,
            plotBands: getPlotBand,
          ),
          NumericAxis(
            axisBorderType: AxisBorderType.withoutTopAndBottom,
            name: 'yAxis',
            opposedPosition: true,
            anchorRangeToVisiblePoints: true,
            rangePadding: ChartRangePadding.additional,
            //desiredIntervals: 3,
            //interval: _getInterval,
            axisLine: const AxisLine(
              width: 0,
            ),
            majorGridLines: const MajorGridLines(
              color: RColor.chartGreyColor,
              width: 0.6,
              dashArray: [2, 2],
            ),
            majorTickLines: const MajorTickLines(
              width: 0,
            ),
            minorGridLines: const MinorGridLines(
              width: 0,
            ),
            minorTickLines: const MinorTickLines(
              width: 0,
            ),
            axisLabelFormatter: (axisLabelRenderArgs) {
              String value = axisLabelRenderArgs.text;
              if (_isRightYAxisUpUnit) {
                value = TStyle.getMoneyPoint((axisLabelRenderArgs.value / 1000).toString());
              } else {
                value = TStyle.getMoneyPoint(axisLabelRenderArgs.value.round().toString());
              }
              return ChartAxisLabel(
                value,
                const TextStyle(
                  fontSize: 12,
                  color: RColor.greyBasic_8c8c8c,
                ),
              );
            },
            plotBands: const [
              PlotBand(
                start: 0,
                end: 0,
                color: RColor.chartGreyColor,
                opacity: 0.2,
                isVisible: true,
                borderWidth: 1.2,
              ),
            ],
          )
        ],
        selectionType: SelectionType.cluster,
        onSelectionChanged: (SelectionArgs args) {
          _seriesAnimation = 0;
          _swipeIndex = args.pointIndex;
          setState(() => _swipeIndex = args.pointIndex);
          //_swiperController.move(args.pointIndex);
        },
        tooltipBehavior: _tooltipBehavior,
        onTooltipRender: (tooltipArgs) {
          if (_swipeIndex <= _listBarData.length - 1) {
            var item = _listBarData[_swipeIndex];
            tooltipArgs.header = _isQuart ? '${item.tradeDate.substring(0, 4)}/${item.quarter}분기' : '${item.year}년';
            tooltipArgs.text = TStyle.getComboUnitWithMoneyPointByDouble(
              '${double.tryParse(
                    _divIndex == 0
                        ? item.sales
                        : _divIndex == 1
                            ? item.salesProfit
                            : _divIndex == 2
                                ? item.netProfit
                                : item.sales,
                  ) ?? 0}',
            );
          }
        },
        series: [
          ColumnSeries<Search10Sales, String>(
            dataSource: _listBarData,
            xValueMapper: (Search10Sales data, index) => '${data.year}/${data.quarter}',
            yValueMapper: (Search10Sales data, index) =>
                double.tryParse(
                  _divIndex == 0
                      ? _listBarData[index].sales
                      : _divIndex == 1
                          ? _listBarData[index].salesProfit
                          : _divIndex == 2
                              ? _listBarData[index].netProfit
                              : _listBarData[index].sales,
                ) ??
                0,
            pointColorMapper: (Search10Sales data, index) {
              if (index == _swipeIndex) {
                return RColor.sigBuy;
              } else {
                if (_isQuart && index == _confirmSearch10SalesIndexInListBarData) {
                  return RColor.chartGreyColor.withOpacity(0.4);
                } else {
                  return RColor.chartGreyColor;
                }
              }
            },
            onPointTap: (pointInteractionDetails) {
              if (pointInteractionDetails.pointIndex != null && pointInteractionDetails.pointIndex != _swipeIndex) {
                _seriesAnimation = 0;
                _swipeIndex = pointInteractionDetails.pointIndex ?? 0;
                _swiperController.move(
                  pointInteractionDetails.pointIndex ?? 0,
                );
              }
            },
            yAxisName: 'yAxis',
            width: _listBarData.length * 0.1,
            enableTooltip: true,
            borderRadius: const BorderRadius.all(
              Radius.circular(1),
            ),
            animationDelay: 0,
            animationDuration: _seriesAnimation,
            onRendererCreated: (controller) {
              _chartColumnController = controller;
            },
          ),
          LineSeries<Search10Sales, String>(
            dataSource: _listData,
            xValueMapper: (item, index) => index.toString(),
            yValueMapper: (item, index) => int.parse(item.tradePrice),
            color: RColor.chartTradePriceColor,
            width: 1.4,
            enableTooltip: false,
            xAxisName: 'xAxis',
            animationDelay: 0,
            animationDuration: _seriesAnimation,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              borderWidth: 1,
              borderColor: RColor.greyBoxLine_c9c9c9,
              color: Colors.white,
              opacity: 0.6,
              //labelAlignment: ChartDataLabelAlignment.top,
              textStyle: const TextStyle(
                fontSize: 8,
                color: Colors.black,
              ),
              showZeroValue: true,
              margin: EdgeInsets.zero,
              builder: (data, point, series, pointIndex, seriesIndex) {
                if (pointIndex == _highestIndex) {
                  //DLog.e('최고 index : $pointIndex');
                  //return '최고123';
                  //return '최고 ${TStyle.getMoneyPoint(datum.tradePrice)}원';
                  return Container(
                    /*padding: const EdgeInsets.all(2,),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border: Border.all(width: 1, color: RColor.greyBox_dcdfe2,),
                    ),*/
                    child: Text(
                      '최고 ${TStyle.getMoneyPoint(_listData[pointIndex].tradePrice)}원',
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  );
                } else if (pointIndex == _lowestIndex) {
                  //DLog.e('최저 index : $index');
                  //return '최저';
                  //return '최저 ${TStyle.getMoneyPoint(datum.tradePrice)}원';
                  return Container(
                    /*padding: const EdgeInsets.all(2,),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border: Border.all(width: 1, color: RColor.greyBox_dcdfe2,),
                    ),*/
                    child: Text(
                      '최저 ${TStyle.getMoneyPoint(_listData[pointIndex].tradePrice)}원',
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  );
                } else {
                  //DLog.e('기타 index : $index');
                  return const SizedBox();
                }
                //return Container(child: Text('${TStyle.getMoneyPoint(_listData[pointIndex].tradePrice)}원'),);
              },
              //overflowMode: OverflowMode.shift,
            ),
            onRendererCreated: (controller) {
              _chartLineController = controller;
            },
          ),
        ],
      ),
    );
  }

  List<PlotBand> get getPlotBand {
    if (_isQuart && _confirmSearch10SalesIndexInListData != -1) {
      return [
        PlotBand(
          isVisible: true,
          start: _confirmSearch10SalesIndexInListData - 1,
          end: _confirmSearch10SalesIndexInListData - 1,
          dashArray: const [3, 5],
          borderWidth: 1,
          borderColor: RColor.chartRed1,
          opacity: 0.8,
        ),
      ];
    } else {
      return [];
    }
  }

  _requestTrAll() async {
    await Future.wait(
      [
        // DEFINE 종목요약정보 + 시세
        _fetchPosts(
          TR.SEARCH10,
          jsonEncode(
            <String, String>{
              'userId': _appGlobal.userId,
              'stockCode': _appGlobal.stkCode,
              'selectDiv': _isQuart ? 'QUART' : 'YEAR',
            },
          ),
        ),
        // DEFINE 주요 지표
        _fetchPosts(
          TR.SHOME05,
          jsonEncode(
            <String, String>{
              'userId': _appGlobal.userId,
              'stockCode': _appGlobal.stkCode,
            },
          ),
        ),
      ],
    );

    //setState(() {});
  }

  _requestTrSearch10() {
    _fetchPosts(
      TR.SEARCH10,
      jsonEncode(
        <String, String>{
          'userId': _appGlobal.userId,
          'stockCode': _appGlobal.stkCode,
          'selectDiv': _isQuart ? 'QUART' : 'YEAR',
        },
      ),
    );
  }

  Future<void> _fetchPosts(String trStr, String json) async {
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
      if (mounted) {
        CommonPopup.instance.showDialogNetErr(context);
      }
    } on SocketException catch (_) {
      if (mounted) {
        CommonPopup.instance.showDialogNetErr(context);
      }
    }
  }

  Future<void> _parseTrData(String trStr, final http.Response response) async {
    // DLog.w(trStr + response.body);
    if (trStr == TR.SEARCH10) {
      final TrSearch10 resData = TrSearch10.fromJson(jsonDecode(response.body));
      _confirmSearch10SalesIndexInListData = -1;
      _confirmSearch10SalesIndexInListBarData = -1;

      //int beforeListBarDataLength = _listBarData.length;

      _listData.clear();
      _listBarData.clear();
      _listIssueData.clear();

      /*if (beforeListBarDataLength != 0) {
        DLog.e(
            'beforeListBarDataLength : $beforeListBarDataLength / _chartColumnController == null ? ${_chartColumnController == null} / '
            '_chartColumnController?.seriesRenderer.children.length : ${_chartColumnController?.seriesRenderer.children.length}'
            '/n _chartColumnController.seriesRenderer.dataCount : ${_chartColumnController?.seriesRenderer.dataCount}');

        _chartColumnController?.updateDataSource(
          removedDataIndexes:
              List.generate(beforeListBarDataLength, (index) => index),
        );
        _chartLineController?.updateDataSource(
          removedDataIndexes:
              List.generate(beforeListBarDataLength, (index) => index),
        );
      }*/

      setState(() {});
      await Future.delayed(const Duration(milliseconds: 100));

      _isNoData = 'N';
      if (resData.retCode == RT.SUCCESS && resData.retData.notApplicable == 'N') {
        if (resData.retData.listSales.isNotEmpty) {
          _listData.addAll(resData.retData.listSales);
          resData.retData.listSales.asMap().forEach((key, element) {
            if (element.sales.isNotEmpty) {
              _listDivIndexIsNoData[0] = false;
            }
            if (element.salesProfit.isNotEmpty) {
              _listDivIndexIsNoData[1] = false;
            }
            if (element.netProfit.isNotEmpty) {
              _listDivIndexIsNoData[2] = false;
            }
            if (element.sales.isNotEmpty || element.salesProfit.isNotEmpty || element.netProfit.isNotEmpty) {
              _listBarData.add(element);
              if (_isQuart && element.confirmYn == 'N') {
                _confirmSearch10SalesIndexInListData = key;
                _confirmSearch10SalesIndexInListBarData = _listBarData.length - 1;
              }
            }
          });
          if (_listDivIndexIsNoData[0]) {
            _divIndex = 1;
          } else if (_listDivIndexIsNoData[1]) {
            _divIndex = 2;
          }
          _isRightYAxisUpUnit = _findMaxValue >= 1000;
          _infoProvider.update(_listData[0]);
          if (resData.retData.listIssue.isNotEmpty) {
            _listIssueData.addAll(resData.retData.listIssue);
          }
        }
      } else {
        _isNoData = 'Y';
      }
      _seriesAnimation = 1000;

      double maxPrice = 0;
      double minPrice = 0;
      _listData.asMap().forEach((index, element) {
        double price = double.parse(element.tradePrice);
        if (index == 0) {
          minPrice = price;
          maxPrice = price;
          _highestIndex = 0;
          _lowestIndex = 0;
        }
        if (price > maxPrice) {
          maxPrice = price;
          _highestIndex = index;
        }
        if (price < minPrice) {
          minPrice = price;
          _lowestIndex = index;
        }
      });

      setState(() => _swipeIndex = _listBarData.length - 1);
    } else if (trStr == TR.SHOME05) {
      final TrShome05 resData = TrShome05.fromJson(jsonDecode(response.body));
      _shome05structPrice = defShome05StructPrice;
      if (resData.retCode == RT.SUCCESS) {
        _shome05structPrice = resData.retData.shome05structPrice;
      }
    }
  }

  double get _findMaxValue {
    if (_listBarData.isEmpty) {
      return 0;
    } else if (_listBarData.length == 1) {
      var item = _listBarData[0];
      double value = 0;
      if (_divIndex == 0) {
        value = double.tryParse(item.sales) ?? 0;
      } else if (_divIndex == 1) {
        value = double.tryParse(item.salesProfit) ?? 0;
      } else if (_divIndex == 2) {
        value = double.tryParse(item.netProfit) ?? 0;
      }
      if (value < 0) {
        return 0;
      }
      return value;
    } else {
      double value = 0;
      if (_divIndex == 0) {
        var item = _listBarData.reduce(
          (curr, next) => (double.tryParse(curr.sales) ?? 0) > (double.tryParse(next.sales) ?? 0) ? curr : next,
        );
        value = double.tryParse(item.sales) ?? 0;
      } else if (_divIndex == 1) {
        var item = _listBarData.reduce(
          (curr, next) =>
              (double.tryParse(curr.salesProfit) ?? 0) > (double.tryParse(next.salesProfit) ?? 0) ? curr : next,
        );
        value = double.tryParse(item.salesProfit) ?? 0;
      } else if (_divIndex == 2) {
        var item = _listBarData.reduce(
          (curr, next) => (double.tryParse(curr.netProfit) ?? 0) > (double.tryParse(next.netProfit) ?? 0) ? curr : next,
        );
        value = double.tryParse(item.netProfit) ?? 0;
      } else {
        value = 0;
      }
      if (value < 0) {
        return 0;
      }
      return value;
    }
  }

  double get _findMinValue {
    if (_listBarData.isEmpty) {
      return 0;
    } else if (_listBarData.length == 1) {
      var item = _listBarData[0];
      double value = 0;
      if (_divIndex == 0) {
        value = double.tryParse(item.sales) ?? 0;
      } else if (_divIndex == 1) {
        value = double.tryParse(item.salesProfit) ?? 0;
      } else if (_divIndex == 2) {
        value = double.tryParse(item.netProfit) ?? 0;
      }
      if (value < 0) {
        return value;
      }
      return 0;
    } else {
      if (_divIndex == 0) {
        var item = _listBarData.reduce(
          (curr, next) => (double.tryParse(next.sales) ?? 0) == 0 ||
                  (double.tryParse(curr.sales) ?? 0) < (double.tryParse(next.sales) ?? 0)
              ? curr
              : next,
        );
        return double.tryParse(item.sales) ?? 0;
      } else if (_divIndex == 1) {
        var item = _listBarData.reduce(
          (curr, next) =>
              (double.tryParse(curr.salesProfit) ?? 0) < (double.tryParse(next.salesProfit) ?? 0) ? curr : next,
        );
        return double.tryParse(item.salesProfit) ?? 0;
      } else if (_divIndex == 2) {
        var item = _listBarData.reduce(
          (curr, next) => (double.tryParse(curr.netProfit) ?? 0) < (double.tryParse(next.netProfit) ?? 0) ? curr : next,
        );
        return double.tryParse(item.netProfit) ?? 0;
      } else {
        return 0;
      }
    }
  }

  int findHighestTradePriceIndex() {
    if (_listData.isEmpty) {
      return -1; // 리스트가 비어있으면 -1을 반환합니다.
    }

    double highestPrice = double.parse(_listData[0].tradePrice);
    int highestIndex = 0;

    for (int i = 1; i < _listData.length; i++) {
      double currentPrice = double.parse(_listData[i].tradePrice);
      if (currentPrice > highestPrice) {
        highestPrice = currentPrice;
        highestIndex = i;
      }
    }

    return highestIndex;
  }

  int findLowestTradePriceIndex() {
    if (_listData.isEmpty) {
      return -1; // 리스트가 비어있으면 -1을 반환합니다.
    }

    double lowestPrice = double.parse(_listData[0].tradePrice);
    int lowestIndex = 0;

    for (int i = 1; i < _listData.length; i++) {
      double currentPrice = double.parse(_listData[i].tradePrice);
      if (currentPrice < lowestPrice) {
        lowestPrice = currentPrice;
        lowestIndex = i;
      }
    }

    return lowestIndex;
  }

  void _showDialogNoConfirm(BuildContext context) {
    var item = _listData[_confirmSearch10SalesIndexInListData];
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
                const Text(
                  '잠정실적',
                  style: TStyle.title18T,
                ),
                InkWell(
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 26,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.c,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${TStyle.getDateSlashFormat3(item.issueDate)}기준',
                      style: TStyle.contentGrey14,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    decoration: UIStyle.boxNewBasicGrey10(),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '매출액',
                              style: TextStyle(
                                fontSize: 13,
                                color: RColor.new_basic_text_color_strong_grey,
                              ),
                            ),
                            item.sales.isEmpty
                                ? const Text(
                                    '- ',
                                    style: TStyle.subTitle,
                                  )
                                : Row(
                                    children: [
                                      Text(
                                        TStyle.getComboUnitWithMoneyPointByDouble(
                                          item.sales,
                                        ),
                                        style: TStyle.contentSBLK,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        item.salesIncRateYoY.isEmpty
                                            ? ''
                                            : '(YoY ${TStyle.getPercentString(item.salesIncRateYoY)})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: TStyle.getMinusPlusColor(
                                            item.salesIncRateYoY,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '영업이익',
                              style: TextStyle(
                                fontSize: 13,
                                color: RColor.new_basic_text_color_strong_grey,
                              ),
                            ),
                            item.salesProfit.isEmpty
                                ? const Text(
                                    '- ',
                                    style: TStyle.subTitle,
                                  )
                                : Row(
                                    children: [
                                      Text(
                                        TStyle.getBillionUnitWithMoneyPointByDouble(
                                          item.salesProfit,
                                        ),
                                        style: TStyle.contentSBLK,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        item.profitIncRateYoY.isEmpty
                                            ? ''
                                            : '(YoY ${TStyle.getPercentString(item.profitIncRateYoY)})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: TStyle.getMinusPlusColor(item.profitIncRateYoY),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '당기순이익',
                              style: TextStyle(
                                fontSize: 13,
                                color: RColor.new_basic_text_color_strong_grey,
                              ),
                            ),
                            item.netProfit.isEmpty
                                ? const Text(
                                    '- ',
                                    style: TStyle.subTitle,
                                  )
                                : Row(
                                    children: [
                                      Text(
                                        TStyle.getBillionUnitWithMoneyPointByDouble(item.netProfit),
                                        style: TStyle.contentSBLK,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        item.netIncRateYoY.isEmpty
                                            ? ''
                                            : '(YoY ${TStyle.getPercentString(item.netIncRateYoY)})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: TStyle.getMinusPlusColor(
                                            item.netIncRateYoY,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    child: const SizedBox(
                      width: 140,
                      height: 36,
                      //decoration: UIStyle.roundBtnStBox(),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '자세히보기',
                              style: TStyle.contentGrey14,
                            ),
                            Icon(
                              Icons.arrow_forward_ios_sharp,
                              color: Color(0xff919191),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // 실적분석 상세페이지 이동
                      basePageState.callPageRouteData(
                        const ResultAnalyzePage(),
                        PgData(
                          stockName: _appGlobal.stkName,
                          stockCode: _appGlobal.stkCode,
                          booleanData: _isQuart,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  double get _getInterval {
    double minValue = _findMinValue;
    double maxValue = _findMaxValue;
    /*if(_isRightYAxisUpUnit){
      minValue /= 1000;
      maxValue /= 1000;
    }*/
    // 최솟값과 최댓값을 이용하여 적절한 간격 계산
    double range = double.parse((maxValue - minValue).toStringAsFixed(1));
    double interval = range / 4; // 예시로 4개의 간격으로 나눔
    double roundedInterval = pow(10, (log(interval) / log(10)).floor()).toDouble();
    /*if(_isRightYAxisUpUnit && interval < 4){
      roundedInterval = double.parse(pow(10, (log(interval) / log(10)).floor()).toStringAsFixed(1));
      DLog.e('_getInterval : ${double.parse((roundedInterval * ((range / 4) / roundedInterval).ceil()).toStringAsFixed(1))}');
      return double.parse((roundedInterval * ((range / 4) / roundedInterval).ceil()).toStringAsFixed(1));
    }*/
    return (roundedInterval * ((range / 4) / roundedInterval).ceil()).toDouble();
  }
}

class InfoProvider extends ChangeNotifier {
  Search10Sales _search10Sales = Search10Sales.empty();

  Search10Sales get getSearch10Sales => _search10Sales;

  void update(Search10Sales vSearch10Sales) {
    _search10Sales = vSearch10Sales;
    notifyListeners();
  }
}
