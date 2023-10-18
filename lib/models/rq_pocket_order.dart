

/// Json 을 생성해보는 클래스
/// request object
/// https://bezkoder.com/dart-flutter-convert-object-to-json-string/
class PocketOrder {
  String userId;
  List<SeqItem>? tags;

  PocketOrder(this.userId, [this.tags]);   // [] 이 표시는 없을 수도 있다는 표시인듯

  Map toJson() {
    List<Map>? seq =
        tags != null ? tags?.map((e) => e.toJson()).toList() : null;

    return {
      'userId': userId,
      'list_Pocket': seq,
    };
  }
}


class SeqItem {
  final String pocketSn;
  final String viewSeq;

  SeqItem(this.pocketSn, this.viewSeq);

  Map toJson() => {
    'pocketSn': pocketSn,
    'viewSeq': viewSeq,
  };
}


