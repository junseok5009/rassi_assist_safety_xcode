import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';

/// 매매신호 성과 23.01.12 list_honorStock + list_signalAnal 추가, 구조 변경
class TrSignal02 {
  final String retCode;
  final String retMsg;
  final Signal02 retData;

  TrSignal02({this.retCode = '', this.retMsg = '', this.retData = defSignal02});

  factory TrSignal02.fromJson(Map<String, dynamic> json) {
    return TrSignal02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: Signal02.fromJson(json['retData']),
    );
  }
}

const defSignal02 = Signal02();

class Signal02 {
  final List<SignalAnal> listSignalAnal;
  final List<HonorStock> listHonorStock;

  const Signal02({
    this.listSignalAnal = const [],
    this.listHonorStock = const [],
  });

  factory Signal02.fromJson(Map<String, dynamic> json) {
    var jsonListSignalAnal = json['list_SignalAnal'] as List?;
    List<SignalAnal> vSignalAnalList;
    jsonListSignalAnal == null
        ? vSignalAnalList = []
        : vSignalAnalList =
            jsonListSignalAnal.map((i) => SignalAnal.fromJson(i)).toList();

    var jsonListHonorStock = json['list_HonorStock'] as List?;
    List<HonorStock> vHonorStockList;
    jsonListHonorStock == null
        ? vHonorStockList = []
        : vHonorStockList =
            jsonListHonorStock.map((i) => HonorStock.fromJson(i)).toList();

    return Signal02(
      listSignalAnal: vSignalAnalList,
      listHonorStock: vHonorStockList,
    );
  }
}

class SignalAnal {
  final String analTarget;
  final String analType;
  final String empValue;
  final String achieveText;
  final String holdingDays;
  final String periodMonth;
  final String beginDate;

  SignalAnal({
    this.analTarget = '',
    this.analType = '',
    this.empValue = '',
    this.achieveText = '',
    this.holdingDays = '',
    this.periodMonth = '',
    this.beginDate = '',
  });

  factory SignalAnal.fromJson(Map<String, dynamic> json) {
    return SignalAnal(
      analTarget: json['analTarget'] ?? '',
      analType: json['analType'] ?? '',
      empValue: json['empValue'] ?? '',
      achieveText: json['achieveText'] ?? '',
      holdingDays: json['holdingDays'] ?? '',
      periodMonth: json['periodMonth'] ?? '',
      beginDate: json['beginDate'] ?? '',
    );
  }
}

class HonorStock {
  /*분야(명예) 구분
  WIN_RATE : 적중률(승률),
  PROFIT_RATE: 수익 10%이상 발생 횟수
  SUM_PROFIT : 누적 수익률
  MAX_PROFIT : 최대 수익률
  AVG_PROFIT : 평균 수익률*/
  final String honorDiv;
  final String stockCode;
  final String stockName;
  final String periodMonth;
  final String profitRate; // 수익률
  final String winningRate; // 적중률
  final String tradeCount; // 전체 매매 횟수
  final String winCount; // 수익 매매 횟수
  final String holdingDays; // 보유 일수(평균)

  HonorStock({
    this.honorDiv = '',
    this.stockCode = '',
    this.stockName = '',
    this.periodMonth = '',
    this.profitRate = '',
    this.winningRate = '',
    this.tradeCount = '',
    this.winCount = '',
    this.holdingDays = '',
  });

  factory HonorStock.fromJson(Map<String, dynamic> json) {
    return HonorStock(
      honorDiv: json['honorDiv'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      periodMonth: json['periodMonth'] ?? '',
      profitRate: json['profitRate'] ?? '',
      winningRate: json['winningRate'] ?? '',
      tradeCount: json['tradeCount'] ?? '',
      winCount: json['winCount'] ?? '',
      holdingDays: json['holdingDays'] ?? '',
    );
  }
}

//화면구성
class TileSignalAnal extends StatelessWidget {
  final SignalAnal item;

  TileSignalAnal(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      margin: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 5.0,
      ),
      alignment: Alignment.centerLeft,
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: SizedBox(
          width: double.infinity,
          height: 100,
          child: Row(
            children: [
              _setCircleStatus(item.empValue),
              Expanded(
                child: Container(
                  child: _initHtml(item.achieveText),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          if (item.analType != null && item.analType.length > 0) {
            DLog.d('TR_Signal02', '${item.analType}');
            _showDialogDesc(context, item.analType);
          }
        },
      ),
    );
  }

  Widget _setCircleStatus(String txt) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 1, color: Colors.grey),
      ),
      child: Center(
        child: Text(
          '$txt', style: TStyle.commonTitle,
          // style: theme.textTheme.body.apply(color: textColor),
        ),
      ),
    );
  }

  Widget _initHtml(String strHtml) {
    return Html(
      data: strHtml,
      style: {
        "body": Style(
          fontSize: FontSize(15.0),
        ),
        "u": Style(color: RColor.mainColor),
      },
    );
  }

/*  Widget _initWebView(String strHtml) {
    return WebView(
      initialUrl:
          'data:text/html;base64, ${base64Encode(const Utf8Encoder().convert("""<!DOCTYPE html>
            <html>
              <head><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
              <body style='"margin: 0; padding: 0;'>
                <div>
                  $strHtml
                </div>
              </body>
            </html>"""))}',
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        WebViewController controller = webViewController;
        controller.loadUrl(Uri.dataFromString(strHtml,
                mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
            .toString());
      },
    );
  }*/

  //내용 다이얼로그
  void _showDialogDesc(
    BuildContext context,
    String aType,
  ) {
    String desc = '';
    if (aType == '적중률')
      desc = RString.dl_anal_hit;
    else if (aType == '평균수익률')
      desc = RString.dl_anal_avg;
    else if (aType == '최대수익률')
      desc = RString.dl_anal_max;
    else if (aType == '누적수익률')
      desc = RString.dl_anal_sta;
    else if (aType == '수익난매매')
      desc = RString.dl_anal_prf;
    else if (aType == '매매횟수')
      desc = RString.dl_anal_trd;
    else if (aType == '보유기간') {
      desc = RString.dl_anal_hld;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: UIStyle.borderRoundedDialog(),
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
                  height: 25.0,
                ),
                Text(
                  aType,
                  style: TStyle.title20,
                  textAlign: TextAlign.center,
                  
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  
                ),
                const SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 다이얼로그
  void _showDialogMsg(BuildContext context, String message, String btnText) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: UIStyle.borderRoundedDialog(),
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
                    height: 25.0,
                  ),
                  Text('$message'),
                  const SizedBox(
                    height: 30.0,
                  ),
                  InkWell(
                    child: Container(
                      width: 140,
                      height: 36,
                      decoration: UIStyle.roundBtnStBox(),
                      child: Center(
                        child: Text(
                          btnText,
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
