

class TrSearch10 {
  final String retCode;
  final String retMsg;
  final Search10 retData;

  TrSearch10({this.retCode='', this.retMsg='', this.retData = defSearch10});

  factory TrSearch10.fromJson(Map<String, dynamic> json) {
    return TrSearch10(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null
            ? defSearch10
            : Search10.fromJson(json['retData']));
  }
}


const defSearch10 = Search10();

class Search10 {
  final String selectDiv;
  final String stockCode;
  final String notApplicable;
  final List<Search10Sales> listSales;
  final List<Search10Issue> listIssue;

  const Search10({
    this.selectDiv='',
    this.stockCode='',
    this.notApplicable='',
    this.listSales = const [],
    this.listIssue = const [],
  });

  factory Search10.fromJson(Map<String, dynamic> json) {
    var list = json['list_Sales'] as List?;
    List<Search10Sales> listData =
        list == null ? [] : list.map((e) => Search10Sales.fromJson(e)).toList();
    var listIssue = json['list_Issue'] as List?;
    List<Search10Issue> listIssueData = listIssue == null
        ? []
        : listIssue.map((e) => Search10Issue.fromJson(e)).toList();
    return Search10(
      selectDiv: json['selectDiv'] ?? '',
      stockCode: json['stockCode'] ?? '',
      notApplicable: json['notApplicable'] ?? '',
      listSales: listData,
      listIssue: listIssueData,
    );
  }
}

class Search10Sales {
  String tradeDate='';
  String tradePrice='';
  String year='';
  String quarter='';
  String sales='';           // 매출액
  String salesProfit='';     // 영업 이익
  String netProfit='';       // 당기 순이익
  String profitRate='';      // 영업 이익률
  String salesIncRateYoY=''; // 매출액 YOY
  String profitIncRateYoY='';// 영업이익 YOY
  String netIncRateYoY='';   // 당기 순이익 YOY
  String confirmYn='';       //확정:Y, 잠정:N (분기 조회시에만 있음)
  String issueDate='';       // confirmYn이 N일때, 잠정실적 발표 날짜

  Search10Sales({
    this.tradeDate='',
    this.tradePrice='',
    this.year='',
    this.quarter='',
    this.sales='',
    this.salesProfit='',
    this.netProfit='',
    this.profitRate='',
    this.salesIncRateYoY='',
    this.profitIncRateYoY='',
    this.netIncRateYoY='',
    this.confirmYn='',
    this.issueDate='',
  });

  Search10Sales.empty(){
    tradeDate = '';
    tradePrice = '';
    year = '';
    quarter = '';
    sales = '';
    salesProfit = '';
    netProfit = '';
    profitRate = '0';
    salesIncRateYoY = '';
    profitIncRateYoY = '';
    netIncRateYoY = '';
    confirmYn = '';
    issueDate = '';
  }

  factory Search10Sales.fromJson(Map<String, dynamic> json) {
    return Search10Sales(
      tradeDate: json['tradeDate'] ?? '',
      tradePrice: json['tradePrice'] ?? '0',
      year: json['year'] ?? '',
      quarter: json['quarter'] ?? '',
      sales: json['sales'] ?? '',
      salesProfit: json['salesProfit'] ?? '',
      netProfit: json['netProfit'] ?? '',
      profitRate: json['profitRate'] ?? '0',
      salesIncRateYoY: json['salesIncRateYoY'] ?? '',
      profitIncRateYoY: json['profitIncRateYoY'] ?? '',
      netIncRateYoY: json['netIncRateYoY'] ?? '',
      confirmYn: json['confirmYn'] ?? '',
      issueDate: json['issueDate'] ?? '',
    );
  }

  @override
  String toString() {
    return '$tradeDate|$tradePrice|$sales|$salesProfit';
  }
}

class Search10Issue {
  final String issueDate;
  final String title;
  final String content;

  Search10Issue({
    this.issueDate='',
    this.title='',
    this.content='',
  });

  factory Search10Issue.fromJson(Map<String, dynamic> json) {
    return Search10Issue(
      issueDate: json['issueDate'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }

  @override
  String toString() {
    return '$issueDate|$title|$content';
  }
}
