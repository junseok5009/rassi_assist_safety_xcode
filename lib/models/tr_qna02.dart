
/// 2021.02.16
/// QNA 목록
class TrQna02 {
  final String retCode;
  final String retMsg;
  Qna02 retData;

  TrQna02({this.retCode = '', this.retMsg = '', this.retData = defQna02, });

  factory TrQna02.fromJson(Map<String, dynamic> json) {
    return TrQna02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? defQna02 : Qna02.fromJson(json['retData']),
    );
  }
}

const defQna02 = Qna02();

class Qna02 {
  final String totalPageSize;
  final String currentPageNo;
  final List<QnaItem> listData;

  const Qna02({this.totalPageSize = '', this.currentPageNo = '', this.listData = const [],});

  factory Qna02.fromJson(Map<String, dynamic> json) {
    var list = json['list_Qna'] as List;
    List<QnaItem>? rtList;
    list == null ? rtList = null : rtList = list.map((i) => QnaItem.fromJson(i)).toList();

    return Qna02(
      totalPageSize: json['totalPageSize'],
      currentPageNo: json['currentPageNo'],
      listData: list.map((i) => QnaItem.fromJson(i)).toList(),
    );
  }

  @override
  String toString() {
    return '$totalPageSize|$currentPageNo';
  }
}


class QnaItem {
  final String qnaSn;
  final String qnaStatus;
  final String regDate;
  final String title;

  QnaItem({
    this.qnaSn = '',
    this.qnaStatus = '',
    this.regDate = '',
    this.title = ''
  });

  factory QnaItem.fromJson(Map<String, dynamic> json) {
    return QnaItem(
      qnaSn: json['qnaSn'],
      qnaStatus: json['qnaStatus'],
      regDate: json['regDate'],
      title: json['title'],
    );
  }
}