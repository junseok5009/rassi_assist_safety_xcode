class TrIndex02 {
  final String retCode;
  final String retMsg;
  final Index02 retData;

  TrIndex02({
    this.retCode = '',
    this.retMsg = '',
    this.retData = const Index02(),
  });

  factory TrIndex02.fromJson(Map<String, dynamic> json) {
    return TrIndex02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? const Index02() : Index02.fromJson(json['retData']),
    );
  }
}

class Index02 {
  final String baseDate;
  final String baseTime;
  final String marketTimeDiv; // N : 장 시작전, B: 예상(장전), O:장중, C:장마감
  final Index02KosStruct kospi;
  final Index02KosStruct kosdaq;

  const Index02({
    this.baseDate = '',
    this.baseTime = '',
    this.marketTimeDiv = '',
    this.kospi = const Index02KosStruct(),
    this.kosdaq = const Index02KosStruct(),
  });

  factory Index02.fromJson(Map<String, dynamic> json) {
    return Index02(
      baseDate: json['baseDate'] ?? '',
      baseTime: json['baseTime'] ?? '',
      marketTimeDiv: json['marketTimeDiv'] ?? '',
      //marketTimeDiv: 'B',
      kospi: json['stru_Kospi'] == null ? const Index02KosStruct() : Index02KosStruct.fromJson(json['stru_Kospi']),
      kosdaq: json['stru_Kosdaq'] == null ? const Index02KosStruct() : Index02KosStruct.fromJson(json['stru_Kosdaq']),
    );
  }
}

class Index02KosStruct {
  final String priceIndex;
  final String indexFluctuation;
  final String fluctuationRate;
  final List<Index02KosChart> listKosChart;

  const Index02KosStruct({
    this.priceIndex = '',
    this.indexFluctuation = '',
    this.fluctuationRate = '',
    this.listKosChart = const [],
  });

  factory Index02KosStruct.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Chart'];
    return Index02KosStruct(
      priceIndex: json['priceIndex'] ?? '',
      indexFluctuation: json['indexFluctuation'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
      listKosChart: jsonList == null ? [] : (jsonList as List).map((e) => Index02KosChart.fromJson(e)).toList(),
    );
  }
}

class Index02KosChart {
  final String tt;
  final String ti;
  final String fi;
  final String fr;

  const Index02KosChart({
    this.tt = '',
    this.ti = '',
    this.fi = '',
    this.fr = '',
  });

  factory Index02KosChart.fromJson(Map<String, dynamic> json) {
    return Index02KosChart(
      tt: json['tt'] ?? '',
      ti: json['ti'] ?? '',
      fi: json['fi'] ?? '',
      fr: json['fr'] ?? '',
    );
  }
}
