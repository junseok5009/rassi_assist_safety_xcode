/// 2020.09.07
/// 앱 버전 정보 확인
class TrApp02 {
  final String retCode;
  final String retMsg;
  final List<App02> listData;

  TrApp02({
    this.retCode = '',
    this.retMsg = '',
    this.listData = const [],
  });

  factory TrApp02.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<App02> rtList = list.map((i) => App02.fromJson(i)).toList();

    return TrApp02(retCode: json['retCode'], retMsg: json['retMsg'], listData: rtList);
  }
}

class App02 {
  final String menuName;
  final String viewSeq;
  final String imageUrl;
  final String linkType;
  final String linkPage;

  App02({
    this.menuName = '',
    this.viewSeq = '',
    this.imageUrl = '',
    this.linkType = '',
    this.linkPage = '',
  });

  factory App02.fromJson(Map<String, dynamic> json) {
    return App02(
      menuName: json['menuName'] ?? '',
      viewSeq: json['viewSeq'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      linkType: json['linkType'] ?? '',
      linkPage: json['linkPage'] ?? '',
    );
  }

  @override
  String toString() {
    return '$menuName|$viewSeq|$imageUrl|$linkType|$linkPage';
  }
}
