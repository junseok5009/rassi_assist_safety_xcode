import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock08.dart';
import 'package:rassi_assist/provider/pocket_provider.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';

class PocketThreeStockSettingPage extends StatefulWidget {
  const PocketThreeStockSettingPage({Key? key}) : super(key: key);

  //const PocketThreeStockSettingPage({super.key});

  @override
  State<PocketThreeStockSettingPage> createState() =>
      _Pocket3StockSettingPageState();
}

class _Pocket3StockSettingPageState extends State<PocketThreeStockSettingPage> {
  late PocketProvider _pocketProvider;
  final List<PocketSignalStock> _stkList = [];
  final List<Stock> _alarmOnStkList = [];
  final List<Stock> _originalAlarmOnStkList = [];
  bool _isFaVisible = true;

  @override
  void initState() {
    super.initState();
    _pocketProvider = Provider.of<PocketProvider>(context, listen: false);
    _fetchPosts(
        TR.POCK08,
        jsonEncode(<String, String>{
          'userId': AppGlobal().userId,
          'pocketSn': _pocketProvider.getPocketList[0].pktSn,
        }));
  }

  @override
  void setState(VoidCallback fn) {
    if (context.mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar.basic(context, '3종목 알림 설정'),
      backgroundColor: RColor.bgBasic_fdfdfd,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.forward &&
              !_isFaVisible) {
            setState(() {
              _isFaVisible = true;
            });
          } else if (notification.direction == ScrollDirection.reverse &&
              _isFaVisible) {
            setState(() {
              _isFaVisible = false;
            });
          }
          return true;
        },
        child: SafeArea(
           child: NestedScrollView(
            physics: const RangeMaintainingScrollPhysics(),
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                snap: true,
                toolbarHeight: 70,
                backgroundColor: Colors.transparent,
                title: null,
                actions: null,
                leading: null,
                automaticallyImplyLeading: false,
                flexibleSpace: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  alignment: Alignment.bottomCenter,
                  child: Wrap(
                    children: const [
                      Text(
                          'AI매매신호를 이용하실 종목을 선택하신 후 등록하기를 눌러주세요. 3종목까지 선택이 가능합니다.'),
                    ],
                  ),
                ),
              ),
            ],
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _stkList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) => _setListItemView(
                      index,
                      _stkList[index],
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: (p0, p1) {
                    bool alarmCanRegisterCheck = _alarmCanRegisterCheck;
                    return InkWell(
                      onTap: () async {
                        if (alarmCanRegisterCheck) {
                          String result = await _pocketProvider
                              .changeAlarmListStock(_alarmOnStkList);
                          if (context.mounted && result != null) {
                            if (result == CustomNvRouteResult.refresh) {
                              await CommonPopup.instance.showDialogBasicConfirm(
                                  context, '안내', '등록되었습니다.');
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            } else if (result == CustomNvRouteResult.fail) {
                              CommonPopup.instance.showDialogBasic(context,
                                  '안내', CommonPopup.dbEtcErroruserCenterMsg);
                            } else {
                              CommonPopup.instance
                                  .showDialogBasic(context, '안내', result);
                            }
                          }
                        }
                      },
                      child: AnimatedContainer(
                        width: double.infinity,
                        height: _isFaVisible ? 50 : 0,
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: alarmCanRegisterCheck
                              ? RColor.mainColor
                              : RColor.greyBoxLine_c9c9c9,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50)),
                        ),
                        margin: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '등록하기',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: const Text(
                    '3종목 알림 설정은 1일 1회 가능합니다.\n여러 종목을 변경하실 경우, 모든 종목의 알림을 설정하신 후 등록하세요.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      //floatingActionButton:
    );
  }

  Widget _setListItemView(int index, PocketSignalStock stock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: EdgeInsets.fromLTRB(
          20, index == 0 ? 10 : 15, 20, index == _stkList.length - 1 ? 10 : 0),
      decoration: UIStyle.boxShadowBasic(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //종목명, 종목코드
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    stock.stockName,
                    style: TStyle.subTitle16,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  stock.stockCode,
                  style: const TextStyle(
                    fontSize: 12,
                    color: RColor.greyBasic_8c8c8c,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              if (stock.signalYn == 'Y') {
                _alarmOff(stock);
              } else {
                if (_alarmOnStkList.length >= 3) {
                  CommonPopup.instance.showDialogBasic(context, '알림',
                      '3종목이 모두 설정되어 있습니다.\n먼저 설정된 종목을 해제 후 설정해 주세요.');
                } else {
                  _alarmOn(stock);
                }
              }
            },
            child: Image.asset(
              stock.signalYn == 'Y'
                  ? 'images/icon_alarm_purple.png'
                  : 'images/icon_alarm_grey.png',
              height: 28,
            ),
          ),
        ],
      ),
    );
  }

  void _alarmOn(PocketSignalStock item) {
    item.signalYn = 'Y';
    _alarmOnStkList.add(item);
    if (!_isFaVisible) {
      _isFaVisible = true;
    }
    setState(() {});
  }

  void _alarmOff(PocketSignalStock item) {
    item.signalYn = 'N';
    _alarmOnStkList.remove(item);
    if (!_isFaVisible) {
      _isFaVisible = true;
    }
    setState(() {});
  }

  bool get _alarmCanRegisterCheck {
    if (_originalAlarmOnStkList.length == _alarmOnStkList.length) {
      bool isSame = true;
      for (var element1 in _originalAlarmOnStkList) {
        bool isSameSmall = false;
        for (var element2 in _alarmOnStkList) {
          if (element1.stockCode == element2.stockCode) {
            isSameSmall = true;
            break;
          }
        }
        if (!isSameSmall) {
          isSame = false;
          break;
        }
      }
      return !isSame;
    } else {
      return true;
    }
  }

  void _fetchPosts(String trStr, String json) async {
    var url = Uri.parse(Net.TR_BASE + trStr);
    try {
      final http.Response response = await http.post(
            url,
            body: json,
            headers: Net.headers,
          ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.e(response.body.toString());
    if (trStr == TR.POCK08) {
      final TrPock08 resData = TrPock08.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        _stkList.addAll(resData.retData!.stkList);
        for (PocketSignalStock item in _stkList) {
          if (item.signalYn == 'Y') {
            _alarmOnStkList.add(item);
            _originalAlarmOnStkList.add(item);
          }
        }
        setState(() {});
      }
    }
  }
}
