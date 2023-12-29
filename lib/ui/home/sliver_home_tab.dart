import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/pg_notifier.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/home/sliver_home_page.dart';
import 'package:rassi_assist/ui/home/sliver_market_page.dart';
import 'package:rassi_assist/ui/home/sliver_signal_page.dart';
import 'package:rassi_assist/ui/home/sliver_stock_catch.dart';
import 'package:rassi_assist/ui/main/search_stock_home_page.dart';

/// 2022.04.20
/// 메인_홈
class SliverHomeTabWidget extends StatefulWidget {
  static const routeName = '/page_home_tab_sliver';
  static const String TAG = "[SliverHomeTabWidget] ";

  const SliverHomeTabWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SliverHomeTabWidgetState();
}

class SliverHomeTabWidgetState extends State<SliverHomeTabWidget> {
  int initIndex = 0;
  final List<String> _tabs = ['홈', 'AI매매신호', '종목캐치', '마켓뷰'];
  final List<String> _dropdownItems = ['AI매매신호', '종목홈'];
  final List<String> _dropdownTitles = [
    '살까? 팔까? 타이밍이 궁금하세요?',
    '종목정보를 검색해 보세요!',
  ];
  String _dropdownValue = 'AI매매신호';
  int _dropdownSelectIndex = 0;

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
        Colors.white,
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
              expandedHeight: 220.0,
              pinned: true,
              floating: false,
              backgroundColor: Colors.white,
              forceElevated: innerBoxIsScrolled,
              // automaticallyImplyLeading: false,
              elevation: 1,
              actions: null,
              //가변영역 [움직이는, 숨겨지는 영역]
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.only(
                  start: 0,
                  bottom: 0,
                ),
                centerTitle: false,
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //상단 타이틀 영역 만큼의 공간[위로 숨겨지는 영역]
                    //const SizedBox(width: double.infinity, height: 60,),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Image.asset(
                          'images/logo_icon_wt.png',
                          color: RColor.mainColor,
                          height: 50,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Image.asset(
                          'images/img_rassi_title_maincolor.png',
                          height: 25,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(79),
                // [남겨지는 영역] Title bar 의 크기
                // preferredSize: Size.fromHeight(55),   // [남겨지는 영역] Title bar 의 크기
                child: Column(
                  children: [
                    _setTabSearchView(innerBoxIsScrolled),
                    Container(
                      height: 55, //[탭바]의 높이
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                      // color: RColor.bgMintWeak,
                      child: const TabBar(
                        indicatorColor: Colors.black,
                        indicatorWeight: 3,
                        labelColor: Colors.black,
                        labelStyle: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        unselectedLabelColor: Color(0xffCDCDCD),
                        unselectedLabelStyle: TextStyle(
                          fontSize: 18,
                          color: Color(0xffCDCDCD),
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
      margin: const EdgeInsets.symmetric(
        vertical: 10,
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
                'images/logo_icon_wt.png',
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
                const Color(
                  0xffF5F5F5,
                ),
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
                            const SearchStockHomePage(),
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
                                color: Color(
                                  0xffCDCDCD,
                                ),
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
            const Color(
              0xffF5F5F5,
            ),
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
        SliverHomeWidget(),
        SliverSignalWidget(),
        const SliverStockCatchWidget(),
        const SliverMarketWidget(),
      ],
    );
  }

  // 페이지 복귀 후 페이지 갱신
  _navigateSearchData(
      BuildContext context, Widget instance, PgData pgData) async {
    final result = await Navigator.push(
        context,
        _createRouteData(
            instance,
            RouteSettings(
              arguments: pgData,
            )));
    if (result == 'cancel') {
      DLog.d(SliverHomeTabWidget.TAG, '*** navigete cancel ***');
    } else {
      DLog.d(SliverHomeTabWidget.TAG, '*** navigateRefresh');

      // _pktList.clear();
      // _fetchPosts(TR.POCK03, jsonEncode(<String, String>{
      //   'userId': _userId,
      // }));
    }
  }

  //페이지 전환 에니메이션 (데이터 전달)
  Route _createRouteData(Widget instance, RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
      settings: settings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
