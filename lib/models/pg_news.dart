
/// 페이지에 전달되는 데이터들
class PgNews {
  final String stockCode;
  final String stockName;
  final String newsSn;
  final String createDate;
  final String tagCode;
  final String tagName;
  final String reportDiv;
  final String linkUrl;

  PgNews({
    this.stockCode = '',
    this.stockName = '',
    this.newsSn = '',
    this.createDate = '',
    this.tagCode = '',
    this.tagName = '',
    this.reportDiv = '',
    this.linkUrl = '',
  });
}
