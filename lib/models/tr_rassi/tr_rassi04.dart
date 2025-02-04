/// 2020.11.11
/// 라씨로 종목 요약정보 조회
class TrRassi04 {
  final String retCode;
  final String retMsg;
  final Rassi04 resData;

  TrRassi04({this.retCode = '', this.retMsg = '', this.resData = const Rassi04()});

  factory TrRassi04.fromJson(Map<String, dynamic> json) {
    return TrRassi04(
      retCode: json['retCode'] ?? '',
      retMsg: json['retMsg'] ?? '',
      resData: json['retData'] == null ? const Rassi04() : Rassi04.fromJson(json['retData']),
    );
  }
}


class Rassi04 {
  final String content;
  final String todayNewsCount;
  final String monthNewsCount;
  final List<Rassi04News> rassi04NewsList;

  const Rassi04({
    this.content = '',
    this.todayNewsCount = '',
    this.monthNewsCount = '',
    this.rassi04NewsList = const [],
  });

  factory Rassi04.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Rassiro'];
    return Rassi04(
      content: json['content'] ?? '',
      todayNewsCount: json['todayNewsCount'] ?? '',
      monthNewsCount: json['monthNewsCount'] ?? '',
      rassi04NewsList: jsonList == null ? [] : (jsonList as List).map((i) => Rassi04News.fromJson(i)).toList(),
    );
  }
}

// 오늘의 요약 - 뉴스(공시, 실적, 리포트) 추가
class Rassi04News {
  final String newsDiv; // DSC : 공시, SCR : 잠정 실적, RPT : 증권사 리포트
  final String title;
  const Rassi04News({
    this.newsDiv = '',
    this.title = '',
  });
  factory Rassi04News.fromJson(Map<String, dynamic> json) {
    return Rassi04News(
      newsDiv: json['newsDiv'] ?? '',
      title: json['title'] ?? '',
    );
  }
  @override
  String toString() {
    return '$newsDiv|$title';
  }
}

