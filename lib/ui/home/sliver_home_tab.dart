import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_notifier.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/home/sliver_home_page.dart';
import 'package:rassi_assist/ui/home/sliver_market_page.dart';
import 'package:rassi_assist/ui/home/sliver_signal_page.dart';
import 'package:rassi_assist/ui/home/sliver_stock_catch.dart';
import 'package:rassi_assist/ui/main/search_page.dart';

/// 2022.04.20
/// 메인_홈
class SliverHomeTabWidget extends StatefulWidget {
  static const String TAG = "[SliverHomeTabWidget] ";

  const SliverHomeTabWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SliverHomeTabWidgetState();
}

class SliverHomeTabWidgetState extends State<SliverHomeTabWidget>
    with SingleTickerProviderStateMixin {
  int initIndex = 0;
  final List<String> _tabs = ['홈', 'AI매매신호', '종목캐치', '마켓뷰'];
  final List<String> _dropdownItems = ['AI매매신호', '종목홈'];
  final List<String> _dropdownTitles = [
    '살까? 팔까? 타이밍이 궁금하세요?',
    '종목정보를 검색해 보세요!',
  ];

  String _dropdownValue = 'AI매매신호';
  int _dropdownSelectIndex = 0;

  final refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DLog.e('ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ'
          'SliverHomeTabWidgetState ModalRoute.of(context).settings.name : ${ModalRoute.of(context)?.settings.name}'
          'ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ');
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    initIndex = Provider.of<PageNotifier>(context, listen: false).dstIndex;
    return Scaffold(
      appBar: CommonAppbar.none(
        RColor.bgBasic_fdfdfd,
      ),
      body: SafeArea(
        child: DefaultTabController(
          initialIndex: initIndex,
          length: _tabs.length,
          child: _setNestedScrollView(),
        ),
      ),
    );
  }

  Widget _setNestedScrollView() {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              expandedHeight: 190.0,
              pinned: true,
              floating: false,
              backgroundColor: RColor.bgBasic_fdfdfd,
              forceElevated: innerBoxIsScrolled,
              // automaticallyImplyLeading: false,
              elevation: 0,
              actions: null,
              //가변영역 [움직이는, 숨겨지는 영역]
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.only(
                  start: 0,
                  bottom: 0,
                ),
                centerTitle: false,
                //backgroundColor 항목과 background 항목이 같이 쓰일경우 Opacity 설정
                background: Opacity(
                  opacity: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //상단 타이틀 영역 만큼의 공간[위로 숨겨지는 영역]
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Image.asset(
                            'images/icon_rassi_logo_purple.png',
                            //color: RColor.mainColor,
                            height: 28,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Image.asset(
                            'images/img_rassi_title_maincolor.png',
                            height: 23,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(54.2),
                // [남겨지는 영역] Title bar 의 크기
                // preferredSize: Size.fromHeight(55),   // [남겨지는 영역] Title bar 의 크기
                child: Column(
                  children: [
                    _setTabSearchView(innerBoxIsScrolled),
                    SizedBox(
                      height: 50.2, //[탭바]의 높이
                      //padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                      child: Column(
                        children: [
                          const TabBar(
                            indicatorColor: Colors.black,
                            indicatorWeight: 3,
                            labelColor: Colors.black,
                            labelStyle: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: RColor.blackTitle_141414,
                            ),
                            unselectedLabelColor: RColor.greyTitle_cdcdcd,
                            unselectedLabelStyle: TextStyle(
                              fontSize: 16,
                              color: RColor.greyTitle_cdcdcd,
                            ),
                            isScrollable: true,
                            tabs: [
                              SizedBox(
                                width: 32,
                                child: Tab(
                                  text: '홈',
                                ),
                              ),
                              Tab(
                                text: 'AI매매신호',
                              ),
                              Tab(
                                text: '종목캐치',
                              ),
                              Tab(
                                text: '마켓뷰',
                              ),
                            ],
                            // _tabs.map((String name) => Tab(text: name)).toList(),
                          ),
                          Container(
                            height: 1.2,
                            color: const Color(
                              0xffF5F5F5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: _setTabView(),
    );
  }

  Widget _setTabSearchView(bool innerBoxIsScrolled) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      margin: const EdgeInsets.only(
        bottom: 5,
        top: 5,
      ),
      child: Row(
        children: [
          Visibility(
            visible: innerBoxIsScrolled,
            child: Container(
              margin: const EdgeInsets.only(
                right: 10,
              ),
              child: Image.asset(
                'images/icon_rassi_logo_purple.png',
                color: RColor.mainColor,
                height: 30,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: UIStyle.boxRoundFullColor6c(
                RColor.greyBox_f5f5f5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _setDropdownView(),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        AppGlobal().tabIndex =
                            _dropdownSelectIndex == 0 ? 1 : 0;
                        Navigator.push(
                          context,
                          CustomNvRouteClass.createRoute(
                            SearchPage.goStockHome(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              _dropdownTitles[_dropdownSelectIndex],
                              style: const TextStyle(
                                color: RColor.greyTitle_cdcdcd,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.search,
                          ),
                        ],
                      ),
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

  Widget _setDropdownView() {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        items: _dropdownItems
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        value: _dropdownValue,
        onChanged: (value) {
          if (value != _dropdownItems[_dropdownSelectIndex]) {
            setState(() {
              _dropdownValue = value!;
              _dropdownSelectIndex = _dropdownSelectIndex == 0 ? 1 : 0;
            });
          }
        },
        buttonStyleData: const ButtonStyleData(
          height: 40,
          width: 100,
          padding: EdgeInsets.only(
            left: 5,
            right: 5,
          ),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.keyboard_arrow_down_outlined,
          ),
          iconSize: 20,
          iconEnabledColor: Colors.black,
          iconDisabledColor: Colors.black,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          width: 120,
          elevation: 0,
          decoration: UIStyle.boxRoundFullColor6c(
            RColor.greyBox_f5f5f5,
          ),
          offset: const Offset(-10, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all(6),
            thumbVisibility: MaterialStateProperty.all(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.only(
            left: 15,
            right: 5,
          ),
        ),
      ),
    );
  }

  //하단 탭뷰
  Widget _setTabView() {
    return TabBarView(
      children: [
        RefreshIndicator(
          //key: refreshKey,
          color: RColor.greyBasic_8c8c8c,
          backgroundColor: RColor.bgBasic_fdfdfd,
          strokeWidth: 2.0,
          displacement: 120,
          onRefresh: () async {
            if (SliverHomeWidget.globalKey.currentState != null) {
              var childCurrentState = SliverHomeWidget.globalKey.currentState;
              childCurrentState?.reload();
              await Future.delayed(const Duration(milliseconds: 1000));
            }
          },
          child: SliverHomeWidget(),
        ),
        RefreshIndicator(
          //key: refreshKey,
          color: RColor.greyBasic_8c8c8c,
          backgroundColor: RColor.bgBasic_fdfdfd,
          strokeWidth: 2.0,
          displacement: 120,
          onRefresh: () async {
            if (SliverSignalWidget.globalKey.currentState != null) {
              var childCurrentState = SliverSignalWidget.globalKey.currentState;
              childCurrentState?.reload();
              await Future.delayed(const Duration(milliseconds: 1000));
            }
          },
          child: SliverSignalWidget(),
        ),
        RefreshIndicator(
          //key: refreshKey,
          color: RColor.greyBasic_8c8c8c,
          backgroundColor: RColor.bgBasic_fdfdfd,
          strokeWidth: 2.0,
          displacement: 120,
          onRefresh: () async {
            if (SliverStockCatchWidget.globalKey.currentState != null) {
              var childCurrentState =
                  SliverStockCatchWidget.globalKey.currentState;
              childCurrentState?.reload();
              await Future.delayed(const Duration(milliseconds: 1000));
            }
          },
          child: SliverStockCatchWidget(),
        ),
        RefreshIndicator(
          //key: refreshKey,
          color: RColor.greyBasic_8c8c8c,
          backgroundColor: RColor.bgBasic_fdfdfd,
          strokeWidth: 2.0,
          displacement: 120,
          onRefresh: () async {
            if (SliverMarketWidget.globalKey.currentState != null) {
              var childCurrentState = SliverMarketWidget.globalKey.currentState;
              childCurrentState?.reload();
              await Future.delayed(const Duration(milliseconds: 1000));
            }
          },
          child: SliverMarketWidget(),
        ),
      ],
    );
  }
}
