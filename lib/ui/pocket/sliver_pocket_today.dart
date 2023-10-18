import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../../common/d_log.dart';
import '../../common/net.dart';
import '../common/common_popup.dart';
import '../home/home_tile/home_tile_mystock_status.dart';


/// 2023.10
/// 포켓_TODAY
class SliverPocketTodayWidget extends StatefulWidget {
  static const routeName = '/page_pocket_today_sliver';
  static const String TAG = "[SliverPocketTodayWidget] ";
  static const String TAG_NAME = '포켓_TODAY';

  const SliverPocketTodayWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SliverPocketTodayWidgetState();
}

class SliverPocketTodayWidgetState extends State<SliverPocketTodayWidget> {
  String _userId = '';
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전


  @override
  void dispose() {
    _bYetDispose = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(
              height: 15,
            ),


            // 내 종목 현황
            const HomeTileMystockStatus(),

          ]),
        ),
      ],
    );
  }



  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(SliverPocketTodayWidget.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if (_bYetDispose) _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      DLog.d(SliverPocketTodayWidget.TAG, 'ERR : TimeoutException (12 seconds)');
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      DLog.d(SliverPocketTodayWidget.TAG, 'ERR : SocketException');
      CommonPopup().showDialogNetErr(context);
    }
  }

  //
  void _parseTrData(String trStr, final http.Response response) {

  }

}
