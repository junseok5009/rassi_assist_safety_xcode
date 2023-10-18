import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../common/d_log.dart';
import '../../common/net.dart';
import '../common/common_popup.dart';


/// 2023.10
/// 포켓_나의포켓
class SliverPocketMyWidget extends StatefulWidget {
  static const routeName = '/page_pocket_my_sliver';
  static const String TAG = "[SliverPocketMyWidget] ";
  static const String TAG_NAME = '포켓_마이포켓';

  const SliverPocketMyWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SliverPocketMyWidgetState();
}

class SliverPocketMyWidgetState extends State<SliverPocketMyWidget> {
  String _userId = '';
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            SingleChildScrollView(
              child: Column(
                children: [

                ],
              ),
            ),
          ]),
        )
      ],
    );
  }


  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {
    DLog.d(SliverPocketMyWidget.TAG, '$trStr $json');

    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
        url,
        body: json,
        headers: Net.headers,
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      if (_bYetDispose) _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      DLog.d(SliverPocketMyWidget.TAG, 'ERR : TimeoutException (12 seconds)');
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      DLog.d(SliverPocketMyWidget.TAG, 'ERR : SocketException');
      CommonPopup().showDialogNetErr(context);
    }
  }

  //
  void _parseTrData(String trStr, final http.Response response) {

  }

}