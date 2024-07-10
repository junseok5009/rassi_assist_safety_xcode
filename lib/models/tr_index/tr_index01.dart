import 'package:rassi_assist/models/tr_atom.dart';


/// 2020.10.14
/// 오늘 지수 정보
class TrIndex01 extends TrAtom {
  final Index01 retData;

  TrIndex01({
    String retCode = '',
    String retMsg = '',
    this.retData = defIndex01,
  }) : super(retCode: retCode, retMsg: retMsg);

  factory TrIndex01.fromJson(Map<String, dynamic> json) {
    return TrIndex01(
        retCode: json['retCode'],
        retMsg: json['retMsg'],
        retData: json['retData'] == null
            ? defIndex01
            : Index01.fromJson(json['retData']),
    );
  }
}

const defIndex01 = Index01();
const dfKospi = Kospi();
const dfKosdaq = Kosdaq();

class Index01 {
  final String baseTime;
  final String marketTimeDiv; // N : 장 시작전, B: 장전, O:장중, C:장마감
  final Kospi kospi;
  final Kosdaq kosdaq;

  const Index01({
    this.baseTime = '',
    this.marketTimeDiv = '',
    this.kospi = dfKospi,
    this.kosdaq = dfKosdaq,
  });

/*  Index01.empty(){
    baseTime = '';
    marketTimeDiv = '';
    kospi = Kospi.empty();
    kosdaq = Kosdaq.empty();
  }*/

  bool isEmpty(){
    return this.baseTime.isEmpty || this.marketTimeDiv.isEmpty /*|| kospi.isEmpty() || kosdaq.isEmpty()*/;
  }

  factory Index01.fromJson(Map<String, dynamic> json) {
    return Index01(
      baseTime: json['baseTime'] ?? '',
      marketTimeDiv: json['marketTimeDiv'] ?? '',
      kospi: json['stru_Kospi'] == null ? dfKospi : Kospi.fromJson(json['stru_Kospi']),
      kosdaq: json['stru_Kosdaq'] == null ? dfKosdaq : Kosdaq.fromJson(json['stru_Kosdaq']),
    );
  }

  @override
  String toString() {
    return baseTime;
  }
}


class Kospi {
  final String priceIndex;
  final String indexFluctuation;
  final String fluctuationRate;

  const Kospi({
    this.priceIndex = '',
    this.indexFluctuation = '',
    this.fluctuationRate = '',
  });

/*  Kospi.empty(){
    priceIndex = '';
    indexFluctuation = '';
    fluctuationRate = '';
  }*/
  bool isEmpty(){
    return priceIndex.isEmpty || indexFluctuation.isEmpty || fluctuationRate.isEmpty;
  }
  factory Kospi.fromJson(Map<String, dynamic> json) {
    return Kospi(
      priceIndex: json['priceIndex'] ?? '',
      indexFluctuation: json['indexFluctuation'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
    );
  }
  @override
  String toString() {
    return '$priceIndex|$indexFluctuation|$fluctuationRate';
  }
}

class Kosdaq {
  final String priceIndex;
  final String indexFluctuation;
  final String fluctuationRate;

  const Kosdaq({
    this.priceIndex = '',
    this.indexFluctuation = '',
    this.fluctuationRate = '',
  });

/*  Kosdaq.empty(){
    priceIndex = '';
    indexFluctuation = '';
    fluctuationRate = '';
  }*/
  bool isEmpty(){
    return priceIndex.isEmpty || indexFluctuation.isEmpty || fluctuationRate.isEmpty;
  }
  factory Kosdaq.fromJson(Map<String, dynamic> json) {
    return Kosdaq(
      priceIndex: json['priceIndex'] ?? '',
      indexFluctuation: json['indexFluctuation'] ?? '',
      fluctuationRate: json['fluctuationRate'] ?? '',
    );
  }
  @override
  String toString() {
    return '$priceIndex|$indexFluctuation|$fluctuationRate';
  }
}
