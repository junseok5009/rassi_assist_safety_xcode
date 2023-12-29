class TrNoRetData {
  final String retCode;
  final String retMsg;

  TrNoRetData({this.retCode='', this.retMsg='',});

  factory TrNoRetData.fromJson(Map<String, dynamic> json) {
    return TrNoRetData(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
    );
  }
}