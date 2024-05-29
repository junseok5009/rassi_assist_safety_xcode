class TrSns06 {
  final String retCode;
  final String retMsg;
  final Sns06 retData;

  TrSns06({this.retCode = '', this.retMsg = '', this.retData = defSns06});

  factory TrSns06.fromJson(Map<String, dynamic> json) {
    var jsonData = json['retData'];
    return TrSns06(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: jsonData == null ? defSns06 : Sns06.fromJson(jsonData),
    );
  }
}

const defSns06 = Sns06();

class Sns06 {
  final String concernGrade;
  final List<SNS06ChartData> listPriceChart;

  const Sns06({
    this.concernGrade = '',
    this.listPriceChart = const [],
  });

  factory Sns06.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_PriceChart'];
    return Sns06(
      concernGrade: json['concernGrade'] ?? '0',
      listPriceChart: jsonList == null
          ? []
          : (jsonList as List)
              .asMap()
              .entries
              .map(
                (e) => SNS06ChartData.fromJsonWithIndex(e.value, e.key),
              )
              .toList(),
    );
  }
}

class SNS06ChartData {
  final String td;
  final String tp; // 가격
  final String ec; // 글 수(건)
  final String cg; // 소셜분석 - 관심 등급(지수) > 1:조용, 2:수군, 3:왁자지껄, 4:폭발
  final String fr; // 변동률
  final int index;

  SNS06ChartData({
    this.td = '',
    this.tp = '',
    this.ec = '',
    this.cg = '',
    this.fr = '',
    this.index = 0,
  });

  factory SNS06ChartData.fromJsonWithIndex(Map<String, dynamic> json, int vIndex) {
    return SNS06ChartData(
      td: json['td'] ?? '',
      tp: json['tp'] ?? '0',
      ec: json['ec'] ?? '0',
      cg: json['cg'] ?? '1',
      fr: json['fr'] ?? '0',
      index: vIndex,
    );
  }

  @override
  String toString() {
    return '$td|$tp|$ec|$cg';
  }
}
