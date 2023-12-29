class TrShome07 {
  final String retCode;
  final String retMsg;
  final Shome07? retData;

  TrShome07({this.retCode='', this.retMsg='', this.retData});

  factory TrShome07.fromJson(Map<String, dynamic> json) {
    return TrShome07(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData:
            json['retData'] == null ? null : Shome07.fromJson(json['retData']));
  }
}

class Shome07 {
  String stockCode='';
  String stockName='';
  List<Shome07StockContent> listStockContent =[];

  Shome07({
    this.stockCode='',
    this.stockName='',
    this.listStockContent=const[],
  });

  Shome07.empty() {
    stockCode = '';
    stockName = '';
    listStockContent = [];
  }

  factory Shome07.fromJson(Map<String, dynamic> json) {
    return Shome07(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      listStockContent: json['listStockContent'] == null
          ? []
          : (json['listStockContent'] as List)
              .map((e) => Shome07StockContent.fromJson(e)).toList(),
    );
  }
}

class Shome07StockContent {
  String contentDiv='';
  String title='';
  String content='';
  String updateDate='';

  Shome07StockContent({
    this.contentDiv='',
    this.title='',
    this.content='',
    this.updateDate='',
  });

  Shome07StockContent.empty() {
    contentDiv = '';
    title = '';
    content = '';
    updateDate = '';
  }

  factory Shome07StockContent.fromJson(Map<String, dynamic> json) {
    return Shome07StockContent(
      contentDiv: json['contentDiv'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      updateDate: json['updateDate'] ?? '',
    );
  }
}
