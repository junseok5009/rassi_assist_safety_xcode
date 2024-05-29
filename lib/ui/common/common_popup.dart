import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_result.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';

/* DEFINE
      공통으로 사용하는 팝업 클래스 입니다.
   */
class CommonPopup {
  CommonPopup._privateConstructor();

  static final CommonPopup instance = CommonPopup._privateConstructor();

  static const String dbEtcErroruserCenterMsg = "정상 처리되지 않았습니다. 해당 상태가 계속된다면 고객센터로 문의바랍니다.";

  factory CommonPopup() {
    return instance;
  }

  // 네트워크 에러 알림 >> 추후 삭제
  void showDialogNetErr(BuildContext funcBuildContext) {
    if (funcBuildContext.mounted) {
      showDialog(
          context: funcBuildContext,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
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
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset(
                      'images/rassibs_img_infomation.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                      child: Text(
                        '안내',
                        style: TStyle.commonTitle,
                      ),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    const Text(
                      RString.err_network,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    InkWell(
                      child: Container(
                        width: 140,
                        height: 36,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text(
                            '확인',
                            style: TStyle.btnTextWht15,
                          ),
                        ),
                      ),
                      onTap: () {
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          });
    }
  }

  Widget netErrBuilder({required BuildContext builderContext}) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
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
              Navigator.pop(builderContext);
            },
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'images/rassibs_img_infomation.png',
              height: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 5.0,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 10, right: 10),
              child: Text(
                '안내',
                style: TStyle.commonTitle,
              ),
            ),
            const SizedBox(
              height: 25.0,
            ),
            const Text(
              RString.err_network,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 30.0,
            ),
            InkWell(
              child: Container(
                width: 140,
                height: 36,
                decoration: UIStyle.roundBtnStBox(),
                child: const Center(
                  child: Text(
                    '확인',
                    style: TStyle.btnTextWht15,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(builderContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 공통 알림
  void showDialogMsg(BuildContext context, String message) {
    if (context.mounted) {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
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
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset(
                      'images/rassibs_img_infomation.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                      child: Text(
                        message,
                        style: TStyle.commonTitle,
                      ),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    InkWell(
                      child: Container(
                        width: 140,
                        height: 36,
                        decoration: UIStyle.roundBtnStBox(),
                        child: const Center(
                          child: Text(
                            '확인',
                            style: TStyle.btnTextWht15,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          });
    }
  }

  // 공통 알림 + 굵은 타이틀
  void showDialogTitleMsg(BuildContext context, String title, String message) {
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
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
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/rassibs_img_infomation.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Text(
                      title,
                      style: TStyle.title18T,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 20),
                    child: Text(
                      message,
                      textAlign: TextAlign.start,
                      style: TStyle.content15,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void showDialogTitleMsgAlignCenter(BuildContext context, String title, String message) {
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
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
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/rassibs_img_infomation.png',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Text(
                      title,
                      style: TStyle.title20,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      message,
                      textAlign: TextAlign.start,
                      style: TStyle.content15,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  // 매수신호 미발생 종목 팝업
  void showDialogForbidden(BuildContext context, String stockName, String desc) {
    if (context.mounted) {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
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
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset(
                      'images/rassibs_img_infomation.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                      child: Column(
                        children: [
                          const Text(
                            '매수 신호 미발생 종목',
                            style: TStyle.commonTitle,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '\n라씨 매매비서에서는\n최대한 많은 종목에 대해서\n매매신호 발생을 원칙으로 하나\n$stockName의 경우\n'
                            '${TStyle.getDateKorFormat(TStyle.getTodayString())} '
                            '현재\n다음과 같은 사유로\n매수신호가 발생되지 않습니다.',
                            textAlign: TextAlign.start,
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            '\n사유 : $desc',
                            style: TStyle.commonTitle,
                            textAlign: TextAlign.start,
                          ),
                          const Text(
                            '\n해당 사유가 해소되면\n다시 매수 신호가 발생 됩니다.',
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                  ],
                ),
              ),
            );
          });
    }
  }

  // 24.04.23 프리미엄 가입 팝업 basic
  Future<String> showDialogPremium(BuildContext context) async {
    if (context.mounted) {
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '프리미엄 계정 가입',
                      style: TStyle.title18T,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Text(
                      '프리미엄 계정으로\n더 완벽하게 이용해 보세요.',
                      textAlign: TextAlign.center,
                      style: TStyle.content15,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 25,
                      ),
                      padding: const EdgeInsets.all(20),
                      decoration: UIStyle.boxRoundFullColor6c(
                        RColor.greyBox_f5f5f5,
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '프리미엄에서',
                            textAlign: TextAlign.start,
                            style: TStyle.content15,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: AppGlobal().deviceWidth / 2.5,
                            height: AppGlobal().deviceWidth / 2.5,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: AppGlobal().deviceWidth / 3.7,
                                    height: AppGlobal().deviceWidth / 3.7,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xffD8D8FF),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: AppGlobal().deviceWidth / 8,
                                    height: AppGlobal().deviceWidth / 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: RColor.greyBox_f5f5f5,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: _premiumCircleWidget('매매신호\n무제한', 0),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: _premiumCircleWidget('나만의\n매도신호', 1),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _premiumCircleWidget('실시간\n알림', 2),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: _premiumCircleWidget('포켓\n추가', 3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            '모두 이용하실 수 있습니다.',
                            textAlign: TextAlign.center,
                            style: TStyle.content15,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      child: Container(
                        height: 50,
                        constraints: const BoxConstraints(
                          minWidth: 100,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        decoration: UIStyle.boxRoundFullColor50c(
                          RColor.mainColor,
                        ),
                        alignment: Alignment.center,
                        child: const FittedBox(
                          child: Text(
                            '프리미엄 계정 가입하기',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context, CustomNvRouteResult.landPremiumPage);
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
    } else {
      return CustomNvRouteResult.cancel;
    }
  }

  // 24.04.23 프리미엄 업그레이드 (AOS 3종목 > 프리미엄) 팝업 basic
  Future<String> showDialogPremiumUpgrade(BuildContext context) async {
    if (context.mounted) {
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
                      '프리미엄 계정 업그레이드',
                      style: TStyle.title18T,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Text(
                      '추가결제 없이 프리미엄 계정을 지금 바로 이용해 보세요.',
                      textAlign: TextAlign.center,
                      style: TStyle.content15,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 25,
                      ),
                      padding: const EdgeInsets.all(20),
                      decoration: UIStyle.boxRoundFullColor6c(
                        RColor.greyBox_f5f5f5,
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '프리미엄에서',
                            textAlign: TextAlign.start,
                            style: TStyle.content15,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: AppGlobal().deviceWidth / 2.5,
                            height: AppGlobal().deviceWidth / 2.5,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: AppGlobal().deviceWidth / 3.7,
                                    height: AppGlobal().deviceWidth / 3.7,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xffD8D8FF),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: AppGlobal().deviceWidth / 8,
                                    height: AppGlobal().deviceWidth / 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: RColor.greyBox_f5f5f5,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: _premiumCircleWidget('매매신호\n무제한', 0),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: _premiumCircleWidget('나만의\n매도신호', 1),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _premiumCircleWidget('실시간\n알림', 2),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: _premiumCircleWidget('포켓\n추가', 3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            '모두 이용하실 수 있습니다.',
                            textAlign: TextAlign.center,
                            style: TStyle.content15,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        decoration: UIStyle.boxRoundFullColor50c(
                          RColor.mainColor,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '계정 업그레이드',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context, CustomNvRouteResult.landPremiumPage);
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
    } else {
      return CustomNvRouteResult.cancel;
    }
  }

  // 24.04.23 프리미엄 기간 (1개월 정기 > 6개월 정기) 업그레이드
  Future<String> showDialogPremiumPeriodUpgrade(BuildContext context) async {
    if (context.mounted) {
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
                      '프리미엄 기간 업그레이드',
                      style: TStyle.title18T,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Text(
                      '프리미엄의 기간을 업그레이드 하시고 더 높은 할인을 받아보세요.',
                      textAlign: TextAlign.center,
                      style: TStyle.content15,
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    InkWell(
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        decoration: UIStyle.boxRoundFullColor50c(
                          RColor.mainColor,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '6개월 상품으로 업그레이드',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context, CustomNvRouteResult.landPremiumPage);
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
    } else {
      return CustomNvRouteResult.cancel;
    }
  }

  // index 0 : top / 1 : bottom / 2 : left / 3 : right
  Widget _premiumCircleWidget(String title, int index) {
    return Container(
      width: AppGlobal().deviceWidth / 7.5,
      height: AppGlobal().deviceWidth / 7.5,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xff353B6F),
      ),
      padding: index == 2
          ? const EdgeInsets.all(8)
          : index == 3
              ? const EdgeInsets.all(10)
              : const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: FittedBox(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // 23.12.05 공통 알림 팝업 개편 >> 확인 버튼 없음, 타이틀 빈 값이면 안보이게 >>>>> 삭제 예정
  showDialogBasic(BuildContext context, String title, String message) async {
    if (context.mounted) {
      return showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
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
                    Text(
                      title,
                      style: TStyle.title18T,
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TStyle.content15,
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
      ).then((value) {
        if (value != null) {
          return value;
        } else {
          return CustomNvRouteResult.cancel;
        }
      });
    } else {
      return CustomNvRouteResult.cancel;
    }
  }

  // 23.12.18 공통 알림 팝업 개편 >> 확인 버튼 있음, 타이틀 빈 값이면 안보이게
  Future<String> showDialogBasicConfirm(BuildContext context, String title, String message) async {
    if (context.mounted) {
      return showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
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
                    Text(
                      title,
                      style: TStyle.title18T,
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TStyle.content15,
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        decoration: UIStyle.boxRoundFullColor50c(
                          RColor.purpleBasic_6565ff,
                        ),
                        child: const Text(
                          '확인',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(
                          context,
                          CustomNvRouteResult.landing,
                        );
                      },
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ).then((value) {
        if (value != null) {
          return value;
        } else {
          return CustomNvRouteResult.cancel;
        }
      });
    } else {
      return CustomNvRouteResult.cancel;
    }
  }

  // 23.12.18 타이틀, 내용, 버튼명
  Future<String> showDialogCustomConfirm(BuildContext context, String title, String message, String btnTitle) async {
    if (context.mounted) {
      return showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
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
                    Text(
                      title,
                      style: TStyle.title18T,
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TStyle.content15,
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        decoration: UIStyle.boxRoundFullColor50c(
                          RColor.mainColor,
                        ),
                        child: Text(
                          btnTitle,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(
                          context,
                          CustomNvRouteResult.landing,
                        );
                      },
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ).then((value) {
        if (value != null) {
          return value;
        } else {
          return CustomNvRouteResult.cancel;
        }
      });
    } else {
      return CustomNvRouteResult.cancel;
    }
  }
}
