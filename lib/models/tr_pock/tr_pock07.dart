
/// 2020.11.12
/// 현재 포켓 매매신호, 매매상태 조회
class TrPock07 {
  final String retCode;
  final String retMsg;
  final Pock07? retData;

  TrPock07({this.retCode='', this.retMsg='', this.retData});

  factory TrPock07.fromJson(Map<String, dynamic> json) {
    return TrPock07(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: Pock07.fromJson(json['retData']),
    );
  }
}


class Pock07 {
  final String noticeText;
  final String remainTime;
  final String stockCount;
  final String buyCount;
  final String sellCount;

  Pock07({
    this.noticeText='',
    this.remainTime='',
    this.stockCount='',
    this.buyCount='',
    this.sellCount=''
  });

  factory Pock07.fromJson(Map<String, dynamic> json) {
    return Pock07(
        noticeText: json['noticeText'],
        remainTime: json['remainTime'] ?? '',
        stockCount: json['stockCount'],
        buyCount: json['buyCount'],
        sellCount: json['sellCount']
    );
  }

  @override
  String toString() {
    return '$noticeText|$remainTime|$stockCount';
  }
}
