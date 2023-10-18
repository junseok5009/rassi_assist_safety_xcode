import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/models/pg_notifier.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/home/sliver_home_page.dart';
import 'package:rassi_assist/ui/home/sliver_signal_page.dart';
import 'package:rassi_assist/ui/home/sliver_stock_catch.dart';
import 'package:rassi_assist/ui/pocket/sliver_pocket_today.dart';


/// 2023.10
/// 메인_포켓
class SliverPocketTab extends StatefulWidget {
  static const routeName = '/page_pocket_tab_sliver';
  static const String TAG = "[SliverPocketTabWidget] ";

  const SliverPocketTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SliverPocketTabWidgetState();
}

class SliverPocketTabWidgetState extends State<SliverPocketTab> {
  int initIndex = 0;
  final List<String> _tabs = ['TODAY', '나의포켓', '나만의 신호'];

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
      appBar: CommonAppbar.simpleWithAction(
        '포켓',
        [
          //알림필터
          IconButton(
            icon: const ImageIcon(
              AssetImage(
                'images/rassibs_pk_icon_ee.png',
              ),
              color: Colors.black,
              size: 19,
            ),
            onPressed: () {
              // _showScrollableSheet();
            },
          ),
          //알림수신 설정
          IconButton(
            icon: const ImageIcon(
              AssetImage(
                'images/main_arlim_icon_mdf.png',
              ),
              color: Colors.black,
              size: 20,
            ),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => const NotificationSettingN()),
              // );
            },
          ),
        ],
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
              expandedHeight: 0.0,
              pinned: true,
              floating: false,
              // backgroundColor: RColor.bgBasic_fdfdfd,
              forceElevated: innerBoxIsScrolled,
              elevation: 0,
              actions: null,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(8.0),
                child: Column(
                  children: [
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
                              // color: RColor.blackTitle_141414,
                            ),
                            // unselectedLabelColor: RColor.greyTitle_cdcdcd,
                            unselectedLabelStyle: TextStyle(
                              fontSize: 16,
                              // color: RColor.greyTitle_cdcdcd,
                            ),
                            isScrollable: true,
                            tabs: [
                              Tab(text: 'TODAY',),
                              Tab(text: '나의 포켓',),
                              Tab(text: '나만의 신호',),
                            ],
                          ),
                          Container(
                            height: 1.2,
                            color: const Color(0xffF5F5F5,),
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
        const SliverPocketTodayWidget(),
        SliverSignalWidget(),
        const SliverStockCatchWidget(),
      ],
    );
  }

}
