import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/main/search_page.dart';
import 'package:rassi_assist/ui/pocket/pocket_page.dart';


/// 2020.11.05
/// 포켓 리스트
class TrPock03 {
  final String retCode;
  final String retMsg;
  final List<Pock03> listData;

  TrPock03({this.retCode='', this.retMsg='', this.listData = const []});

  factory TrPock03.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<Pock03>? rtList;
    list == null ? rtList = null : rtList = list.map((i) => Pock03.fromJson(i)).toList();

    return TrPock03(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        listData: list.map((i) => Pock03.fromJson(i)).toList(),
    );
  }
}

class Pock03 {
  final String pocketSn;
  final String pocketName;
  final String viewSeq;
  final String pocketSize;
  final String waitCount;
  final String holdCount;

  Pock03({this.pocketSn='', this.pocketName='', this.viewSeq='',
          this.pocketSize='', this.waitCount='', this.holdCount='',});

  factory Pock03.fromJson(Map<String, dynamic> json) {
    return Pock03(
      pocketSn: json['pocketSn'],
      pocketName: json['pocketName'],
      viewSeq: json['viewSeq'],
      pocketSize: json['pocketSize'],
      waitCount: json['waitCount'] ?? 0,
      holdCount: json['holdCount'] ?? 0,
    );
  }

  @override
  String toString() {
    return '$pocketSn | $pocketName';
  }
}


//화면구성 - 종목 추가 BottomSheet
class TilePock03 extends StatelessWidget {
  final Pock03 item;
  const TilePock03(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var waitCnt = int.parse(item.waitCount);
    var holdCnt = int.parse(item.holdCount);
    var totCnt = waitCnt + holdCnt;
    return _setCirclePocket(item.pocketName, "${totCnt.toString()}/${item.pocketSize}");
  }

  //투자수익 Circle
  Widget _setCirclePocket(String pktName, String pktCnt) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      width: 80.0,
      height: 80.0,
      decoration: const BoxDecoration(
        color: RColor.bgSolidSky,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(pktName, style: TStyle.title20, textScaleFactor: Const.TEXT_SCALE_FACTOR,),
          const SizedBox(height: 15.0,),
          const Text('종목수', textScaleFactor: Const.TEXT_SCALE_FACTOR,),
          const SizedBox(height: 5.0,),
          Text(pktCnt, textScaleFactor: Const.TEXT_SCALE_FACTOR,),
        ],
      ),
    );
  }
}

//화면구성 - MY_Page 포켓리스트
class TilePocket extends StatelessWidget {
  final Pock03 item;
  TilePocket(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: RColor.lineGrey, width: 0.7,),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),

      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 47,),
                Chip(label: Text(item.pocketName, textScaleFactor: Const.TEXT_SCALE_FACTOR),
                  backgroundColor: RColor.yonbora,),
                IconButton(
                  icon: const ImageIcon(AssetImage('images/rassibs_pk_icon_plu.png',),),
                  color: Colors.grey,
                  onPressed: (){
                    basePageState.callPageRouteUpData(SearchPage(),
                        PgData(pgSn: item.pocketSn));
                  }
                ),
              ],
            ),
            const SizedBox(height: 7,),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('관심종목 ', textScaleFactor: Const.TEXT_SCALE_FACTOR),
                      Text(item.waitCount, textScaleFactor: Const.TEXT_SCALE_FACTOR),
                    ],
                  ),
                ),
                SizedBox(width: 0.5,
                  child: Container(width: 0.5, height: 20, color: RColor.lineGrey,),),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('보유종목 ', textScaleFactor: Const.TEXT_SCALE_FACTOR),
                      Text(item.holdCount, textScaleFactor: Const.TEXT_SCALE_FACTOR),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
        onTap: (){
          Navigator.pushNamed(
            context,
            PocketPage.routeName,
            arguments: PgData(pgSn: item.pocketSn,),);
        },
      ),
    );
  }

}


//화면구성 - 모든 포켓 리스트 보기
class TilePocketLst extends StatelessWidget {
  final Pock03 item;

  TilePocketLst(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0,),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border.all(color: RColor.lineGrey, width: 0.8,),
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: double.infinity,
          height: 70,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Image.asset('images/main_honor_img_poket.png',
                      fit: BoxFit.cover, height: 40,),
                    const SizedBox(width: 10,),
                    Text(item.pocketName, style: TStyle.subTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,),
                  ],
                ),
              ),
              Row(
                children: [
                  const Text('보유'),
                  Text(item.holdCount, style: TStyle.commonSTitle,),
                  const SizedBox(width: 5.0,),
                  const Text('관심'),
                  Text(item.waitCount, style: TStyle.commonSTitle,),
                ],
              ),
            ],
          ),
        ),
        onTap: () => goPocketPage(context, item.pocketSn),
        // {
        //   //포켓 상세 페이지
        //   Navigator.pushNamed(
        //     context,
        //     PocketPage.routeName,
        //     arguments: PgData(pgSn: item.pocketSn,),);
        // },

      ),
    );
  }

  void goPocketPage(BuildContext context, String pktSn) {
    //TODO 포켓 page
    Navigator.of(context).pushReplacementNamed(PocketPage.routeName,
      arguments: PgData(pgSn: pktSn,),);
  }

}

