import 'dart:io';

import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pocket.dart';
import 'package:rassi_assist/provider/pocket_provider.dart';
import 'package:rassi_assist/ui/common/common_layer.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/pocket/pocket_stock_setting_page.dart';

/// 2021.01.25 > 나의_종목_포켓_설정
/// 2023.11.28 HJS 개편 > 포켓 설정

class PocketSettingPage extends StatefulWidget {
  const PocketSettingPage({Key? key}) : super(key: key);

  static const routeName = '/page_pocket_setting';
  static const String TAG = "[PocketSettingPage]";
  static const String TAG_NAME = '포켓_설정';

  @override
  State<StatefulWidget> createState() => PocketSettingPageState();
}

class PocketSettingPageState extends State<PocketSettingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _isChangedOrder = false; // 순서 변경 여부
  bool _isChangedTrash = false; // 삭제하기 변경 여부

  late PocketProvider _pocketProvider;
  List<Pocket> _pktList = []; //포켓리스트

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      PocketSettingPage.TAG_NAME,
    );
    _pocketProvider = Provider.of<PocketProvider>(context, listen: false);
    _pktList = _pocketProvider.getPocketList
        .map((e) => Pocket.withStockList(e.pktSn, e.pktName, e.stkList))
        .toList();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
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

  Widget _pageChildWidget() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            '포켓 설정',
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
          actions: [
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () async {
                var pocketProvider =
                    Provider.of<PocketProvider>(context, listen: false);
                if (AppGlobal().isPremium) {
                  if (pocketProvider.getPocketList.length >= 10) {
                    commonShowToastCenter('생성 가능한 포켓의 개수는 최대 10개 입니다.');
                  } else {
                    String result =
                        await CommonLayer.instance.showLayerAddPocket(context);
                    if (result != null &&
                        result == CustomNvRouteResult.refresh) {
                      // [포켓 > 나의포켓 > 포켓선택 (새로 만든 포켓이 선택)]
                      if (mounted) {
                        Navigator.pop(context);
                      }
                      /* setState(() {
                        _pktList = _pocketProvider.getPocketList
                            .map((e) => Pocket.withStockList(e.pktSn, e.pktName, e.stkList))
                            .toList();
                      });*/
                    }
                  }
                } else {
                  // 프리미엄 팝업
                  String result =
                      await CommonPopup.instance.showDialogPremium(context);
                  if (result == CustomNvRouteResult.landPremiumPage) {
                    basePageState.navigateAndGetResultPayPremiumPage();
                  }
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/icon_folder_plus.png',
                    fit: BoxFit.cover,
                    height: 18,
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  const Text(
                    '포켓 더 만들기',
                    style: TextStyle(
                      fontSize: 14,
                      color: RColor.greyBasic_8c8c8c,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
          ],
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
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              width: double.infinity,
              child: const Text(
                '포켓명 부분을 터치한 상태에서 상하로 움직여 포켓의 순서를 변경하실 수 있습니다.',
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
                            .bottom +
                        10,
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
            Pocket startItem = _pktList[start];
            int i = 0;
            int local = start;
            do {
              _pktList[local] = _pktList[++local];
              i++;
            } while (i < end - start);
            _pktList[end] = startItem;
          }
          //dragging from bottom to top
          else if (start > current) {
            Pocket startItem = _pktList[start];
            for (int i = start; i > current; i--) {
              _pktList[i] = _pktList[i - 1];
            }
            _pktList[current] = startItem;
          }

          if (areListsEqualOrder(_pktList, _pocketProvider.getPocketList)) {
            _isChangedOrder = false;
          } else {
            _isChangedOrder = true;
          }
          setState(() {});
        },
        children: _pktList.map((item) => _setListItem(item)).toList(),
      ),
    );
  }

  bool areListsEqualOrder(List<Pocket> a, List<Pocket> b) {
    if (a == b) {
      return true;
    }
    if (a == null || b == null || a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i].pktSn != b[i].pktSn) {
        return false;
      }
    }
    return true;
  }

  //리스트 아이템 설정
  Widget _setListItem(Pocket item) {
    return Container(
      key: Key(item.pktSn),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 7.5,
      ),
      color: Colors.transparent,
      child: Container(
        key: Key(item.pktSn),
        width: double.infinity,
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: UIStyle.boxShadowBasic(16),
        child: SizedBox(
          width: double.infinity,
          height: 70,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Image.asset(
                      'images/main_jm_icon_list_awtb.png',
                      height: 19,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Flexible(
                      child: Text(
                        item.pktName,
                        style: TStyle.commonTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Row(
                children: [
                  InkWell(
                    child: const Text(
                      '종목관리',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: RColor.greyBasic_8c8c8c,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PocketStockSettingPage(item.pktSn),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    width: 15.0,
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/icon_edit_pocket_name_grey.png',
                            height: 20,
                          ),
                          const Text(
                            '변경',
                            style: TextStyle(
                              fontSize: 12,
                              color: RColor.greyBasic_8c8c8c,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      var result =
                          await CommonLayer.instance.showLayerChangePocketName(
                        context,
                        item,
                      );
                      if (result == CustomNvRouteResult.refresh) {
                        Pocket? findChangedPocket = _pocketProvider.getPocketList
                            .firstWhere(
                                (findPocket) => findPocket.pktSn == item.pktSn,
                                orElse: () => null as Pocket);
                        if (findChangedPocket != null) {
                          setState(() {
                            item.pktName = findChangedPocket.pktName;
                          });
                        }
                      } else {}
                    },
                  ),
                  InkWell(
                    onTap: () {
                      if (item.isDelete) {
                        item.isDelete = false;
                        if (!_pktList.any(
                          (pocket) => pocket.isDelete == true,
                        )) {
                          _isChangedTrash = false;
                        }
                      } else {
                        item.isDelete = true;
                        _isChangedTrash = true;
                      }
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            item.isDelete
                                ? 'images/icon_trash_ok_purple.png'
                                : 'images/icon_trash_grey.png',
                            height: 20,
                          ),
                          Text(
                            '삭제',
                            style: TextStyle(
                              fontSize: 12,
                              color: item.isDelete
                                  ? RColor.purpleBasic_6565ff
                                  : RColor.greyBasic_8c8c8c,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getTrashPocketCount() {
    if (_isChangedTrash) {
      int count = 0;
      for (var element in _pktList) {
        if (element.isDelete) count++;
      }
      return count;
    } else {
      return 0;
    }
  }

  deleteProcess(bool goBack) async {
    if (_isChangedTrash || _isChangedOrder) {
      String result = await CommonPopup.instance.showDialogCustomConfirm(
        context,
        '알림',
        !_isChangedTrash
            ? '포켓의 순서를 저장하시겠습니까?'
            : '선택하신 ${_getTrashPocketCount()}개의 포켓을\n삭제하시겠습니까?\n포켓에 등록된 모든 종목이\n함께 삭제됩니다.',
        !_isChangedTrash ? '저장하기' : '삭제하기',
      );
      if (context.mounted) {
        if (result == CustomNvRouteResult.landing) {
          if (_isChangedOrder) {
            bool result = await _pocketProvider.changeOrderPocket(_pktList);
            if (!result) {
              if (context.mounted) {
                CommonPopup.instance.showDialogBasic(
                    context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
              }
            }
            _isChangedOrder = false;
          }
          if (_isChangedTrash) {
            bool result = await _pocketProvider.deleteListPocket(_pktList);
            if (!result) {
              if (context.mounted) {
                CommonPopup.instance.showDialogBasic(
                    context, '안내', CommonPopup.dbEtcErroruserCenterMsg);
              }
            }
            _isChangedTrash = false;
          }
          setState(() {
            _pktList = _pocketProvider.getPocketList
                .map((e) => Pocket.withStockList(e.pktSn, e.pktName, e.stkList))
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
}
