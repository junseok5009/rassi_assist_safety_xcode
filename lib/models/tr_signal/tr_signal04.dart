
/// 2021.08.03
/// 매매신호 발생 추이와 코스피/코스닥 지수 비교
class TrSignal04 {
  final String retCode;
  final String retMsg;
  final Signal04? retData;

  TrSignal04({
    this.retCode = '',
    this.retMsg = '',
    this.retData
  });

  factory TrSignal04.fromJson(Map<String, dynamic> json) {
    return TrSignal04(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: Signal04.fromJson(json['retData'])
    );
  }
}


class Signal04 {
  final String dayOrWeek;   //D: 일일데이터, W: 주차별 데이터
  final String indexHigh;
  final String indexLow;
  final String sigCntMax;
  final String sigCntMin;
  final String sigCntAvg;
  final List<SigGenData> listChart;

  Signal04({
    this.dayOrWeek='', this.indexHigh='', this.indexLow='',
    this.sigCntMax='', this.sigCntMin='', this.sigCntAvg='',
    this.listChart = const [],
  });

  factory Signal04.fromJson(Map<String, dynamic> json) {
    var list = json['list_Chart'] as List;
    List<SigGenData> listData = [];
    if(list!=null) listData = list.map((e) => SigGenData.fromJson(e)).toList();

    return Signal04(
      dayOrWeek: json['dayOrWeek'],
      indexHigh: json['indexHigh'],
      indexLow: json['indexLow'],
      sigCntMax: json['sigCntMax'],
      sigCntMin: json['sigCntMin'],
      sigCntAvg: json['sigCntAvg'],
      listChart: listData,
    );
  }
}

//매매신호 & 지수 정보
class SigGenData {
  final String date;    //거래일자
  final String index;   //시장지수
  final String count;   //신호 발생 건수

  SigGenData({this.date='', this.index='', this.count=''});

  factory SigGenData.fromJson(Map<String, dynamic> json) {
    return SigGenData(
      date: json['d'],
      index: json['i'],
      count: json['c'],
    );
  }

  @override
  String toString() {
    return '$date|$index|$count';
  }
}
