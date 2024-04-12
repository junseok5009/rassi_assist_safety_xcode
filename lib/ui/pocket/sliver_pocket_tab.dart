import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pg_notifier.dart';
import 'package:rassi_assist/provider/pocket_provider.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/pocket/sliver_pocket_my.dart';
import 'package:rassi_assist/ui/pocket/sliver_pocket_signal.dart';
import 'package:rassi_assist/ui/pocket/sliver_pocket_today.dart';

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

class SliverPocketTabWidgetState extends State<SliverPocketTab> with SingleTickerProviderStateMixin {
  late UserInfoProvider _userInfoProvider;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3,
        vsync: this,
        initialIndex: Provider.of<PageNotifier>(context, listen: false).pktIndex,
    );
    _userInfoProvider = Provider.of<UserInfoProvider>(context, listen: false);
    //_userInfoProvider.addListener(() => refreshChildWithMoveTab(Provider.of<PageNotifier>(context, listen: false).pktIndex),);
    _userInfoProvider.addListener(refreshChildWithMoveTab);
  }

  @override
  void dispose() {
    _userInfoProvider.removeListener(refreshChildWithMoveTab,);
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
        child: _setNestedScrollView(),
      ),
    );
  }

  _setTabIndex(BuildContext context) {
    int stkCount = Provider.of<PocketProvider>(context, listen: false).getAllStockListCount;
    if (stkCount == 0 && _tabController.index == 0) _tabController.animateTo(1);
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
                          TabBar(
                            controller: _tabController,
                            indicatorColor: Colors.black,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorWeight: 3,
                            labelColor: Colors.black,
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            labelStyle: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: RColor.blackTitle_141414,
                            ),
                            unselectedLabelColor: RColor.greyTitle_cdcdcd,
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 16,
                              color: RColor.greyTitle_cdcdcd,
                            ),
                            isScrollable: true,
                            tabs: const [
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
      controller: _tabController,
      children: [
        SliverPocketTodayWidget(),
        SliverPocketMyWidget(),
        SliverPocketSignalWidget(),
      ],
    );
  }

  refreshChildWithMoveTab({int moveTabIndex = 0, String changePocketSn = ''}) {
    if (moveTabIndex == 0) {
      if (SliverPocketTodayWidget.globalKey.currentState == null) {
        _tabController.animateTo(0);
      } else {
        var childCurrentState = SliverPocketTodayWidget.globalKey.currentState;
        childCurrentState?.reload();
      }
    } else if (moveTabIndex == 1) {
      if (SliverPocketMyWidget.globalKey.currentState == null) {
        if(changePocketSn.isNotEmpty){
          AppGlobal().pocketSn = changePocketSn;
        }
        _tabController.animateTo(1);
      } else {
        var childCurrentState = SliverPocketMyWidget.globalKey.currentState;
        childCurrentState?.reload(changePocketSn: changePocketSn);
      }
    } else if (moveTabIndex == 2) {
      if (SliverPocketSignalWidget.globalKey.currentState == null) {
        _tabController.animateTo(2);
      } else {
        var childCurrentState = SliverPocketSignalWidget.globalKey.currentState;
        childCurrentState?.reload();
      }
    }
  }

}
