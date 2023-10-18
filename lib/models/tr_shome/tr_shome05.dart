class TrShome05 {
  final String retCode;
  final String retMsg;
  final Shome05 retData;

  TrShome05({this.retCode='', this.retMsg='', this.retData = defShome05});

  factory TrShome05.fromJson(Map<String, dynamic> json) {
    return TrShome05(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null
            ? defShome05
            : Shome05.fromJson(json['retData']));
  }
}

const defShome05 = Shome05();
class Shome05 {
  final Shome05StructPrice shome05structPrice;
  const Shome05({
    this.shome05structPrice = defShome05StructPrice
  });

  factory Shome05.fromJson(Map<String, dynamic> json) {
    return Shome05(
      shome05structPrice: Shome05StructPrice.fromJson(json['struct_Price']) ?? defShome05StructPrice,
    );
  }
}

const defShome05StructPrice = Shome05StructPrice();
class Shome05StructPrice {
  final String stockCode;
  final String stockName;
  final String per;
  final String pbr;
  final String eps;
  const Shome05StructPrice({
    this.stockCode='',
    this.stockName='',
    this.per='',
    this.pbr='',
    this.eps='',
  });
/*  Shome05StructPrice.empty(){
    stockCode = '';
    stockName = '';
    per = '';
    pbr = '';
    eps = '';
  }*/
  bool isEmpty(){
    if(per.isEmpty && pbr.isEmpty && eps.isEmpty){
      return true;
    }else{
      return false;
    }
  }
  factory Shome05StructPrice.fromJson(Map<String, dynamic> json) {
    return Shome05StructPrice(
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      per: json['per'] ?? '',
      pbr: json['pbr'] ?? '',
      eps: json['eps'] ?? '',
    );
  }

  @override
  String toString() {
    return '$stockCode|$stockName|';
  }
}