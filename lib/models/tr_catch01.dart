import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/tr_atom.dart';

/// 2020.10.06
/// 캐치 간략 조회
class TrCatch01 extends TrAtom {
  final Catch01 retData;

  TrCatch01({String retCode = '', String retMsg = '', this.retData = defCatch01})
      : super(retCode: retCode, retMsg: retMsg);

  factory TrCatch01.fromJson(Map<String, dynamic> json) {
    return TrCatch01(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null ? defCatch01 : Catch01.fromJson(json['retData']));
  }
}

const defCatch01 = Catch01();

class Catch01 {
  final String catchSn;
  final String issueTmTx;
  final String title;
  final List<Stock> listStock;

  const Catch01({
    this.catchSn = '',
    this.issueTmTx = '',
    this.title = '',
    this.listStock = const [],
  });

  factory Catch01.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    List<Stock> listData = list.map((e) => Stock.fromJson(e)).toList();

    return Catch01(
      catchSn: json['catchSn'],
      issueTmTx: json['issueTmTx'],
      title: json['title'],
      listStock: listData,
    );
  }
}

// AI 매매신호 페이지 캐치 부분 종목
class TileStockCatch extends StatelessWidget {
  final Stock item;

  const TileStockCatch(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
      decoration: const BoxDecoration(
        color: RColor.bgSkyBlue,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Center(
        child: Text(
          item.stockName,
          style: TStyle.commonSTitle,
          maxLines: 1,
          overflow: TextOverflow.clip,
        ),
      ),
    );
  }
}
