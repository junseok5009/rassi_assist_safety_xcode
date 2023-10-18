import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/stock.dart';
import 'package:rassi_assist/models/tr_report04.dart';
import 'package:rassi_assist/ui/main/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 23.02.10 HJS
/// 종목홈_리포트 분석_최신 리포트 리스트 화면
class StockRecentReportListPage extends StatefulWidget {
  static const String TAG_NAME = '종목_최신_리포트_리스트';

  @override
  State<StockRecentReportListPage> createState() =>
      _StockRecentReportListPageState();
}

class _StockRecentReportListPageState extends State<StockRecentReportListPage> {
  late SharedPreferences _prefs;
  String _userId = '';
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceModel = '';

  bool _isDivStock = true;
  String _stkName = '';
  String _stkCode = '';

  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  String _pageSize = '10'; // 아이패드와 같은 긴 화면에서는 페이지 사이즈 늘려야함

  // 전체보기
  final List<Report04Report> _allReportList = [];
  int _allPageNo = 0;
  int _allTotalPageSize = 0;

  // 종목선택
  final List<Report04Report> _stockReportList = [];
  int _stockPageNo = 0;
  int _stockTotalPageSize = 0;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      StockRecentReportListPage.TAG_NAME,
    );
    _scrollController.addListener(() {
      if (_scrollController.hasClients && _scrollController.position.atEdge) {
        bool isTop = _scrollController.position.pixels == 0;
        if (!isTop) {
          _checkAndRequestTrReport04();
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
              _requestTrReport04();
            } else {
              Navigator.pop(context);
            }
          }),
        });
  }

  // 저장된 데이터를 가져오는 것에 시간이 필요함
  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    if (_bYetDispose) {
      _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
      deviceModel = iosInfo.model!;
    }
  }

  @override
  void dispose() {
    _bYetDispose = false;
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
        title: Text(
          _stkName.length > 8
              ? '${_stkName.substring(0, 8)} 최신 리포트'
              : '$_stkName 최신 리포트',
          style: TStyle.title18T,
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
                  _requestTrReport04();
                else if (_scrollController.hasClients &&
                    _scrollController.position.atEdge)
                  _checkAndRequestTrReport04();
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
                          _requestTrReport04();
                        else if (_scrollController.hasClients &&
                            _scrollController.position.atEdge)
                          _checkAndRequestTrReport04();
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
                if (_scrollController.hasClients &&
                    _scrollController.position.atEdge)
                  _checkAndRequestTrReport04();
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
                          if (_scrollController.hasClients &&
                              _scrollController.position.atEdge)
                            _checkAndRequestTrReport04();
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
          if (((_isDivStock && _stockReportList.length < 1) ||
              (!_isDivStock && _allReportList.length < 1)))
            /* Expanded(
              child: Center(
                child: Text('최신 리포트가 없습니다.'),
              ),
            )*/
            _setNoDataView()
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _isDivStock
                    ? _stockReportList.length
                    : _allReportList.length,
                itemBuilder: (context, index) => TileReport04ListItemView(
                    _isDivStock
                        ? _stockReportList[index]
                        : _allReportList[index]),
              ),
            ),
        ],
      ),
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
                style: TextStyle(
                    fontSize: 18, color: RColor.new_basic_text_color_grey),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            '최신 리포트가 없습니다.',
            style: TextStyle(
                fontSize: 14, color: RColor.new_basic_text_color_grey),
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
      commonPageRouteFromBottomToUpWithSettings(
        SearchPage(),
        PgData(
          pgSn: '',
        ),
      ),
    );

    if (result != null &&
        result is Stock &&
        result.stockName.isNotEmpty &&
        result.stockCode.isNotEmpty) {
      _stkName = result.stockName;
      _stkCode = result.stockCode;
      _isDivStock = true;
      _stockReportList.clear();
      _stockPageNo = 0;
      _stockTotalPageSize = 0;
      _requestTrReport04();
      if (_scrollController.hasClients)
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    }
  }

  _checkAndRequestTrReport04() {
    if (_isDivStock && _stockPageNo < _stockTotalPageSize) {
      _stockReportList.removeLast();
      _requestTrReport04();
    } else if (!_isDivStock && _allPageNo < _allTotalPageSize) {
      _allReportList.removeLast();
      _requestTrReport04();
    }
  }

  _requestTrReport04() {
    _fetchPosts(
        TR.REPORT04,
        jsonEncode(<String, String>{
          'userId': _userId,
          'stockCode': _isDivStock ? _stkCode : '',
          'pageNo': _isDivStock ? '$_stockPageNo' : '$_allPageNo',
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

      if (_bYetDispose) _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup().showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup().showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    if (trStr == TR.REPORT04) {
      final TrReport04 resData = TrReport04.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Report04 report04 = resData.retData;
        if (_isDivStock) {
          _stockPageNo++;
          _stockTotalPageSize = int.parse(report04.totalPageSize);
          //if(_stockPageNo == 0) _stockPageNo++;
          if (report04.listReport.length > 0) {
            _stockReportList.addAll(
              report04.listReport,
            );
            if (_stockPageNo < _stockTotalPageSize)
              _stockReportList.add(Report04Report());
          }
        } else {
          _allPageNo++;
          _allTotalPageSize = int.parse(report04.totalPageSize);
          //if(_allPageNo == 0) _allPageNo++;
          if (report04.listReport.length > 0) {
            _allReportList.addAll(
              report04.listReport,
            );
            if (_allPageNo < _allTotalPageSize)
              _allReportList.add(Report04Report());
          }
        }
        setState(() {});
      } else {
        if (_isDivStock && _stockPageNo == 0) {
          _stockReportList.clear();
        } else if (!_isDivStock && _allPageNo == 0) {
          _allReportList.clear();
        }
        setState(() {});
      }
    }
  }
}
