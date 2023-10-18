
/// RASSI03 > 증권사 리포트 뉴스 > 관련 종목
class Opinion {
  final String issueDate;
  final String goalValue;
  final String opinion;
  final String orgName;

  Opinion({
    this.issueDate = '',
    this.goalValue = '',
    this.opinion = '',
    this.orgName = '',
  });

  factory Opinion.fromJson(Map<String, dynamic> json) {
    return Opinion(
      issueDate: json['issueDate'] ?? '',
      goalValue: json['goalValue'] ?? '',
      opinion: json['opinion'] ?? '',
      orgName: json['orgName'] ?? '',
    );
  }

  @override
  String toString() {
    return '$issueDate|$goalValue|$opinion|$orgName';
  }
}

