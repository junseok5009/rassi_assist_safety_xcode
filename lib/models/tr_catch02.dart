import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/stock.dart';
import 'package:rassi_assist/models/tr_atom.dart';
import 'package:rassi_assist/ui/main/base_page.dart';


/// 2020.10.06
/// 캐치 Contents 상세 조회
class TrCatch02 extends TrAtom {
  final Catch02? retData;

  TrCatch02({String retCode = '', String retMsg = '', this.retData}) :
        super(retCode: retCode, retMsg: retMsg);

  factory TrCatch02.fromJson(Map<String, dynamic> json) {
    return TrCatch02(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null ? null : Catch02.fromJson(json['retData'])
    );
  }
}


class Catch02 {
  final String catchSn;
  final String issueTmTx;
  final String regDate;
  final String title;
  final String content;
  final List<Stock> listStock;

  Catch02({
    this.catchSn = '', this.issueTmTx = '', this.regDate = '',
    this.title = '', this.content = '', this.listStock = const []});

  factory Catch02.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    List<Stock> listData = list.map((e) => Stock.fromJson(e)).toList();

    return Catch02(
      catchSn: json['catchSn'],
      issueTmTx: json['issueTmTx'],
      regDate: json['regDate'],
      title: json['title'],
      content: json['content'],
      listStock: listData,
    );
  }

  @override
  String toString() {
    return '$catchSn|$issueTmTx|$title';
  }
}



// 캐치 하단 종목
class TileStockCatch extends StatelessWidget {
  final Stock item;

  TileStockCatch(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: RColor.lineGrey, width: 0.7,),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),

      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.stockCode, style: TStyle.textSGrey,),
              const SizedBox(height: 7,),
              Text(item.stockName, style: TStyle.subTitle,
                maxLines: 1, overflow: TextOverflow.clip,),
            ],
          ),
        ),
        onTap: (){
          basePageState.goStockHomePage(item.stockCode, item.stockName, Const.STK_INDEX_SIGNAL,);
        },
      ),
    );
  }
}
