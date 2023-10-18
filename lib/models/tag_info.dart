
/// 공통 태그 데이터
class  Tag {
  final String tagCode;
  final String tagName;

  Tag({this.tagCode = '', this.tagName = ''});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      tagCode: json['tagCode'],
      tagName: json['tagName'],
    );
  }

  @override
  String toString() {
    return '$tagCode|$tagName';
  }
}

