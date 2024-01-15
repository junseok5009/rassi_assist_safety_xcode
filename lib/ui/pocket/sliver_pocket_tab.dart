import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/models/pg_notifier.dart';
import 'package:rassi_assist/provider/pocket_provider.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/pocket/pocket_setting_page.dart';
import 'package:rassi_assist/ui/pocket/sliver_pocket_my.dart';
import 'package:rassi_assist/ui/pocket/sliver_pocket_signal.dart';
import 'package:rassi_assist/ui/pocket/sliver_pocket_today.dart';

import '../common/common_appbar.dart';

/// 2023.10
/// 메인_포켓
class SliverPocketTab extends StatefulWidget {
  static const routeName = '/page_pocket_tab_sliver';
  static const String TAG = "[SliverPocketTabWidget] ";

  static final GlobalKey<SliverPocketTabWidgetState> globalKey = GlobalKey();

  SliverPocketTab({Key? key}) : super(key: globalKey);

  @override
  State<StatefulWidget> createState() => SliverPocketTabWidgetState();
}

class SliverPocketTabWidgetState extends State<SliverPocketTab> {
  int initIndex = 0;
  final List<String> _tabs = [' TODAY', ' 나의포켓', ' 나만의 신호'];
  late UserInfoProvider _userInfoProvider;

  @override
  void initState() {
    super.initState();
    _userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
    _userInfoProvider.addListener(refreshChild);
  }

  @override
  void dispose() {
    _userInfoProvider.removeListener(refreshChild);
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
    _setTabIndex(context);
    return Scaffold(
      // appBar: _setAppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: DefaultTabController(
          initialIndex: initIndex,
          length: _tabs.length,
          child: _setNestedScrollView(),
        ),
      ),
    );
  }

  _setTabIndex(BuildContext context) {
    initIndex = Provider.of<PageNotifier>(context, listen: false).pktIndex;
    int stkCount = Provider.of<PocketProvider>(context, listen: false)
        .getAllStockListCount;
    if (stkCount == 0) initIndex = 1;
  }

  Widget _setAppBar() {
    return CommonAppbar.simpleWithAction(
      '포켓',
      [
        // 종목추가
        InkWell(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              ImageIcon(
                AssetImage(
                  'images/rassibs_pk_icon_plu.png',
                ),
                color: Colors.grey,
                size: 16,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                '종목추가',
                style: TextStyle(
                  color: RColor.greyMore_999999,
                ),
              ),
            ],
          ),
          onTap: () async {
/*            Navigator.push(
              context,
              CustomNvRouteClass.createRoute(
                SearchPage.goLayer(SearchPage.landAddPocketLayer, ''),
              ),
            );*/
          },
        ),
        const SizedBox(
          width: 15,
        ),

        // 설정
        InkWell(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              ImageIcon(
                AssetImage(
                  'images/main_arlim_icon_mdf.png',
                ),
                color: Colors.grey,
                size: 16,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                '포켓설정',
                style: TextStyle(
                  color: RColor.greyMore_999999,
                ),
              ),
            ],
          ),
          onTap: () {
            // 포켓 설정
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PocketSettingPage(),
              ),
            );
          },
        ),
        const SizedBox(
          width: 15,
        )
      ],
    );
  }

  Widget _setNestedScrollView() {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              expandedHeight: 0.0,
              pinned: true,
              floating: false,
              backgroundColor: RColor.bgBasic_fdfdfd,
              forceElevated: innerBoxIsScrolled,
              elevation: 0,
              actions: null,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0.5),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50.2, //[탭바]의 높이
                      //padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                      child: Column(
                        children: [
                          const TabBar(
                            indicatorColor: Colors.black,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorWeight: 3,
                            labelColor: Colors.black,
                            labelPadding: EdgeInsets.symmetric(horizontal: 10),
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
                                width: 67,
                                child: Tab(
                                  text: 'TODAY',
                                ),
                              ),
                              SizedBox(
                                width: 67,
                                child: Tab(
                                  text: '나의 포켓',
                                ),
                              ),
                              Tab(
                                text: '나만의 신호',
                              ),
                            ],
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

  //하단 탭뷰
  Widget _setTabView() {
    return TabBarView(
      children: [
        SliverPocketTodayWidget(),
        SliverPocketMyWidget(),
        SliverPocketSignalWidget(),
      ],
    );
  }

  refreshChild() {
    if (SliverPocketTodayWidget.globalKey.currentState != null) {
      var childCurrentState = SliverPocketTodayWidget.globalKey.currentState;
      childCurrentState?.reload();
    } else if (SliverPocketMyWidget.globalKey.currentState != null) {
      var childCurrentState = SliverPocketMyWidget.globalKey.currentState;
      childCurrentState?.reload();
    } else if (SliverPocketSignalWidget.globalKey.currentState != null) {
      var childCurrentState = SliverPocketSignalWidget.globalKey.currentState;
      childCurrentState?.reload();
    }
  }
}
