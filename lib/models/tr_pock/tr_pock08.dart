import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/main/search_page.dart';
import 'package:rassi_assist/ui/pocket/pocket_page.dart';


/// 2020.11.12
/// 포켓 종목 신호 상태
class TrPock08 {
  final String retCode;
  final String retMsg;
  final Pock08? retData;

  TrPock08({this.retCode='', this.retMsg='', this.retData});

  factory TrPock08.fromJson(Map<String, dynamic> json) {
    return TrPock08(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: Pock08.fromJson(json['retData']),
    );
  }
}


class Pock08 {
  final PocketBrief? pocketBrief;
  final List<PtStock> stkList;

  Pock08({this.pocketBrief, this.stkList = const [],});

  factory Pock08.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    // List<PtStock>? rtList;
    // list == null ? rtList = null : rtList = list.map((i) => PtStock.fromJson(i)).toList();

    return Pock08(
      pocketBrief: PocketBrief.fromJson(json['struct_Pocket']),
      stkList: list.map((i) => PtStock.fromJson(i)).toList(),
    );
  }
}

class PocketBrief {
  final String pocketSn;
  final String pocketName;
  final String viewSeq;
  final String waitCount;
  final String holdCount;

  PocketBrief({
    this.pocketSn='',
    this.pocketName='',
    this.viewSeq='',
    this.waitCount='',
    this.holdCount='',
  });

  factory PocketBrief.fromJson(Map<String, dynamic> json) {
    return PocketBrief(
      pocketSn: json['pocketSn'],
      pocketName: json['pocketName'],
      viewSeq: json['viewSeq'],
      waitCount: json['waitCount'],
      holdCount: json['holdCount'],
    );
  }

  @override
  String toString() {
    return '$pocketName|$pocketSn|$viewSeq|$waitCount|$holdCount';
  }
}

class PtStock {
  final String viewSeq;
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String myTradeFlag;
  final String tradePrice;
  final String tradeDttm;
  final String currentPrice;
  final String profitRate;
  final String fluctuationAmt;
  final String fluctuationRate;
  final String elapsedDays;
  final String sellPrice;
  final String termOfTrade;

  PtStock({
    this.viewSeq='', this.stockCode='', this.stockName='', this.tradeFlag='',
    this.myTradeFlag='', this.tradePrice='', this.tradeDttm='', this.currentPrice='',
    this.profitRate='', this.fluctuationAmt='', this.fluctuationRate='',
    this.elapsedDays='', this.sellPrice='', this.termOfTrade=''
  });

  factory PtStock.fromJson(Map<String, dynamic> json) {
    return PtStock(
      viewSeq: json['viewSeq'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      tradeFlag: json['tradeFlag'] ?? '',
      myTradeFlag: json['myTradeFlag'] ?? '',
      tradePrice: json['tradePrice'] ?? '',
      tradeDttm: json['tradeDttm'] ?? '',
      currentPrice: json['currentPrice'] ?? '',
      profitRate: json['profitRate'] ?? '',
      fluctuationAmt: json['fluctuationAmt'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
      elapsedDays: json['elapsedDays'] ?? '',
      sellPrice: json['sellPrice'] ?? '',
      termOfTrade: json['termOfTrade'] ?? '',
    );
  }
}


//포켓 대시보드 종목 리스트 아이템
class TileBoardItem extends StatelessWidget {
  final PtStock item;
  final String pktSn;
  final bool isUserSig;

  TileBoardItem(this.item, this.pktSn, this.isUserSig);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(TStyle.getLimitString(item.stockName, 10), style: TStyle.commonTitle,
                            maxLines: 1, overflow: TextOverflow.clip,),
                          const SizedBox(width: 4,),
                          Text(item.stockCode, style: TStyle.textSGrey,),
                        ],
                      ),
                      const SizedBox(height: 5.0,),
                      Visibility(
                        visible: isUserSig,
                        child: const Text('나만의 매도신호 발생',
                          style: TStyle.commonSPurple,),
                      ),
                    ],
                  ),

                  _setRateCircleText(item),

                ],
              ),

            ),

            Visibility(
              visible: isUserSig,
              child: Container(
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                width: double.infinity,
                decoration: UIStyle.boxWeakGrey10(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('회원님만을 위한 ',),
                    Text(
                      '매도신호 ${TStyle.getMoneyPoint(item.sellPrice)}원',
                      style: TStyle.commonSTitle,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 0.5,
              color: Colors.grey,
            )
          ],
        ),
        onTap: (){
          Navigator.of(context).pushNamed(PocketPage.routeName,
            arguments: PgData(pgSn: pktSn, stockCode: item.stockCode, stockName: item.stockName),);
        },
      ),
    );
  }

  Widget _setRateCircleText(PtStock item) {
    String statTxt = '';
    String typeText = '';
    Color? statColor;
    Color rateColor;
    String rateText = '';
    bool isToday = false;

    if(item.tradeFlag == 'B') {
      statTxt = '오늘\n매수';
      statColor = RColor.bgBuy;
      isToday = true;
    }
    else if(item.tradeFlag == 'S') {
      statTxt = '오늘\n매도';
      statColor = RColor.bgSell;
      isToday = true;
    }
    else if(item.tradeFlag == 'H') {
      statTxt = '보유중';
      typeText = '보유';
      statColor = RColor.sigHolding;
    }
    else if(item.tradeFlag == 'W') {
      statTxt = '관망중';
      typeText = '관망';
      statColor = RColor.sigWatching;
    }

    if(item.profitRate.contains('-')) {
      rateText = item.profitRate;
      rateColor = RColor.bgSell;
    } else {
      rateText = '+' + item.profitRate;
      rateColor = RColor.bgBuy;
    }

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            //오늘 매수/매도 시간 & 가격
            Visibility(
              visible: isToday,
              child: Text('${TStyle.getDtTimeFormat(item.tradeDttm)}  ${TStyle.getMoneyPoint(item.tradePrice)} '),
            ),

            //보유/관망 몇일째
            Visibility(
              visible: !isToday,
              child: Text('$typeText ${item.elapsedDays}일째 '),
            ),

            //수익률
            Visibility(
              visible: item.tradeFlag != 'W',   //관망이 아닐때만 보여줌
              child: Row(
                children: [
                  Visibility(
                    visible: item.tradeFlag != 'S',
                    child: const Text('수익률',
                      style: TextStyle(fontSize: 12),),
                  ),
                  const SizedBox(width: 4,),
                  Text('$rateText%', style: TextStyle(
                    color: rateColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  )),
                  const SizedBox(width: 3,),
                  Visibility(
                    visible: item.tradeFlag == 'S',
                    child: Text('${item.termOfTrade}일보유'),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(width: 7,),

        // Circle
        Container(
          width: 45.0,
          height: 45.0,
          decoration: BoxDecoration(color: statColor, shape: BoxShape.circle,),
          child: Center(
            child: Text('$statTxt', style: TStyle.btnTextWht12,
              // style: theme.textTheme.body.apply(color: textColor),
            ),
          ),
        )
      ],
    );
  }
}


class HeaderBoard extends StatelessWidget {
  final PocketBrief item;
  final String pageStr;
  HeaderBoard(this.item, this.pageStr);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      child: Column(
        children: [
          _setTopInfo(context),

          _setBottomInfo(context),
        ],
      ),
    );
  }

  //포켓명, 포켓상세보기
  Widget _setTopInfo(BuildContext context) {
    return Container(
      height: 170,
      color: RColor.deepBlue,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 10,),
          Text(item.pocketName, style: TStyle.btnTextWht20,),
          const SizedBox(height: 10,),
          _setRoundBotton(context, '+상세보기'),
          const SizedBox(height: 40,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('images/rassibs_pk_icon_myp_1.png', height: 20,),
                  const SizedBox(width: 5.0,),
                  Text(item.waitCount, style: TStyle.btnTextWht16,),
                  const SizedBox(width: 8.0,),
                  Image.asset('images/rassibs_pk_icon_myp_2.png', height: 20,),
                  const SizedBox(width: 5.0,),
                  Text(item.holdCount, style: TStyle.btnTextWht16,),
                ],
              ),
              Text(pageStr, style: TStyle.btnTextWht16,),
            ],
          ),
        ],
      ),
    );
  }

  // +상세보기(포켓)
  Widget _setRoundBotton(BuildContext context, String bTitle) {
    return Center(
      child: InkWell(
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          decoration: UIStyle.roundBtnStBox(),
          child: Center(child: Text(bTitle, style: TStyle.btnSTextWht,),),
        ),
        onTap: (){    //포켓 상세보기로 이동
          Navigator.of(context).pushReplacementNamed(PocketPage.routeName,
            arguments: PgData(pgSn: item.pocketSn,),);
        },
      ),
    );
  }

  //종목추가 / 순서변경
  Widget _setBottomInfo(BuildContext context) {
    return Container(
      height: 50,
      child: Column(
        children: [
          Container(
            height: 49.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //종목추가
                    InkWell(
                      child: Image.asset('images/rassibs_pk_icon_plu.png', height: 22,),
                      onTap: (){
                        //종목 검색 페이지로 이동
                        // basePageState.callPageRouteUpData(SearchPage(), PgData(pgSn: ''));
                        _navigateSearchData(context, SearchPage(), PgData(pgSn: item.pocketSn,));

                        // if(stkList.length > 2) {
                        //   _showSuggestPremium(context, '베이직 계정에서는 3종목까지 이용이 가능합니다.\n'
                        //       '종목추가와 포켓을 마음껏 이용할 수 있는 프리미엄 계정으로 업그레이드 해보세요.');
                        // } else {
                        //   _navigateSearchData(context, SearchPage(), PgData(pgSn: pktSn,));
                        // }
                      },
                    ),
                    const SizedBox(width: 12.0,),
                    //종목순서변경 TODO 순서변경 페이지 필요
                    // InkWell(
                    //   child: Image.asset('images/rassibs_pk_icon_awr.png',
                    //     height: 22,),
                    //   onTap: (){},
                    // ),
                  ],
                ),

                Text('AI매매신호 현황'),    //TODO 아래 리스트와 내용이 같이 변경
              ],
            ),
          ),
          Container(height: 0.7, color: Colors.grey, alignment: Alignment.bottomCenter,),
        ],
      ),
    );
  }

  //결제 안내 다이얼로그
  void _showSuggestPremium(BuildContext context, String desc) {
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
                  child: Icon(Icons.close, color: Colors.black,),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Text(desc, style: TStyle.contentMGrey,
                    textAlign: TextAlign.center,),
                  const SizedBox(height: 30.0,),
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
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  //페이지 리프레시
  _navigateSearchData(BuildContext context, Widget instance, PgData pgData) async {
    final result = await Navigator.push(context, _createRouteData(instance, RouteSettings(arguments: pgData,)));
    if(result == 'cancel') {
      DLog.d(PocketPage.TAG, '*** navigete cancel ***');
    }
    else {
      DLog.d(PocketPage.TAG, '*** navigateRefresh');
      // _fetchPosts(TR.POCK04, jsonEncode(<String, String>{
      //   'userId': _userId,
      //   'pocketSn': pktSn,
      // }));
    }
  }
  //페이지 전환 에니메이션 (데이터 전달)
  Route _createRouteData(Widget instance, RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
      settings: settings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,);
      },
    );
  }

}

