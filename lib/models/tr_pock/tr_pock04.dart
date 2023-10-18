

/// 2020.11.10
/// 포켓 상세 조회
class TrPock04 {
  final String retCode;
  final String retMsg;
  final Pock04 retData;

  TrPock04({this.retCode='', this.retMsg='', this.retData = defPock04});

  factory TrPock04.fromJson(Map<String, dynamic> json) {
    return TrPock04(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: Pock04.fromJson(json['retData']),
    );
  }
}

const defPock04 = Pock04();

class Pock04 {
  final PocketInfo pocketInfo;      //포켓정보
  final List<PStock> stkList;       //포켓 안의 종목들

  const Pock04({this.pocketInfo = defPocketInfo, this.stkList = const [],});

  factory Pock04.fromJson(Map<String, dynamic> json) {
    var list = json['list_Stock'] as List;
    // List<PStock>? rtList;
    // list == null ? rtList = null : rtList = list.map((i) => PStock.fromJson(i)).toList();

    return Pock04(
      pocketInfo: PocketInfo.fromJson(json['struct_Pocket']),
      stkList: list.map((i) => PStock.fromJson(i)).toList(),
    );
  }
}

const defPocketInfo = PocketInfo();
//포켓 정보
class PocketInfo {
  final String pocketSn;
  final String pocketName;
  final String pocketSize;

  const PocketInfo({this.pocketSn='', this.pocketName='', this.pocketSize=''});

  factory PocketInfo.fromJson(Map<String, dynamic> json) {
    return PocketInfo(
      pocketSn: json['pocketSn'],
      pocketName: json['pocketName'],
      pocketSize: json['pocketSize'],
    );
  }

  @override
  String toString() {
    return "$pocketSn|$pocketName|$pocketSize";
  }
}

// 포켓 종목
class PStock {
  final String viewSeq;
  final String stockCode;
  final String stockName;
  final String tradeFlag;
  final String myTradeFlag;
  final String buyPrice;
  final String sellDttm;
  final String sellPrice;
  final String profitRate;
  final List<ListTalk> listTalk;

  PStock({
    this.viewSeq='', this.stockCode='',
    this.stockName='', this.tradeFlag='',
    this.myTradeFlag='', this.buyPrice='',
    this.sellDttm='', this.sellPrice='',
    this.profitRate='', this.listTalk = const [],
  });

  factory PStock.fromJson(Map<String, dynamic> json) {
    var list = json['list_Talk'] as List?;
    List<ListTalk>? rtList;
    if(json['list_Talk'] == null) rtList = null;
    else rtList = list?.map((i) => ListTalk.fromJson(i)).toList();

    return PStock(
      viewSeq: json['viewSeq'],
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      tradeFlag: json['tradeFlag'] ?? '',
      myTradeFlag: json['myTradeFlag'] ?? '',
      buyPrice: json['buyPrice'] ?? '',
      sellDttm: json['sellDttm'] ?? '',
      sellPrice: json['sellPrice'] ?? '',
      profitRate: json['profitRate'] ?? '',
      listTalk: rtList ?? [],
    );
  }
}


class ListTalk {
  final String analTarget;
  final String achieveText;

  ListTalk({this.analTarget='', this.achieveText=''});
  factory ListTalk.fromJson(Map<String, dynamic> json) {
    return ListTalk(
      analTarget: json['analTarget'],
      achieveText: json['achieveText'],
    );
  }
}


//화면구성 - 포켓 상세 페이지
// class TilePock04 extends StatelessWidget {
//   final PStock item;
//
//   TilePock04(this.item,);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(left: 12, right: 8,),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         shape: BoxShape.circle,
//       ),
//       child: InkWell(
//         splashColor: Colors.deepPurpleAccent.withAlpha(30),
//         child: Container(
//           width: 90,
//           child: Center(
//             child: Text(item.stockName,
//               style: TStyle.subTitle,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ),
//         onTap: (){
//
//         },
//       ),
//     );
//   }
// }

