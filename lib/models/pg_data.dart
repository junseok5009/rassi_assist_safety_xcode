

/// 페이지에 전달되는 데이터들
class PgData {
  final String userId;
  final String stockCode;
  final String stockName;
  final String flag;
  final String pgData;
  final String pgSn;
  final String data; // pay promotion code
  final bool booleanData;

  PgData({
    this.userId = '',
    this.stockCode = '',
    this.stockName = '',
    this.flag = '',
    this.pgData = '',
    this.pgSn = '',
    this.data = '',
    this.booleanData = false, // TODO 이 내용이 어디서 쓰이는지 확인 필요
  });

  bool isStockDataExist() {
    if(stockName.isEmpty) {
      return false;
    } else if(stockCode.isEmpty) {
      return false;
    } else{
      return true;
    }
  }
}

