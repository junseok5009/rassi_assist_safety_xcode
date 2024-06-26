
/// 2021.02.16
/// QNA 상세 조회
class TrQna03 {
  final String retCode;
  final String retMsg;
  final Qna03 retData;

  TrQna03({this.retCode = '', this.retMsg = '', this.retData = defQna03});

  factory TrQna03.fromJson(Map<String, dynamic> json) {
    return TrQna03(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null ? defQna03 : Qna03.fromJson(json['retData']),
    );
  }
}

const defQna03 = Qna03();

class Qna03 {
  final String qnaSn;
  final String qnaStatus;
  final String regDate;
  final String title;
  final String content;
  final List<Contents> answer;

  const Qna03({
    this.qnaSn = '', this.qnaStatus = '', this.regDate = '',
    this.title = '', this.content = '', this.answer = const []});

  factory Qna03.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Qna'];
    return Qna03(
      qnaSn: json['qnaSn'] ?? '',
      qnaStatus: json['qnaStatus'] ?? '',
      regDate: json['regDate'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      answer: jsonList == null ? [] : (jsonList as List).map((e) => Contents.fromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return '$qnaSn|$title|$content';
  }
}

class Contents {
  final String content;

  Contents({
    this.content = '',
  });

  factory Contents.fromJson(Map<String, dynamic> json) {
    return Contents(
      content: json['content'],
    );
  }
}