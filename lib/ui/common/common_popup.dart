import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';

class CommonPopup {
  CommonPopup._privateConstructor();

  /* DEFINE
      공통으로 사용하는 팝업 클래스 입니다.
   */

  static final CommonPopup _instance =
      CommonPopup._privateConstructor();

  factory CommonPopup() {
    return _instance;
  }

  // 네트워크 에러 알림
  void showDialogNetErr(BuildContext context) {
    if (context != null && context.mounted) {
      showDialog(
          context: context,
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
                      if (context != null && context.mounted) {
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
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
                          ),
                        ),
                      ),
                      onTap: () {
                        if (context != null && context.mounted) {
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

  // 공통 알림
  void showDialogMsg(BuildContext _context, String message) {
    if (_context != null) {
      showDialog(
          context: _context,
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
                    child: Icon(
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
                      padding:
                          const EdgeInsets.only(top: 20, left: 10, right: 10),
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
                        child: Center(
                          child: Text(
                            '확인',
                            style: TStyle.btnTextWht15,
                            textScaleFactor: Const.TEXT_SCALE_FACTOR,
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
  void showDialogTitleMsg(BuildContext _context, String title, String message) {
    if (_context != null) {
      showDialog(
        context: _context,
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
                    padding:
                        const EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Text(
                      title,
                      style: TStyle.title20,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 10, right: 10, bottom: 20),
                    child: Text(
                      message,
                      textAlign: TextAlign.start,
                      style: TStyle.content16,
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

  void showDialogTitleMsgAlignCenter(
      BuildContext _context, String title, String message) {
    if (_context != null) {
      showDialog(
        context: _context,
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
                    padding:
                        const EdgeInsets.only(top: 20, left: 10, right: 10),
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
                      textAlign: TextAlign.center,
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
  void showDialogForbidden(
      BuildContext context, String stockName, String desc) {
    if (context != null) {
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
                      padding:
                          const EdgeInsets.only(top: 20, left: 10, right: 10),
                      child: Column(
                        children: [
                          Text(
                            '매수 신호 미발생 종목',
                            style: TStyle.commonTitle,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '\n라씨 매매비서에서는\n최대한 많은 종목에 대해서\n매매신호 발생을 원칙으로 하나\n$stockName의 경우\n'
                            '${TStyle.getDateKorFormat(TStyle.getTodayString())} '
                            '현재\n다음과 같은 사유로\n매수신호가 발생되지 않습니다.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            '\n사유 : $desc',
                            style: TStyle.commonTitle,
                            textAlign: TextAlign.center,
                          ),
                          const Text(
                            '\n해당 사유가 해소되면\n다시 매수 신호가 발생 됩니다.',
                            textAlign: TextAlign.center,
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
}
