/// 현재가(20분 지연) 조회
class TrSearch01 {
  final String retCode;
  final String retMsg;
  final Search01? retData;

  TrSearch01({this.retCode = '', this.retMsg = '', this.retData});

  factory TrSearch01.fromJson(Map<String, dynamic> json) {
    return TrSearch01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? null : Search01.fromJson(json['retData']),
    );
  }
}

const defSearch01 = Search01();

class Search01 {
  final String stockCode;
  final String stockName;
  final String isMyStock; //포켓 등록 여부 Y/N
  final String myTradeFlag; //isMyStock 이 "Y"일 경우, 존재하며 w:관심, 보유:h
  final String pocketSn;
  final String tradeDate;
  final String tradeTime;
  final String timeDivTxt;
  final String currentPrice;
  final String fluctuationRate; //등락률(전일비) > div에 따라서 바뀜
  final String fluctuationAmt; //등락금액(전일비) > div에 따라서 바뀜
  final String tradingHaltYn;
  final List<Search01BuyPrice> listBuyPrice;

  const Search01({
    this.stockCode = '',
    this.stockName = '',
    this.isMyStock = '',
    this.myTradeFlag = '',
    this.pocketSn = '',
    this.tradeDate = '',
    this.tradeTime = '',
    this.timeDivTxt = '',
    this.currentPrice = '',
    this.fluctuationRate = '',
    this.fluctuationAmt = '',
    this.tradingHaltYn = '',
    this.listBuyPrice = const [],
  });

/*  Search01.withoutPocketSn({
    this.stockCode = '',
    this.stockName = '',
    this.isMyStock = '',
    this.myTradeFlag = '',
    this.tradeDate = '',
    this.tradeTime = '',
    this.timeDivTxt = '',
    this.currentPrice = '',
    this.fluctuationRate = '',
    this.fluctuationAmt = '',
    this.tradingHaltYn = '',
    this.listBuyPrice = const [],
  }) : pocketSn = '';*/

  factory Search01.fromJson(Map<String, dynamic> json) {
    return Search01(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      isMyStock: json['isMyStock'],
      myTradeFlag: json['myTradeFlag'] ?? '',
      pocketSn: json['pocketSn'],
      tradeDate: json['tradeDate'],
      tradeTime: json['tradeTime'],
      timeDivTxt: json['timeDivTxt'],
      currentPrice: json['currentPrice'],
      fluctuationRate: json['fluctuationRate'],
      fluctuationAmt: json['fluctuationAmt'],
      tradingHaltYn: json['tradingHaltYn'],
      listBuyPrice: json['list_buyPrice'] == null
          ? []
          : (json['list_buyPrice'] as List).map((e) => Search01BuyPrice.fromJson(e)).toList(),
    );
  }
}

class Search01BuyPrice {
  final String setPrice;
  final String resultDiv;

  Search01BuyPrice({
    this.setPrice = '',
    this.resultDiv = '',
  });

  factory Search01BuyPrice.fromJson(Map<String, dynamic> json) {
    return Search01BuyPrice(
      setPrice: json['setPrice'] ?? '0',
      resultDiv: json['resultDiv'] ?? '',
    );
  }
}
