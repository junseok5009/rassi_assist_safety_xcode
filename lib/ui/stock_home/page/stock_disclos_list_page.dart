import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/models/tr_disclos01.dart';
import 'package:rassi_assist/ui/main/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/pg_data.dart';
import '../../../models/stock.dart';

/// 23.02.10 HJS
/// 공시 리스트 화면
class StockDisclosListPage extends StatefulWidget {
  //const StockDisclosListPage({Key? key}) : super(key: key);
  static const String TAG_NAME = '종목_공시_리스트';

  const StockDisclosListPage({super.key});

  @override
  State<StockDisclosListPage> createState() => _StockDisclosListPageState();
}

class _StockDisclosListPageState extends State<StockDisclosListPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  bool _bYetDispose = true; //true: 아직 화면이 사라지기 전
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
  final List<Disclos> _allDisclostList = [];
  int _allPageNo = 0;
  int _allTotalPageSize = 0;

  // 종목선택
  final List<Disclos> _stockDisclosList = [];
  int _stockPageNo = 0;
  int _stockTotalPageSize = 0;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      StockDisclosListPage.TAG_NAME,
    );
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isTop = _scrollController.position.pixels == 0;
        if (!isTop) {
          _checkAndRequestTrDisclos01();
        }
      }
    });
    _loadPrefData().then((_) => {
          if (deviceModel.contains('iPad'))
            {
              _pageSize = '30',
            },
          Future.delayed(Duration.zero, () {
            PgData _pgData = ModalRoute.of(context)!.settings.arguments as PgData;
            if (_userId != '' &&
                _pgData.stockCode != null &&
                _pgData.stockCode.isNotEmpty) {
              _stkName = _pgData.stockName;
              _stkCode = _pgData.stockCode;
              _requestTrDisclos01();
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
      deviceModel = (iosInfo.model) ?? '';
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
                  ? '${_stkName.substring(0, 8)} 공시'
                  : '$_stkName 공시',
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
                if (_allPageNo == 0) {
                  _requestTrDisclos01();
                } else if (_scrollController.position.atEdge) {
                  _checkAndRequestTrDisclos01();
                }
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
                        if (_allPageNo == 0) {
                          _requestTrDisclos01();
                        } else if (_scrollController.position.atEdge) {
                          _checkAndRequestTrDisclos01();
                        }
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
                if (_scrollController.position.atEdge) {
                  _checkAndRequestTrDisclos01();
                }
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
                          if (_scrollController.position.atEdge) {
                            _checkAndRequestTrDisclos01();
                          }
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
          if (((_isDivStock && _stockDisclosList.length < 1) ||
                  (!_isDivStock && _allDisclostList.length < 1)) &&
              _isNoData == 'Y')
            const Expanded(
              child: Center(
                child: Text('공시가 없습니다.'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _isDivStock
                    ? _stockDisclosList.length
                    : _allDisclostList.length,
                itemBuilder: (context, index) => TileDisclos01ListItemView(
                    _isDivStock
                        ? _stockDisclosList[index]
                        : _allDisclostList[index]),
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
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SearchPage(),
          settings: RouteSettings(
            arguments: PgData(
              pgSn: '',
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(0.0, 1.0);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.ease));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ));
    if (result != null &&
        result is Stock &&
        result.stockName.isNotEmpty &&
        result.stockCode.isNotEmpty) {
      _stkName = result.stockName;
      _stkCode = result.stockCode;
      _isDivStock = true;
      _stockDisclosList.clear();
      _stockPageNo = 0;
      _stockTotalPageSize = 0;
      _requestTrDisclos01();
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    }
  }

  _checkAndRequestTrDisclos01() {
    if (_isDivStock && _stockPageNo < _stockTotalPageSize) {
      _stockDisclosList.removeLast();
      _requestTrDisclos01();
    } else if (!_isDivStock && _allPageNo < _allTotalPageSize) {
      _allDisclostList.removeLast();
      _requestTrDisclos01();
    }
  }

  _requestTrDisclos01() {
    _fetchPosts(
        TR.DISCLOS01,
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

  // 비동기적으로 들어오는 데이터를 어떻게 처리할 것인지 더 생각
  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    if (trStr == TR.DISCLOS01) {
      final TrDisclos01 resData =
          TrDisclos01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Disclos01 disclos01 = resData.retData;
        if (_isDivStock) {
          _stockPageNo++;
          _stockTotalPageSize = int.parse(disclos01.totalPageSize);
          if (disclos01.listDisclos.length > 0) {
            _isNoData = 'N';
            _stockDisclosList.addAll(
              disclos01.listDisclos,
            );
            if (_stockPageNo < _stockTotalPageSize)
              _stockDisclosList.add(Disclos());
          }
        } else {
          _allPageNo++;
          _allTotalPageSize = int.parse(disclos01.totalPageSize);
          //if(_allPageNo == 0) _allPageNo++;
          if (disclos01.listDisclos.length > 0) {
            _isNoData = 'N';
            _allDisclostList.addAll(
              disclos01.listDisclos,
            );
            if (_allPageNo < _allTotalPageSize) _allDisclostList.add(Disclos());
          }
        }
        setState(() {});
      } else {
        if (_isDivStock && _stockPageNo == 0) {
          _stockDisclosList.clear();
          _isNoData = 'Y';
        } else if (!_isDivStock && _allPageNo == 0) {
          _allDisclostList.clear();
          _isNoData = 'Y';
        }
        setState(() {});
      }
    }
  }
}
