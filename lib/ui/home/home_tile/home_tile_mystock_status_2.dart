import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/tr_pock/tr_pock11.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_stock_info_provider.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/common/common_popup.dart';
import 'package:rassi_assist/ui/main/base_page.dart';

class HomeTileMystockStatus2 extends StatefulWidget {
  //const HomeTileMystockStatus2({super.key});

  final Pock11 pock11;

  const HomeTileMystockStatus2(this.pock11, {super.key});

  @override
  State<HomeTileMystockStatus2> createState() => _HomeTileMystockStatus2State();
}

class _HomeTileMystockStatus2State extends State<HomeTileMystockStatus2>
    with AutomaticKeepAliveClientMixin {
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '내 종목 TODAY',
                style: TStyle.title18T,
              ),
              InkWell(
                onTap: () async {
                  basePageState.goPocketPage(Const.PKT_INDEX_MY,
                      pktSn:
                          Provider.of<StockInfoProvider>(context, listen: false)
                              .getPockSn);
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: const Text(
                  '나의 포켓',
                  style: TextStyle(
                    color: RColor.greyMore_999999,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 25.0,
          ),
          Container(
            width: double.infinity,
            height: 80,
            decoration: UIStyle.boxShadowBasic(16),
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //상승
                InkWell(
                  child: Column(
                    children: [
                      const Text(
                        '상승',
                        style: TStyle.content14,
                      ),
                      Text(
                        widget.pock11.upCnt,
                        style: TStyle.commonTitle,
                      ),
                    ],
                  ),
                  onTap: () {
                    basePageState.goPocketPage(
                      Const.PKT_INDEX_TODAY,
                      todayIndex: 0,
                    );
                  },
                ),

                //하락
                InkWell(
                  child: Column(
                    children: [
                      const Text(
                        '하락',
                        style: TStyle.content14,
                      ),
                      Text(
                        widget.pock11.downCnt,
                        style: TStyle.commonTitle,
                      ),
                    ],
                  ),
                  onTap: () {
                    basePageState.goPocketPage(
                      Const.PKT_INDEX_TODAY,
                      todayIndex: 1,
                    );
                  },
                ),

                //매매신호
                InkWell(
                  child: Column(
                    children: [
                      const Text(
                        '매매신호',
                        style: TStyle.content14,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.pock11.sigBuyCnt,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: RColor.sigBuy,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            widget.pock11.sigSellCnt,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: RColor.sigSell,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  onTap: () {
                    basePageState.goPocketPage(
                      Const.PKT_INDEX_TODAY,
                      todayIndex: 2,
                    );
                  },
                ),

                //이슈
                InkWell(
                  child: Column(
                    children: [
                      const Text(
                        '이슈',
                        style: TStyle.content14,
                      ),
                      Text(
                        widget.pock11.issueCnt,
                        style: TStyle.commonTitle,
                      ),
                    ],
                  ),
                  onTap: () {
                    basePageState.goPocketPage(
                      Const.PKT_INDEX_TODAY,
                      todayIndex: 3,
                    );
                  },
                ),

                //특이사항
                InkWell(
                  child: Column(
                    children: [
                      const Text(
                        '특이사항',
                        style: TStyle.content14,
                      ),
                      Text(
                        '${(int.tryParse(widget.pock11.chartCnt) ?? 0) + (int.tryParse(widget.pock11.supplyCnt) ?? 0)}',
                        style: TStyle.commonTitle,
                      ),
                    ],
                  ),
                  onTap: () {
                    basePageState.goPocketPage(
                      Const.PKT_INDEX_TODAY,
                      todayIndex: 4,
                    );
                  },
                ),
              ],
            ),
          ),
          _setBannerRobot(),
        ],
      ),
    );
  }

  //무료 사용자 배너
  Widget _setBannerRobot() {
    return Consumer<UserInfoProvider>(builder: (context, provider, child) {
      if (provider.isPremiumUser() || provider.is3StockUser()) {
        return const SizedBox();
      } else {
        return InkWell(
          child: Container(
            width: double.infinity,
            height: 110.0,
            margin: const EdgeInsets.only(top: 20.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 15,
            ),
            decoration: UIStyle.boxRoundFullColor6c(
              const Color(
                0xffE7E7FF,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '내 종목 소식과 AI매매신호',
                        style: TextStyle(
                          color: RColor.mainColor,
                          fontSize: 14,
                        ),
                      ),
                      FittedBox(
                        child: Text(
                          '실시간 알림 받기',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Image.asset(
                  'images/img_robot.png',
                  fit: BoxFit.cover,
                  scale: 4,
                ),
              ],
            ),
          ),
          onTap: () async {
            String result =
                await CommonPopup.instance.showDialogPremium(context);
            if (result == CustomNvRouteResult.landPremiumPage) {
              basePageState.navigateAndGetResultPayPremiumPage();
            }
          },
        );
      }
    });
  }
}
