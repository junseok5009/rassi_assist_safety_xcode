
/// 인기 종목 TOP (관심종목 추가 건수 or 네이버 검색 상위)
class TrSearch03 {
  final String retCode;
  final String retMsg;
  final List<Search03>? retData;

  TrSearch03({this.retCode = '', this.retMsg = '', this.retData});

  factory TrSearch03.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<Search03>? rtList;
    list == null ? rtList = null : rtList = list.map((i) => Search03.fromJson(i)).toList();

    return TrSearch03(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: rtList,
    );
  }
}


class Search03 {
  final String stockCode;
  final String stockName;
  final String updateDttm;

  Search03({this.stockCode = '', this.stockName = '', this.updateDttm = ''});

  factory Search03.fromJson(Map<String, dynamic> json) {
    return Search03(
      stockCode: json['stockCode'],
      stockName: json['stockName'],
      updateDttm: json['updateDttm'],
    );
  }
}

