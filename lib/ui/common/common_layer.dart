import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/pocket_api_result.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/pocket.dart';
import 'package:rassi_assist/models/stock_pkt_signal.dart';
import 'package:rassi_assist/ui/layer/add_pocket_layer.dart';
import 'package:rassi_assist/ui/layer/add_signal_layer.dart';
import 'package:rassi_assist/ui/layer/add_stock_layer.dart';
import 'package:rassi_assist/ui/layer/change_pocket_name_layer.dart';
import 'package:rassi_assist/ui/layer/change_signal_layer.dart';
import 'package:rassi_assist/ui/layer/my_pocket_layer.dart';

class CommonLayer {
  CommonLayer._privateConstructor();

  static final CommonLayer instance = CommonLayer._privateConstructor();

  // 종목을 포켓에 담기
  Future<PocketApiResult> showLayerAddStock(BuildContext context, Stock stock, String pocketSn) async {
    if (context.mounted) {
      return showModalBottomSheet<PocketApiResult>(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Wrap(
              children: <Widget>[
                AddStockLayer(
                  stock,
                  pocketSn: pocketSn,
                ),
              ],
            ),
          );
        },
      ).then(
        (value) {
          if (value != null) {
            return value;
          } else {
            return PocketApiResult.userCancelled();
          }
        },
      );
    } else {
      return PocketApiResult.unknownFailure();
    }
  }

  // 종목을 포켓에 담기
  Future<PocketApiResult> showLayerAddStockWithAddSignalBtn(
      BuildContext context, Stock stock) async {
    if (context.mounted) {
      return showModalBottomSheet<PocketApiResult>(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Wrap(
              children: <Widget>[
                AddStockLayer(
                  stock,
                ),
                InkWell(
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    //padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '나만의 매도신호 만들기',
                          style: TextStyle(
                            //공통 소항목 타이틀 (bold)
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: RColor.purpleBasic_6565ff,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: RColor.purpleBasic_6565ff,
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    // 레이어 내리고 매도신호 만들기 레이어 띄워야 함
                    return Navigator.pop(context, PocketApiResult.unknownFailure());
                  },
                ),
              ],
            ),
          );
        },
      ).then(
        (value) {
          if (value != null) {
            return value;
          } else {
            return PocketApiResult.userCancelled();
          }
        },
      );
    } else {
      return PocketApiResult.userCancelled();
    }
  }

  // 포켓 추가하기
  Future<String> showLayerAddPocket(
      BuildContext context,) async {
    if (context.mounted) {
      return showModalBottomSheet<String>(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: const Wrap(
              children: <Widget>[
                AddPocketLayer(),
              ],
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
    } else {
      return CustomNvRouteResult.cancel;
    }
  }

  // 종목을 신호에 설정 ( 나만의 매도 신호 만들기 )
  Future<String> showLayerAddSignal(BuildContext context, Stock stock) async {
    if (context.mounted) {
      return showModalBottomSheet<String>(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Wrap(
              children: <Widget>[
                AddSignalLayer(
                  stock: stock,
                ),
              ],
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
    } else {
      return CustomNvRouteResult.cancel;
    }
  }

  // 나만의 매도 신호 가격 변경
  Future<String> showLayerChangeSignal(
      BuildContext context, StockPktSignal stockPktSignal) async {
    if (context.mounted) {
      return showModalBottomSheet<String>(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Wrap(
              children: <Widget>[
                ChangeSignalLayer(
                  stockPktSignal: stockPktSignal,
                ),
              ],
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
    } else {
      return CustomNvRouteResult.cancel;
    }
  }

  // 포켓-나의 포켓 포켓 리스트 선택 레이어 / return [cancel / pocketSn]
  Future<String> showLayerMyPocket(
      BuildContext context, String pocketSn) async {
    if (context.mounted) {
      return showModalBottomSheet<String>(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Wrap(
              children: <Widget>[
                MyPocketLayer(
                  pocketSn,
                ),
              ],
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
    } else {
      return CustomNvRouteResult.cancel;
    }
  }

  // 포켓명 변경하기
  Future<String> showLayerChangePocketName(
      BuildContext context, Pocket pocket) async {
    if (context.mounted) {
      return showModalBottomSheet<String>(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Wrap(
              children: <Widget>[
                ChangePocketNameLayer(
                  pocket: pocket,
                ),
              ],
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
    } else {
      return CustomNvRouteResult.cancel;
    }
  }



}
