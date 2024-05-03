import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi01.dart';
import 'package:rassi_assist/models/tr_rassi/tr_rassi02.dart';
import 'package:rassi_assist/ui/main/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/pg_data.dart';
import '../../../models/rassiro.dart';
import '../../../models/none_tr/stock/stock.dart';
import '../../common/common_popup.dart';

/// 2023.02.22_HJS
/// AI(라씨로) 속보 리스트 페이지
class StockAiBreakingNewsListPage extends StatefulWidget {
  static const String TAG_NAME = '종목_AI속보_리스트';

  const StockAiBreakingNewsListPage({Key? key}) : super(key: key);

  @override
  State<StockAiBreakingNewsListPage> createState() =>
      StockAiBreakingNewsListPageState();
}

class StockAiBreakingNewsListPageState
    extends State<StockAiBreakingNewsListPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  String _isNoData = '';
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceModel = '';

  bool _isDivStock = true;
  String _stkName = '';
  String _stkCode = '';

  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  String _pageSize = '10'; // 아이패드와 같은 긴 화면에서는 페이지 사이즈 늘려야함

  // 전체보기
  final List<Rassiro> _allRassiroList = [];
  int _allPageNo = 0;
  final int _allTotalPageSize = 19;

  // 종목선택
  final List<Rassi02> _stockRassi02List = [];
  int _stockPageNo = 0;
  int _stockTotalPageSize = 19;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      StockAiBreakingNewsListPage.TAG_NAME,
    );
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isTop = _scrollController.position.pixels == 0;
        if (!isTop) {
          _checkAndRequestTrAnything();
        }
      }
    });
    _loadPrefData().then((_) => {
          if (deviceModel.contains('iPad'))
            {
              _pageSize = '30',
            },
          Future.delayed(Duration.zero, () {
            PgData pgData = ModalRoute.of(context)!.settings.arguments as PgData;
            if (_userId != '' &&
                pgData.stockCode != null &&
                pgData.stockCode.isNotEmpty) {
              _stkName = pgData.stockName;
              _stkCode = pgData.stockCode;
              _requestTrRassi02();
            } else {
              Navigator.pop(context);
            }
          }),
        });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
    // deviceModel = iosInfo.model;
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            /*Flexible(
              child: Text(
                '$_stkName',
                style: TStyle.title18T,
                overflow: TextOverflow.ellipsis,
              ),
            ),*/
            Text(
              _stkName.length > 8
                  ? '${_stkName.substring(0, 8)} AI 속보'
                  : '$_stkName AI 속보',
              style: TStyle.title18T,
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: false,
        leadingWidth: 20,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              _setDivButtons(),
              const SizedBox(
                height: 10,
              ),
              _setListWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _setDivButtons() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: Row(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isDivStock = false;
              });
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (_allPageNo == 0)
                  _requestTrRassi01();
                else if (_scrollController.position.atEdge)
                  _checkAndRequestTrAnything();
              });
            },
            splashColor: Colors.transparent,
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Radio(
                    activeColor: RColor.mainColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),
                    value: false,
                    groupValue: _isDivStock,
                    onChanged: (value) {
                      setState(() {
                        _isDivStock = false;
                      });
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        if (_allPageNo == 0)
                          _requestTrRassi01();
                        else if (_scrollController.position.atEdge)
                          _checkAndRequestTrAnything();
                      });
                    },
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text(
                  '전체보기',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          InkWell(
            onTap: () {
              setState(() {
                _isDivStock = true;
              });
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.position.atEdge)
                  _checkAndRequestTrAnything();
              });
            },
            splashColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Radio(
                      activeColor: RColor.mainColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.minimumDensity,
                      ),
                      value: true,
                      groupValue: _isDivStock,
                      onChanged: (value) {
                        setState(() {
                          _isDivStock = true;
                        });
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.position.atEdge)
                            _checkAndRequestTrAnything();
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    '종목 선택',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                _navigateAndWaitReturn(context);
              },
              splashColor: Colors.transparent,
              child: Container(
                decoration: UIStyle.boxNewBasicGrey10(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _stkName,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.search_rounded,
                      size: 24,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _setListWidget() {
    return Expanded(
      child: Column(
        children: [
          if (((_isDivStock && _stockRassi02List.isEmpty) ||
                  (!_isDivStock && _allRassiroList.isEmpty)) &&
              _isNoData == 'Y')
            const Expanded(
              child: Center(
                child: Text('AI 속보가 없습니다.'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _isDivStock
                    ? _stockRassi02List.length
                    : _allRassiroList.length,
                itemBuilder: (context, index) {
                  return _isDivStock
                      ? TileRassi02ListItemView(
                          _stockRassi02List[index],
                        )
                      : TileRassi01ListItemView(
                          _allRassiroList[index],
                        );
                },
              ),
            ),
        ],
      ),
    );
  }

  // SearchStockPage 띄우고 navigator.pop으로부터 결과를 기다리는 메서드
  _navigateAndWaitReturn(BuildContext context) async {
    // Navigator.push는 Future를 반환합니다. Future는 선택 창에서
    // Navigator.pop이 호출된 이후 완료될 것입니다.
    final result = await Navigator.push(
      context,
      CustomNvRouteClass.createRoute(
        const SearchPage(landWhere: SearchPage.goStockHome, pocketSn: '',),
      ),
    );
    if (result != null &&
        result is Stock &&
        result.stockName.isNotEmpty &&
        result.stockCode.isNotEmpty) {
      _stkName = result.stockName;
      _stkCode = result.stockCode;
      _isDivStock = true;
      _stockRassi02List.clear();
      _stockPageNo = 0;
      _stockTotalPageSize = 19;
      _requestTrRassi02();
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    }
  }

  _checkAndRequestTrAnything() {
    if (_isDivStock && _stockPageNo < _stockTotalPageSize) {
      _stockRassi02List.removeLast();
      _requestTrRassi02();
    } else if (!_isDivStock && _allPageNo < _allTotalPageSize) {
      _allRassiroList.removeLast();
      _requestTrRassi01();
    }
  }

  _requestTrRassi01() {
    _fetchPosts(
        TR.RASSI01,
        jsonEncode(<String, String>{
          'userId': _userId,
          'pageNo': '$_allPageNo',
          'pageItemSize': _pageSize,
        }));
  }

  _requestTrRassi02() {
    _fetchPosts(
        TR.RASSI02,
        jsonEncode(<String, String>{
          'userId': _userId,
          'stockCode': _stkCode,
          'pageNo': '$_stockPageNo',
          'pageItemSize': _pageSize,
        }));
  }

  //convert 패키지의 jsonDecode 사용
  void _fetchPosts(String trStr, String json) async {

    try {
      var url = Uri.parse(Net.TR_BASE + trStr);
      final http.Response response = await http.post(
        url,
        body: json,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));
      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    if (trStr == TR.RASSI02) {
      final TrRassi02 resData = TrRassi02.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        //_stockTotalPageSize = int.parse(resData.listData.totalPageSize);
        _stockPageNo++;
        if (resData.listData.length > 0) {
          _isNoData = 'N';
          _stockRassi02List.addAll(
            resData.listData,
          );
          if (_stockPageNo < _stockTotalPageSize)
            _stockRassi02List.add(Rassi02());
        }
      } else {
        _stockRassi02List.clear();
        _isNoData = 'Y';
      }
      setState(() {});
    } else if (trStr == TR.RASSI01) {
      final TrRassi01 resData = TrRassi01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        //_stockTotalPageSize = int.parse(resData.listData.totalPageSize);
        _allPageNo++;
        if (resData.listData.length > 0) {
          _isNoData = 'N';
          _allRassiroList.addAll(
            resData.listData,
          );
          if (_allPageNo < _allTotalPageSize) _allRassiroList.add(Rassiro());
        }
      } else {
        _allRassiroList.clear();
        _isNoData = 'Y';
      }
      setState(() {});
    }
  }
}
