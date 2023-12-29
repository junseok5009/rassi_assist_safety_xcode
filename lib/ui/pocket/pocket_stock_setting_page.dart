import 'dart:io';

import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/pocket.dart';
import 'package:rassi_assist/provider/pocket_provider.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/common/common_view.dart';

import '../../common/common_class.dart';

/// 2021.01.25 > 나의_종목_설정
/// 2023.11.29 HJS 개편 > 포켓 종목 설정

class PocketStockSettingPage extends StatefulWidget {
  //const PocketStockSettingPage({Key key}) : super(key: key);
  static const String TAG = "[PocketStkSeqPage]";
  static const String TAG_NAME = '포켓_종목_설정';

  final String pocketSn;

  const PocketStockSettingPage(this.pocketSn, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PocketStockSettingPageState();
}

class PocketStockSettingPageState extends State<PocketStockSettingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _isChangedOrder = false; // 순서 변경 여부
  bool _isChangedTrash = false; // 삭제하기 변경 여부

  late PocketProvider _pocketProvider;
  late Pocket _pocket;
  List<Stock> _stockList = []; // 종목 리스트

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      PocketStockSettingPage.TAG_NAME,
    );
    _pocketProvider = Provider.of<PocketProvider>(context, listen: false);
    try {
      _pocket = _pocketProvider.getPocketList
          .singleWhere((element) => element.pktSn == widget.pocketSn);
    } on Exception catch (_, __) {}
    if (_pocket == null) {
      commonShowToast('포켓 에러\n고객센터에 문의해 주세요.');
      Navigator.pop(context, CustomNvRouteResult.refresh);
    } else {
      _stockList = _pocket.stkList
          .map((e) => Stock(
                stockCode: e.stockCode,
                stockName: e.stockName,
              ))
          .toList();
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget _pageChildWidget() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            '포켓 종목 설정',
            style: TStyle.commonTitle,
          ),
          leading: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              deleteProcess(true);
            },
            child: const Icon(
              Icons.arrow_back_ios_sharp,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 1,
          centerTitle: false,
          leadingWidth: 40,
          titleSpacing: 5.0,
        ),
      ),
      backgroundColor: RColor.bgBasic_fdfdfd,
      body: SafeArea(
        child: Column(
          children: [
            if (_stockList.isEmpty)
              CommonView.setNoDataTextView(
                  200, '포켓에 종목이 없습니다.\n먼저 포켓에 종목을 추가해주세요.')
            else
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                width: double.infinity,
                child: const Text(
                  '종목명 부분을 터치한 상태에서 상하로 움직여 포켓의 순서를 변경하실 수 있습니다.',
                  style: TStyle.textMGrey,
                ),
              ),
            Expanded(
              child: _setReorderableList(),
            ),
            Visibility(
              visible: _isChangedOrder || _isChangedTrash,
              child: const SizedBox(
                height: 60,
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _isChangedOrder || _isChangedTrash
          ? BottomSheet(
              backgroundColor: Colors.transparent,
              builder: (bsContext) => InkWell(
                onTap: () {
                  deleteProcess(false);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  //color: RColor.mainColor,
                  decoration: const BoxDecoration(
                    color: RColor.mainColor,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  margin: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: MediaQuery.of(_scaffoldKey.currentState!.context)
                        .viewPadding
                        .bottom + 10,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '저장하기',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              onClosing: () {},
              enableDrag: false,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConditionalWillPopScope(
      onWillPop: () {
        if (Platform.isAndroid) {
          deleteProcess(true);
        }
        return Future.value(false);
      },
      shouldAddCallback: true,
      child: Platform.isIOS
          ? GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.velocity.pixelsPerSecond.dx > 20) {
                  deleteProcess(true);
                }
              },
              child: _pageChildWidget(),
            )
          : _pageChildWidget(),
    );
  }

  //리스트 순서 변경 리스트
  Widget _setReorderableList() {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      child: ReorderableListView(
        shrinkWrap: true,
        onReorder: (int start, int current) {
          //dragging from top to bottom
          if (start < current) {
            int end = current - 1;
            Stock startItem = _stockList[start];
            int i = 0;
            int local = start;
            do {
              _stockList[local] = _stockList[++local];
              i++;
            } while (i < end - start);
            _stockList[end] = startItem;
          }
          //dragging from bottom to top
          else if (start > current) {
            Stock startItem = _stockList[start];
            for (int i = start; i > current; i--) {
              _stockList[i] = _stockList[i - 1];
            }
            _stockList[current] = startItem;
          }

          if (areListsEqualOrder(_stockList, _pocket.stkList)) {
            _isChangedOrder = false;
          } else {
            _isChangedOrder = true;
          }
          setState(() {});

          for (int j = 0; j < _stockList.length; j++) {
            DLog.d(PocketStockSettingPage.TAG, _stockList[j].toString());
          }
        },
        children: _stockList.map((item) => _setListItem(item)).toList(),
      ),
    );
  }

  bool areListsEqualOrder(List<Stock> a, List<Stock> b) {
    if (a == b) {
      return true;
    }
    if (a == null || b == null || a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i].stockCode != b[i].stockCode) {
        return false;
      }
    }
    return true;
  }

  //리스트 아이템 설정
  Widget _setListItem(Stock item) {
    return Container(
      key: Key(item.stockCode),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7.5,),
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: 65,
        padding: const EdgeInsets.only(left: 20, right: 12,),
        decoration: UIStyle.boxShadowBasic(16),
        child: SizedBox(
          width: double.infinity,
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/main_jm_icon_list_awtb.png',
                      height: 19,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 15.0,
                    ),
                    Flexible(
                      flex: 1,
                      child: Text(
                        item.stockName,
                        style: TStyle.commonTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      item.stockCode,
                      style: TStyle.textSGrey,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 15.0,
              ),
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    item.isDelete
                        ? 'images/icon_trash_can_main.png'
                        : 'images/icon_trash_can_grey.png',
                    height: 19,
                  ),
                ),
                onTap: () {
                  if (item.isDelete) {
                    item.isDelete = false;
                    if (!_stockList.any(
                      (stock) => stock.isDelete == true,
                    )) {
                      _isChangedTrash = false;
                    }
                  } else {
                    item.isDelete = true;
                    _isChangedTrash = true;
                  }
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getTrashStockCount() {
    if (_isChangedTrash) {
      int count = 0;
      for (var element in _stockList) {
        if (element.isDelete) count++;
      }
      return count;
    } else {
      return 0;
    }
  }

  deleteProcess(bool goBack) async {
    if (_isChangedTrash || _isChangedOrder) {
      var result = await _showDelStock();
      if (context.mounted && result != null) {
        if (result == CustomNvRouteResult.refresh) {
          if (_isChangedOrder) {
            bool result = await _pocketProvider.changeOrderStock(
                _pocket.pktSn, _stockList);
            if (!result) {
              if (context.mounted) {
                CommonPopup.instance.showDialogBasic(
                    context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
              }
            }
            _isChangedOrder = false;
          }
          if (_isChangedTrash) {
            String result = await _pocketProvider.deleteListStock(
                _pocket.pktSn, _stockList);
            if (context.mounted && result != null) {
             if (result == CustomNvRouteResult.refresh) {
                //
              } else if (result == CustomNvRouteResult.fail) {
                CommonPopup.instance.showDialogBasic(
                    context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
              } else {
                CommonPopup.instance.showDialogBasic(context, '안내', result);
              }
            }
            _isChangedTrash = false;
          }
          setState(() {
            _stockList = _pocket.stkList
                .map(
                  (e) => Stock(
                    stockCode: e.stockCode,
                    stockName: e.stockName,
                  ),
                )
                .toList();
          });
        } else if (result == CustomNvRouteResult.cancel) {
          if (goBack) {
            Navigator.pop(context, CustomNvRouteResult.cancel);
          }
        } else {
          Navigator.pop(context, CustomNvRouteResult.refresh);
        }
      }
    } else {
      Navigator.pop(context, CustomNvRouteResult.cancel);
    }
  }

  //포켓 삭제 다이얼로그
  Future<String> _showDelStock() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                ),
                onTap: () {
                  Navigator.pop(context, CustomNvRouteResult.cancel);
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '알림',
                    style: TStyle.title18T,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    !_isChangedTrash
                        ? '종목의 순서를 저장하시겠습니까?'
                        : '선택하신 ${_getTrashStockCount()}개의 종목을\n삭제하시겠습니까?',
                    textAlign: TextAlign.center,
                    style: TStyle.content15,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 12,
                      ),
                      decoration: UIStyle.boxRoundFullColor50c(
                        RColor.mainColor,
                      ),
                      child: Text(
                        !_isChangedTrash ? '저장하기' : '삭제하기',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context, CustomNvRouteResult.refresh);
                    },
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then(
      (value) {
        if (value != null) {
          return value;
        } else {
          return CustomNvRouteResult.cancel;
        }
      },
    );
  }
}
