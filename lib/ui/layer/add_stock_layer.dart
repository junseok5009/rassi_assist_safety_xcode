import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/pocket.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/provider/pocket_provider.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/layer/add_pocket_layer.dart';

/// 포켓에 종목추가 하기
class AddStockLayer extends StatefulWidget {
  //const AddStockLayer({super.key});

  final Stock stock;
  final String pocketSn;
  static final GlobalKey<AddStockLayerState> globalKey = GlobalKey();

  AddStockLayer(this.stock, {this.pocketSn='', Key? key}) : super(key: globalKey);

  @override
  State<AddStockLayer> createState() => AddStockLayerState();
}

class AddStockLayerState extends State<AddStockLayer> {
  bool isAddStock = true;
  String _pocketSn = '';
  late ScrollController _controller;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.pocketSn != null && widget.pocketSn.isNotEmpty) {
      _pocketSn = widget.pocketSn;
      int pocketListIndex = Provider.of<PocketProvider>(context, listen: false).getPocketListIndexByPocketSn(_pocketSn);
      if(pocketListIndex > 2){
        pocketListIndex -= 2;
      }
      _controller =  ScrollController(initialScrollOffset: 40.0 * pocketListIndex);
    }else{
      _controller = ScrollController();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isAddStock) {
      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                color: Colors.black,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 24,
                onPressed: () {
                  if (context != null && context.mounted) {
                    Navigator.pop(context, CustomNvRouteResult.cancel);
                  }
                },
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              '포켓에 종목추가 하기',
              style: TStyle.title18T,
            ),
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.only(top: 20),
              child: Consumer<PocketProvider>(
                builder: (_, provider, __) {
                  return ListView.builder(
                    shrinkWrap: true,
                    //physics: NeverScrollableScrollPhysics(),
                    controller: _controller,
                    itemCount: provider.getPocketList.length,
                    itemBuilder: (context, index) => _setPocketListView(
                        index, provider.getPocketList[index]),
                  );
                },
              ),
            ),
            InkWell(
              onTap: () {
                var pocketProvider =
                    Provider.of<PocketProvider>(context, listen: false);
                if (AppGlobal().isPremium) {
                  if (pocketProvider.getPocketList.length >= 10) {
                    CommonPopup.instance.showDialogBasic(context, '알림', '생성 가능한 포켓의 개수는 최대 10개 입니다.');
                  } else {
                    setState(() {
                      isAddStock = false;
                    });
                  }
                } else {
                  // 프리미엄 팝업
                  Navigator.pop(
                      context,
                      CustomNvRouteResult.landPremiumPopup,
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.only(
                  top: 10,
                ),
                decoration: UIStyle.boxRoundFullColor6c(
                  RColor.greyBox_f5f5f5,
                ),
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
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                if (_pocketSn.isEmpty) {
                  commonShowToastCenter('포켓을 선택해 주십시오.');
                } else {
                  String result =
                      await Provider.of<PocketProvider>(context, listen: false)
                          .addStock(widget.stock, _pocketSn);
                  if(mounted){
                    Navigator.pop(context, result);
                  }
                }
              },
              child: Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.only(
                  top: 40,
                ),
                decoration: UIStyle.boxRoundFullColor25c(
                  _pocketSn.isEmpty ? RColor.greyBox_f5f5f5 : RColor.mainColor,
                ),
                alignment: Alignment.center,
                child: Text(
                  '추가하기',
                  style: TextStyle(
                    fontSize: 15,
                    color: _pocketSn.isEmpty ? RColor.greyBasic_8c8c8c : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const AddPocketLayer();
    }
  }

  Widget _setPocketListView(int index, Pocket pocket) {
    return InkWell(
      onTap: () {
        if (pocket.pktSn != _pocketSn) {
          setState(() {
            _pocketSn = pocket.pktSn;
          });
        }
      },
      child: Container(
        width: double.infinity,
        //height: 50,
        //color: Colors.red,
        margin: const EdgeInsets.only(top: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      pocket.pktName,
                      style: TextStyle(
                        fontSize: 16,
                        color: pocket.pktSn == _pocketSn
                            ? RColor.mainColor
                            : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text(
                    '${pocket.stkList.length}/50',
                    style: TextStyle(
                      fontSize: 11,
                      color: pocket.pktSn == _pocketSn
                          ? RColor.mainColor
                          : RColor.greyMore_999999,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                ],
              ),
            ),
            Image.asset(
              pocket.pktSn == _pocketSn
                  ? 'images/icon_circle_check_y.png'
                  : 'images/icon_circle_check_n.png',
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}
