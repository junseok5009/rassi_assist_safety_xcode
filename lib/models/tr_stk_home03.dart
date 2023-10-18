import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';


/// 2021.04.02
/// 종목의 최근7일간 주간 소식
class TrSHome03 {
  final String retCode;
  final String retMsg;
  final SHome03? retData;

  TrSHome03({this.retCode = '', this.retMsg = '', this.retData});

  factory TrSHome03.fromJson(Map<String, dynamic> json) {

    return TrSHome03(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null ? null : SHome03.fromJson(json['retData']),
    );
  }
}

class SHome03 {
  final String stockCode;
  final String stockName;
  final List<StockNews>? listNews;

  SHome03({this.stockCode = '', this.stockName = '', this.listNews});

  factory SHome03.fromJson(Map<String, dynamic> json) {
    var list = json['list_StockNews'] as List;
    List<StockNews> rtList = list == null ? [] : list.map((i) => StockNews.fromJson(i)).toList();

    return SHome03(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      listNews: rtList,
    );
  }
}

class StockNews {
  final String issueDate;
  final String contentDiv;
  final String content;

  StockNews({this.issueDate = '', this.contentDiv = '', this.content = '',});

  factory StockNews.fromJson(Map<String, dynamic> json) {
    return StockNews(
      issueDate: json['issueDate'],
      contentDiv: json['contentDiv'] ?? '',
      content: json['content'],
    );
  }
}


//화면구성 (종목홈 내에서 탭이동 구현이 힘들어서 일단 이 코드는 사용안함)
class TileSHome03 extends StatelessWidget {
  final StockNews item;
  final Color fColor;
  final Color bColor;

  TileSHome03(this.item, this.fColor, this.bColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 5, top: 15, bottom: 15),
      decoration: UIStyle.boxWithOpacity(),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(10.0),
          child: _setTileDesc(item.contentDiv, item.content),
        ),
        onTap: (){
          if(item.contentDiv == 'KEYWORD') {

          }
          else if(item.contentDiv == 'ISSUE') {

          }
          else if(item.contentDiv == 'TOPIC') {

          }
          else if(item.contentDiv == 'BUY') {
            //종목홈 시그널 이동
          }
          else if(item.contentDiv == 'SELL') {
            //종목홈 시그널 이동
          }
          else {    //성과 TOP
            if(item.contentDiv == 'WIN_RATE') {

            } else if(item.contentDiv == 'PROFIT_10P') {

            } else if(item.contentDiv == 'SUM_PROFIT') {

            } else if(item.contentDiv == 'MAX_PROFIT') {

            } else if(item.contentDiv == 'AVG_PROFIT') {

            }
            //TODO 종목홈으로 이동
          }
        },
      ),
    );
  }


  Widget _setTileDesc(String vType, String cont) {
    DLog.d('STK_HOME_TILE', 'div type : $vType');
    String title = '';
    String subText = '';
    String contents = '';
    Color statColor = RColor.sigWatching;
    bool isBsType = false;
    bool isTopType = false;

    if(item.contentDiv == 'KEYWORD') {
      title = item.content;
      contents = '종목키워드가\n등록되었습니다.';
    }
    else if(item.contentDiv == 'ISSUE') {
      title = item.content;
      contents = '이슈 헤드라인이\n발생했습니다.';
    }
    else if(item.contentDiv == 'TOPIC') {
      title = '주간토픽 등록';
      contents = '${item.content}\n주간토픽 종목입니다.';
    }
    else if(item.contentDiv == 'BUY') {
      isBsType = true;
      statColor = RColor.sigBuy;
      title = '매수';
      contents = '7일 이내 발생한\n매수신호가 있습니다.';
    }
    else if(item.contentDiv == 'SELL') {
      isBsType = true;
      statColor = RColor.sigSell;
      title = '매도';
      contents = '7일 이내 발생한\n매도신호가 있습니다.';
    }
    else {    //성과 TOP
      isTopType = true;
      if(item.contentDiv == 'WIN_RATE') {
        title = '적중률';
        subText = cont + '%';
      } else if(item.contentDiv == 'PROFIT_10P') {
        title = '수익난 매매';
        subText = cont + '번';
      } else if(item.contentDiv == 'SUM_PROFIT') {
        title = '누적수익률';
        subText = cont + '%';
      } else if(item.contentDiv == 'MAX_PROFIT') {
        title = '최대수익률';
        subText = cont + '%';
      } else if(item.contentDiv == 'AVG_PROFIT') {
        title = '평균수익률';
        subText = cont + '%';
      }
      contents = '성과 TOP 종목으로\n선정되었습니다.';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //상단 영역
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Stack(
            children: [
              Visibility(
                visible: isBsType && !isTopType,
                child: _setCircleText(statColor, title),
              ),

              Visibility(
                visible: !isBsType && !isTopType,
                child: Text(title, style: TStyle.puplePlainStyle(),),
              ),

              Visibility(
                visible: isTopType,
                child: Column(
                  children: [
                    Text(title, style: TStyle.subTitle,),
                    const SizedBox(height: 5,),
                    Text(subText, style: TStyle.textBBuy,),
                  ],
                ),
              ),
            ],
          ),
        ),

        //하단 컨텐츠 영역
        Text(contents, style: TStyle.contentGrey14, maxLines: 2, overflow: TextOverflow.clip,),
      ],
    );
  }

  Widget _setCircleText(Color bsColor, String bsText) {
    return Container(
      width: 45.0,
      height: 45.0,
      decoration: BoxDecoration(color: bsColor, shape: BoxShape.circle,),
      child: Center(
        child: Text(bsText, style: TStyle.btnTextWht17,
          // style: theme.textTheme.body.apply(color: textColor),
        ),
      ),
    );
  }
}
