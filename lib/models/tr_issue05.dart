

///2021.02.25
///이슈 히스토리 조회
class TrIssue05 {
  final String retCode;
  final String retMsg;
  final List<Issue05>? listData;

  TrIssue05({this.retCode = '', this.retMsg = '', this.listData});

  factory TrIssue05.fromJson(Map<String, dynamic> json) {
    List<Issue05>? rtList;
    if(json['retData'] != null) {
      var list = json['retData']['list_Issue'] as List;
      list == null ? rtList = null : rtList = list.map((i) => Issue05.fromJson(i)).toList();
    }

    return TrIssue05(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        listData: rtList
    );
  }
}


class Issue05 {
  final String newsSn;
  final String issueDttm;
  final String title;
  final String content;
  final String issueSn;
  final String keyword;
  final String imageUrl;

  Issue05({
    this.newsSn = '', this.issueDttm = '',
    this.title = '', this.content = '',
    this.issueSn = '', this.keyword = '',
    this.imageUrl = ''
  });

  factory Issue05.fromJson(Map<String, dynamic> json) {
    return Issue05(
      newsSn: json['newsSn'],
      issueDttm: json['issueDttm'],
      title: json['title'],
      content: json['content'],
      issueSn: json['issueSn'],
      keyword: json['keyword'],
      imageUrl: json['imageUrl'],
    );
  }
}
