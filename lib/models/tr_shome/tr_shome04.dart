class TrShome04 {
  final String retCode;
  final String retMsg;
  final Shome04 retData;

  TrShome04({this.retCode='', this.retMsg='', this.retData = defShome04});

  factory TrShome04.fromJson(Map<String, dynamic> json) {
    return TrShome04(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null
            ? defShome04
            : Shome04.fromJson(json['retData'])
    );
  }
}

const defShome04 = Shome04();
class Shome04 {
  final Shome04Stock shome04stock;
  final Shome04Price shome04price;
  final List<Shome04Issue>? listShome04Issue;

  const Shome04({
    this.shome04stock = defShome04Stock,
    this.shome04price = defShome04Price,
    this.listShome04Issue,
  });

/*  Shome04.empty(){
    shome04stock = defShome04Stock;
    shome04price = Shome04Price.empty();
    listShome04Issue = [];
  }*/

  factory Shome04.fromJson(Map<String, dynamic> json) {
    var list = json['list_Issue'] as List;
    List<Shome04Issue> listData =
    list == null ? [] : list.map((e) => Shome04Issue.fromJson(e)).toList();
    return Shome04(
      shome04stock: Shome04Stock.fromJson(json['struct_Stock']) ?? defShome04Stock,
      shome04price: Shome04Price.fromJson(json['struct_Price']) ?? defShome04Price,
      listShome04Issue: listData,
    );
  }
}


const defShome04Stock = Shome04Stock();
class Shome04Stock {
  final String stockCode;
  final String stockName;
  final String isMyStock;
  final String pocketSn;
  final String bizOverview;     // 기업 개요
  final String sectorName;      // 업종 이름
  final String managedStockYn;  // 관리 종목 여부
  final String tradingHaltYn;   // 거래 정지 여부
  final String investStatus;    // 투자 상태

  const Shome04Stock({
    this.stockCode='',
    this.stockName='',
    this.isMyStock='',
    this.pocketSn='',
    this.bizOverview='',
    this.sectorName='',
    this.managedStockYn='',
    this.tradingHaltYn='',
    this.investStatus='',
  });
  // Shome04Stock.empty(){
  //   stockCode = '';
  //   stockName = '';
  //   isMyStock = '';
  //   pocketSn = '';
  //   bizOverview = '';
  //   sectorName = '';
  //   managedStockYn = '';
  //   tradingHaltYn = '';
  //   investStatus = '';
  // }
  factory Shome04Stock.fromJson(Map<String, dynamic> json) {
    return Shome04Stock(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      isMyStock: json['isMyStock'] ?? '',
      pocketSn: json['pocketSn'] ?? '',
      bizOverview: json['bizOverview'] ?? '',         // 기업 개요
      sectorName: json['sectorName'] ?? '',           // 업종 이름
      managedStockYn: json['managedStockYn'] ?? '',   // 관리 종목 여부
      tradingHaltYn: json['tradingHaltYn'] ?? '',     // 투자 상태
      investStatus: json['investStatus'] ?? '',       // 투자 상태
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|$isMyStock|$pocketSn';
  }
}

const defShome04Price = Shome04Price();
class Shome04Price {
  final String stockCode;
  final String stockName;
  final String marketType;      // 시장 (1: KOSPI, 2: KOSDAQ)
  final String currentPrice;    // 종가(현재가)
  final String openPrice;       // 시가
  final String highPrice;       // 고가
  final String lowPrice;        // 저가
  final String accTradeVol;     // 거래수량(단위:주)
  final String accTradeAmt;     // 거래대금(단위:백만원)
  final String fluctuationAmt;  // 등락액(전일비)
  final String fluctuationRate; // 등락률(전일비)
  final String preClosePrice;   // 전일 종가
  final String preAccTradeVol;  // 전일 거래량
  final String marketValue;     // 시가 총액(단위:억원)
  final String marketRank;      // 시총 순위
  final String capital;         // 자본금(단위:억원)
  final String listedShares;    // 상장 주식수(단위:만주)
  final String closingMMDD;     // 결산월일(MMDD)
  final String frnHoldVol;      // 외인 보유수량(단위:천주)
  final String frnHoldRate;     // 외인 보유비율
  final String par;             // 액면가
  final String eps;             // 주당 순이익
  final String per;             // 주가 수익 비율
  final String pbr;             // 주가 순자산 비율
  final String fluctMonth1;     // 1개월 등락률
  final String fluctMonth3;     // 3개월 등락률
  final String fluctYear1;      // 1년 등락률
  final String top52Price;      // 52주 최고가
  final String low52Price;      // 52주 최저가

  const Shome04Price({
    this.stockCode = '',
    this.stockName = '',
    this.marketType = '',
    this.currentPrice = '',
    this.openPrice = '',
    this.highPrice = '',
    this.lowPrice = '',
    this.accTradeVol = '',
    this.accTradeAmt = '',
    this.fluctuationAmt = '',
    this.fluctuationRate = '',
    this.preClosePrice = '',
    this.preAccTradeVol = '',
    this.marketValue = '',
    this.marketRank = '',
    this.capital = '',
    this.listedShares = '',
    this.closingMMDD = '',
    this.frnHoldVol = '',
    this.frnHoldRate = '',
    this.par = '',
    this.eps = '',
    this.per = '',
    this.pbr = '',
    this.fluctMonth1 = '',
    this.fluctMonth3 = '',
    this.fluctYear1 = '',
    this.top52Price = '',
    this.low52Price = '',
  });
/*  Shome04Price.empty(){
    this.stockCode = '';
    this.stockName = '';
    this.marketType = '';
    this.currentPrice = '';
    this.openPrice = '';
    this.highPrice = '';
    this.lowPrice = '';
    this.accTradeVol = '';
    this.accTradeAmt = '';
    this.fluctuationAmt = '';
    this.fluctuationRate = '';
    this.preClosePrice = '';
    this.preAccTradeVol = '';
    this.marketValue = '';
    this.marketRank = '';
    this.capital = '';
    this.listedShares = '';
    this.closingMMDD = '';
    this.frnHoldVol = '';
    this.frnHoldRate = '';
    this.par = '';
    this.eps = '';
    this.per = '';
    this.pbr = '';
    this.fluctMonth1 = '';
    this.fluctMonth3 = '';
    this.fluctYear1 = '';
    this.top52Price = '';
    this.low52Price = '';
  }*/
  factory Shome04Price.fromJson(Map<String, dynamic> json) {
    return Shome04Price(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      marketType: json['marketType'] ?? '',
      currentPrice: json['currentPrice'] ?? '',
      openPrice: json['openPrice'] ?? '',
      highPrice: json['highPrice'] ?? '',
      lowPrice: json['lowPrice'] ?? '',
      accTradeVol: json['accTradeVol'] ?? '',
      accTradeAmt: json['accTradeAmt'] ?? '',
      fluctuationAmt: json['fluctuationAmt'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
      preClosePrice: json['preClosePrice'] ?? '',
      preAccTradeVol: json['preAccTradeVol'] ?? '',
      marketValue: json['marketValue'] ?? '',
      marketRank: json['marketRank'] ?? '',
      capital: json['capital'] ?? '',
      listedShares: json['listedShares'] ?? '',
      closingMMDD: json['closingMMDD'] ?? '',
      frnHoldVol: json['frnHoldVol'] ?? '',
      frnHoldRate: json['frnHoldRate'] ?? '',
      par: json['par'] ?? '',
      eps: json['eps'] ?? '',
      per: json['per'] ?? '',
      pbr: json['pbr'] ?? '',
      fluctMonth1: json['fluctMonth1'] ?? '',
      fluctMonth3: json['fluctMonth3'] ?? '',
      fluctYear1: json['fluctYear1'] ?? '',
      low52Price: json['low52Price'] ?? '',
      top52Price: json['top52Price'] ?? '',
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|';
  }
}

class Shome04Issue {
  final String newsSn;
  final String issueSn;
  final String keyword;
  final String title;

  Shome04Issue({this.newsSn='', this.issueSn='', this.keyword='', this.title='',});

  factory Shome04Issue.fromJson(Map<String, dynamic> json) {
    return Shome04Issue(
      newsSn: json['newsSn'],
      issueSn: json['issueSn'],
      keyword: json['keyword'],
      title: json['title'],
    );
  }
}