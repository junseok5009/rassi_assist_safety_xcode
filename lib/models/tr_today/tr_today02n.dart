import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/pocket/pocket_board.dart';
import 'package:rassi_assist/ui/pocket/pocket_page.dart';


/// 2020.11.13
/// 오늘의 내 종목 소식 [지정 포켓]
class TrToday02n {
  final String retCode;
  final String retMsg;
  final List<Today02n> listData;

  TrToday02n({this.retCode='', this.retMsg='', this.listData = const []});

  factory TrToday02n.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    // List<Today02n> rtList;
    // list == null ? rtList = null : rtList = list.map((i) => Today02n.fromJson(i)).toList();

    return TrToday02n(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        listData: list.map((i) => Today02n.fromJson(i)).toList(),
    );
  }
}


class Today02n {
  final String pocketSn;
  final String pocketName;
  final String viewSeq;
  final String pocketCount;
  final String waitCount;
  final String holdCount;
  final List<SNew> listNews;

  Today02n({
    this.pocketSn='', this.pocketName='',
    this.viewSeq='', this.pocketCount='',
    this.waitCount='', this.holdCount='',
    this.listNews = const [],
  });

  factory Today02n.fromJson(Map<String, dynamic> json) {
    var list = json['list_News'] as List;
    // List<SNew> rtList;
    // list == null ? rtList = null : rtList = list.map((i) => SNew.fromJson(i)).toList();

    return Today02n(
      pocketSn: json['pocketSn'] ?? '',
      pocketName: json['pocketName'],
      viewSeq: json['viewSeq'],
      pocketCount: json['pocketCount'],
      waitCount: json['waitCount'],
      holdCount: json['holdCount'],
      listNews: list.map((i) => SNew.fromJson(i)).toList(),
    );
  }

  @override
  String toString() {
    return '$pocketName|$pocketSn|$viewSeq';
  }

}


class SNew {
  final String stockCode;
  final String stockName;
  final String tradeTime;
  final String fluctuationRate;
  final String rassiroCount;
  final String sbCount;

  SNew({
    this.stockCode='', this.stockName='', this.tradeTime='',
    this.fluctuationRate='', this.rassiroCount='', this.sbCount='',
  });

  factory SNew.fromJson(Map<String, dynamic> json) {
    return SNew(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      tradeTime: json['tradeTime'],
      fluctuationRate: json['fluctuationRate'],
      rassiroCount: json['rassiroCount'],
      sbCount: json['sbCount'],
    );
  }
}

//포켓 HOME 종목 정보 (사용안함)
class TilePocketItem extends StatelessWidget {
  final SNew item;
  final String pktSn;

  TilePocketItem(this.item, this.pktSn);

  @override
  Widget build(BuildContext context) {
    String strRate = '';
    if(item.fluctuationRate.contains('-'))
      strRate = '오늘 ${item.fluctuationRate}% 하락하였습니다.';
    else if(item.fluctuationRate == '0.00')
      strRate = '오늘 종목의 등락에 변동이 없습니다.';
    else
      strRate = '오늘 ${item.fluctuationRate}% 상승하였습니다.';

    return Container(
      height: 110,
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15.0),
              child:  Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    child: Text(item.stockName[0], style: TStyle.btnTextWht16,),
                    radius: 15,
                    backgroundColor: RColor.mainColor,),
                  SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.stockName, style: TStyle.subTitle,
                        maxLines: 1, overflow: TextOverflow.clip,),
                      Text(strRate),
                      Text('라씨로 속보가 ${item.rassiroCount}건 있습니다.'),
                      Text('종목 알림이 ${item.sbCount}건 있습니다.'),
                    ],
                  ),
                ],
              ),
            ),
            // Container(
            //   width: double.infinity,
            //   height: 0.5,
            //   color: Colors.grey,
            // )
          ],
        ),
        onTap: (){
          Navigator.of(context).pushNamed(PocketPage.routeName,
            arguments: PgData(pgSn: pktSn,
                stockCode: item.stockCode, stockName: item.stockName),);
        },
      ),
    );
  }
}

//메인_홈 나의 종목소식 헤더 (사용안함)
class HeaderPocket extends StatelessWidget {
  final Today02n item;
  final int index;
  final String totSize;
  HeaderPocket(this.item, this.index, this.totSize);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: [
          InkWell(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 15),
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: const BoxDecoration(
                color: RColor.yonbora,
                borderRadius: BorderRadius.all(Radius.circular(7.0)),
              ),
              child: const Text('내 종목에서 AI매매신호를 모아보는 포켓보드 →',
                textAlign: TextAlign.center,
              ),
            ),
            onTap: (){    //해당 SN 포켓보드로 이동
              Navigator.pushNamed(context, PocketBoard.routeName,
                arguments: PgData(pgSn: item.pocketSn,),);
            },),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item != null ? item.pocketName : '', style: TStyle.commonTitle,),
              //
              Row(
                children: [
                  Text((index+1).toString(), style: TStyle.commonSTitle,),
                  Text(' / $totSize'),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}