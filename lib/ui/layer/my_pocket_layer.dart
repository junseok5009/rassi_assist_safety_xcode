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
import 'package:rassi_assist/ui/layer/add_pocket_layer.dart';

class MyPocketLayer extends StatefulWidget {
  //const MyPocketLayer({super.key});
  final String pocketSn;
  static final GlobalKey<MyPocketLayerState> globalKey = GlobalKey();

  MyPocketLayer(this.pocketSn, {Key? key}) : super(key: globalKey);

  @override
  State<MyPocketLayer> createState() => MyPocketLayerState();
}

class MyPocketLayerState extends State<MyPocketLayer> {
  bool isAddStock = true;
  bool isAddStockListOn = false;
  String _pocketSn = '';
  double _listViewHeight = 0;
  final AppGlobal _appGlobal = AppGlobal();

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      '나의_포켓_레이어',
    );
    if (widget.pocketSn != null && widget.pocketSn.isNotEmpty) {
      _pocketSn = widget.pocketSn;
    }
    int pktLength = Provider.of<PocketProvider>(context, listen: false)
        .getPocketList
        .length;
    if (pktLength * 64.0 + 10 > _appGlobal.deviceHeight - 250) {
      // 리스트 온
      isAddStockListOn = true;
      _listViewHeight = ((_appGlobal.deviceHeight - 250) ~/ 64.0) * 64.0;
    } else {
      // 리스트 없이
      _listViewHeight = pktLength * 64.0;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '나의 포켓',
                  style: TStyle.title18T,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context, CustomNvRouteResult.landing);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/icon_setting_grey.png',
                        height: 16,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        '포켓설정',
                        style: TextStyle(
                          color: RColor.greyBasicStrong_666666,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              height: _listViewHeight,
              margin: const EdgeInsets.only(top: 10),
              child: Consumer<PocketProvider>(
                builder: (_, provider, __) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: isAddStockListOn
                        ? null
                        : const NeverScrollableScrollPhysics(),
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
                    commonShowToastCenter('생성 가능한 포켓의 개수는 최대 10개 입니다.');
                  } else {
                    setState(() {
                      isAddStock = false;
                    });
                  }
                } else {
                  // 프리미엄 팝업
                  Navigator.pop(context, CustomNvRouteResult.landPremiumPopup);
                }
              },
              child: Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.only(
                  top: 10,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                decoration: UIStyle.boxRoundFullColor6c(
                  RColor.purple_e7e7ff,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(
                      child: Text(
                        '종목관리를 더 편하게, 포켓을 더 만들어 보세요.',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                    )
                  ],
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
          Navigator.pop(context, pocket.pktSn);
        }
      },
      child: Container(
        width: double.infinity,
        height: 54,
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
        ),
        decoration: UIStyle.boxRoundLine6LineColor(
          pocket.pktSn == _pocketSn
              ? RColor.purpleBasic_6565ff
              : RColor.greyBox_dcdfe2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Image.asset(
                    pocket.pktSn == _pocketSn ? 'images/icon_folder_check_purple.png' : 'images/icon_folder_grey.png',
                    height: pocket.pktSn == _pocketSn ? 20 : 18,
                  ),
                  SizedBox(
                    width: pocket.pktSn == _pocketSn ? 5 : 7,
                  ),
                  Flexible(
                    child: Text(
                      pocket.pktName,
                      style: TextStyle(
                        fontSize: 16,
                        color: pocket.pktSn == _pocketSn ? RColor.purpleBasic_6565ff : Colors.black,
                        fontWeight: pocket.pktSn == _pocketSn
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${pocket.stkList.length}',
                    style: TextStyle(
                      fontSize: 19,
                      color: pocket.pktSn == _pocketSn ? RColor.purpleBasic_6565ff : Colors.black,
                      fontWeight: pocket.pktSn == _pocketSn ? FontWeight.bold : FontWeight.w400,
                    ),
                  ),
                  const TextSpan(
                    text: '종목',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
