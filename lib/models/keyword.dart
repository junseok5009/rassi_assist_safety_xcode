

/// 차트 데이터
class Keyword {
  final String newsSn;
  final String issueSn;
  final String keyword;

  Keyword({this.newsSn = '', this.issueSn = '', this.keyword = ''});

  factory Keyword.fromJson(Map<String, dynamic> json) {
    return Keyword(
      newsSn: json['newsSn'] ?? '',
      issueSn: json['issueSn'] ?? '',
      keyword: json['keyword'] ?? '',
    );
  }

  @override
  String toString() {
    return '$newsSn|$issueSn|$keyword';
  }
}