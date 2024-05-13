import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/routes.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/ui/home/sliver_signal_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_aos_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_page.dart';
import 'package:rassi_assist/ui/pay/pay_premium_promotion_aos.dart';
import 'package:rassi_assist/ui/pay/pay_premium_promotion_page.dart';

import '../ui/home/sliver_home_page.dart';
import '../ui/main/base_page.dart';
import 'pg_data.dart';

/// 2020.10.06
/// 상품 홍보/안내
class TrProm02 {
  String retCode;
  final String retMsg;
  final List<Prom02> retData;

  TrProm02({this.retCode = '', this.retMsg = '', this.retData = const []});

  factory TrProm02.fromJson(Map<String, dynamic> json) {
    return TrProm02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: (json['retData'] == null)
          ? []
          : (json['retData'] as List).map((i) => Prom02.fromJson(i)).toList() ??
              [],
    );
  }
}

class Prom02 {
  final String promoSn;
  final String viewPage;
  final String viewPosition;
  final String promoDiv;
  final String contentType;
  final String title;
  final String content;
  final String linkType;
  final String linkPage;
  final String buttonTxt;
  final String popupBlockTime;

  Prom02({
    this.promoSn = '',
    this.viewPage = '',
    this.viewPosition = '',
    this.promoDiv = '',
    this.contentType = '',
    this.title = '',
    this.content = '',
    this.linkType = '',
    this.linkPage = '',
    this.buttonTxt = '',
    this.popupBlockTime = '',
  });

  factory Prom02.fromJson(Map<String, dynamic> json) {
    return Prom02(
      promoSn: json['promoSn'],
      viewPage: json['viewPage'],
      viewPosition: json['viewPosition'] ?? '',
      promoDiv: json['promoDiv'],
      contentType: json['contentType'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      linkType: json['linkType'] ?? '',
      linkPage: json['linkPage'] ?? '',
      buttonTxt: json['buttonTxt'] ?? '',
      popupBlockTime: json['popupBlockTime'],
    );
  }

  @override
  String toString() {
    return '$promoSn|$viewPage|$viewPosition|$promoDiv|$title';
  }
}

class CardProm02 extends StatefulWidget {
  final List<Prom02> listItem;
  final SwiperController controller = SwiperController();

  CardProm02(
    this.listItem, {
    Key? key,
  }) : super(key: key);

  @override
  State<CardProm02> createState() => _CardProm02State();
}

class _CardProm02State extends State<CardProm02> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.listItem.length == 1) {
      return _tileProm02(widget.listItem[0]);
    } else {
      return Stack(
        children: [
          Swiper(
            controller: widget.controller,
            autoplay: widget.listItem.length < 2 ? false : true,
            autoplayDelay: 4000,
            itemCount: widget.listItem.length,
            itemBuilder: (BuildContext context, int index) {
              return _tileProm02(widget.listItem[index]);
            },
            onIndexChanged: (value) {
              if (currentIndex != value) {
                setState(() {
                  currentIndex = value;
                });
              }
            },
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: const EdgeInsets.all(
                10,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 1,
              ),
              decoration: UIStyle.boxRoundFullColor25c(
                Colors.black.withOpacity(0.5),
              ),
              child: Text(
                '${currentIndex + 1} / ${widget.listItem.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _tileProm02(Prom02 item) {
    BoxFit boxFit = BoxFit.contain;
    int bgColorInteger = 0xffF3F4F8; // bgWeak
    if (AppGlobal().isTablet) {
      boxFit = BoxFit.contain;
      try {
        int endSubStringInt = item.content.lastIndexOf('.');
        String linkColorCode =
            '0xff${item.content.substring(endSubStringInt - 6, endSubStringInt)}';
        bgColorInteger = int.parse(linkColorCode);
        boxFit = BoxFit.contain;
      } on FormatException {
        bgColorInteger = 0xffF3F4F8;
      } catch (_) {
        bgColorInteger = 0xffF3F4F8;
      }
    } else {
      boxFit = BoxFit.fill;
    }
    return InkWell(
      child: Container(
        color: Color(bgColorInteger),
        child: FittedBox(
          fit: boxFit,
          child: Image.network(item.content),
        ),
      ),
      onTap: () async {
        DLog.d('TileProm02', 'Promotion -> ' + item.title);
        DLog.d('TileProm02', 'item.linkPage : ${item.linkPage}');

        if (item.linkType == LD.linkTypeApp) {
          // 앱 내 이동
          _navigateAndGetResultPayPremiumPage(context, item);
        } else if (item.linkType == LD.linkTypeUrl) {
          basePageState.goLandingPage(
              LD.linkTypeUrl, item.linkPage, item.title, '', '');
        } else if (item.linkType == LD.linkTypeOutLink) {
          basePageState.goLandingPage(
              LD.linkTypeOutLink, item.linkPage, '', '', '');
        }
      },
    );
  }

  // Prom02 이용하는 화면들에서 결제연동 + 화면 갱신
  _navigateAndGetResultPayPremiumPage(
      BuildContext buildContext, Prom02 item) async {
    var result;

    switch (item.linkPage) {
      case 'LPH1':
        {
          result = await Navigator.push(
            buildContext,
            Platform.isIOS
                ? CustomNvRouteClass.createRoute(const PayPremiumPage())
                : CustomNvRouteClass.createRoute(const PayPremiumAosPage()),
          );
          break;
        }
      case 'LPH7':
        {
          result = await Navigator.push(
            buildContext,
            Platform.isIOS
                ? CustomNvRouteClass.createRouteData(
                    const PayPremiumPromotionPage(),
                    RouteSettings(
                      arguments: PgData(data: 'ad5'),
                    ),
                  )
                : CustomNvRouteClass.createRouteData(
                    const PayPremiumPromotionAosPage(),
                    RouteSettings(
                      arguments: PgData(data: 'ad5'),
                    ),
                  ),
          );
          break;
        }
      case 'LPH8':
        {
          result = await Navigator.push(
            buildContext,
            Platform.isIOS
                ? CustomNvRouteClass.createRouteData(
                    const PayPremiumPromotionPage(),
                    RouteSettings(
                      arguments: PgData(data: 'ad4'),
                    ),
                  )
                : CustomNvRouteClass.createRouteData(
                    const PayPremiumPromotionAosPage(),
                    RouteSettings(
                      arguments: PgData(data: 'ad4'),
                    ),
                  ),
          );
          break;
        }
      case 'LPH9':
        {
          result = await Navigator.push(
            buildContext,
            Platform.isIOS
                ? CustomNvRouteClass.createRouteData(
                    const PayPremiumPromotionPage(),
                    RouteSettings(
                      arguments: PgData(data: 'ad3'),
                    ),
                  )
                : CustomNvRouteClass.createRouteData(
                    const PayPremiumPromotionAosPage(),
                    RouteSettings(
                      arguments: PgData(data: 'ad3'),
                    ),
                  ),
          );
          break;
        }
      case 'LPHA':
        {
          result = await Navigator.push(
            buildContext,
            Platform.isIOS
                ? CustomNvRouteClass.createRouteData(
                    const PayPremiumPromotionPage(),
                    RouteSettings(
                      arguments: PgData(data: 'at1'),
                    ),
                  )
                : CustomNvRouteClass.createRouteData(
                    const PayPremiumPromotionAosPage(),
                    RouteSettings(
                      arguments: PgData(data: 'at1'),
                    ),
                  ),
          );
          break;
        }
      case 'LPHB':
        {
          result = await Navigator.push(
            buildContext,
            Platform.isIOS
                ? CustomNvRouteClass.createRouteData(
                    const PayPremiumPromotionPage(),
                    RouteSettings(
                      arguments: PgData(data: 'at2'),
                    ),
                  )
                : CustomNvRouteClass.createRouteData(
                    const PayPremiumPromotionAosPage(),
                    RouteSettings(
                      arguments: PgData(data: 'at2'),
                    ),
                  ),
          );
          break;
        }
      case 'LPHD':
        {
          if(Platform.isAndroid) {
            result = await Navigator.push(
              buildContext,
              CustomNvRouteClass.createRouteData(
                const PayPremiumPromotionAosPage(),
                RouteSettings(
                  arguments: PgData(data: 'new_6m'),
                ),
              ),
            );
          }
          break;
        }
      case 'LPHE':
        {
          if(Platform.isAndroid) {
            result = await Navigator.push(
              buildContext,
              CustomNvRouteClass.createRouteData(
                const PayPremiumPromotionAosPage(),
                RouteSettings(
                  arguments: PgData(data: 'new_6m_50'),
                ),
              ),
            );
          }else if(Platform.isIOS) {
            result = await Navigator.push(
              buildContext,
              CustomNvRouteClass.createRouteData(
                const PayPremiumPromotionPage(),
                RouteSettings(
                  arguments: PgData(data: 'am6d5'),
                ),
              ),
            );
          }
          break;
        }
      case 'LPHG':
        {
          if(Platform.isAndroid) {
            result = await Navigator.push(
              buildContext,
              CustomNvRouteClass.createRouteData(
                const PayPremiumPromotionAosPage(),
                RouteSettings(
                  arguments: PgData(data: 'new_6m_70'),
                ),
              ),
            );
          }
          break;
        }
      case 'LPHF':
        {
          if(Platform.isAndroid) {
            result = await Navigator.push(
              buildContext,
              CustomNvRouteClass.createRouteData(
                const PayPremiumPromotionAosPage(),
                RouteSettings(
                  arguments: PgData(data: 'new_7d'),
                ),
              ),
            );
          }
          break;
        }
      default:
        {
          basePageState.goLandingPage(item.linkPage, '', '', '', '');
        }
    }

    if (result != null && result != 'cancel') {
      if (SliverHomeWidget.globalKey.currentState != null) {
        // 홈_홈 화면 결제 후 갱신
        var childCurrentState = SliverHomeWidget.globalKey.currentState;
        childCurrentState?.requestTrUser04();
      } else if (SliverSignalWidget.globalKey.currentState != null) {
        // 홈_AI매매신호 화면 결제 후 갱신
        var childCurrentState0 = SliverSignalWidget.globalKey.currentState;
        childCurrentState0?.reload();
      }
    }
  }
}
