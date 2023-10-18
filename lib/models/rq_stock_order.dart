

/// Json 을 생성해보는 클래스
/// request object
/// https://bezkoder.com/dart-flutter-convert-object-to-json-string/
class StockOrder {
  final String userId;
  final String pocketSn;
  final List<SeqStock>? tags;

  StockOrder(this.userId, this.pocketSn, [this.tags]);   // [] 이 표시는 없을 수도 있다는 표시인듯

  Map toJson() {
    List<Map>? seq = tags != null ? tags?.map((e) => e.toJson()).toList() : null;
    return {
      'userId': userId,
      'pocketSn': pocketSn,
      'list_Stock': seq,
    };
  }
}


class SeqStock {
  final String stockCode;
  final String viewSeq;

  SeqStock(this.stockCode, this.viewSeq);

  Map toJson() => {
    'stockCode': stockCode,
    'viewSeq': viewSeq,
  };
}


