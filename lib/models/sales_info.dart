
/// 종목비교 차트 데이터 - SalesInfo
class SalesInfo {
  final String year;            //연도 (YYYY)
  final String quarter;         //분기 (= 1, 2, 3, 4)
  final String salesRateQuart;  // 매출액
  final String salesRateYear;   // 영업 이익
  final String profitRateQuart; // per
  final String profitRateYear;  // pbr
  final String dividendYear;    // 배당 연도 (YYYY)
  final String dividendRate;    // 배당 수익률
  final String dividendAmt;     // 배당금액

  SalesInfo({
    this.year = '',
    this.quarter = '',
    this.salesRateQuart = '',
    this.salesRateYear = '',
    this.profitRateQuart = '',
    this.profitRateYear = '',
    this.dividendYear = '',
    this.dividendRate = '',
    this.dividendAmt = '',
  });

  factory SalesInfo.fromJson(Map<String, dynamic> json) {
    return SalesInfo(
      year: json['year'] ?? '',
      quarter: json['quarter'] ?? '',
      salesRateQuart: json['salesRateQuart'] ?? '',
      salesRateYear: json['salesRateYear'] ?? '',
      profitRateQuart: json['profitRateQuart'] ?? '',
      profitRateYear: json['profitRateYear'] ?? '',
      dividendYear: json['dividendYear'] ?? '',
      dividendRate: json['dividendRate'] ?? '',
      dividendAmt: json['dividendAmt'] ?? '',
    );
  }

  @override
  String toString() {
    return '$year|$quarter|$salesRateQuart|$salesRateYear|$profitRateQuart|'
        '$profitRateYear|$dividendYear|$dividendRate|$dividendAmt';
  }
}

