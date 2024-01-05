import 'package:rassi_assist/models/tr_search/tr_search01.dart';

class TrSearch12 {
  final String retCode;
  final String retMsg;
  final Search12? retData;

  TrSearch12({this.retCode = '', this.retMsg = '', this.retData});

  factory TrSearch12.fromJson(Map<String, dynamic> json) {
    return TrSearch12(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? null : Search12.fromJson(json['retData']),
    );
  }
}

class Search12DivModel {
  final String divName;
  final String divCode;

  Search12DivModel({
    this.divName = '',
    this.divCode = '',
  });

  List<Search12DivModel> getListDate() {
    return List.generate(6, (index) {
      String divName = '';
      String divCode = '';
      switch (index) {
        case 0:
          {
            divName = '1D';
            divCode = 'D1';
            break;
          }
        case 1:
          {
            divName = '1M';
            divCode = 'M1';
            break;
          }
        case 2:
          {
            divName = '3M+E';
            divCode = 'M3';
            break;
          }
        case 3:
          {
            divName = 'YTD';
            divCode = 'YTD';
            break;
          }
        case 4:
          {
            divName = '1Y';
            divCode = 'Y1';
            break;
          }
        case 5:
          {
            divName = '3Y';
            divCode = 'Y3';
            break;
          }
      }
      return Search12DivModel(divName: divName, divCode: divCode);
    });
  }

  List<Search12DivModel> getListEvent() {
    return List.generate(5, (index) {
      String divName = '';
      String divCode = '';
      switch (index) {
        case 0:
          {
            divName = '이슈\n발생';
            divCode = 'IS';
            break;
          }
        case 1:
          {
            divName = '커뮤\n니티';
            divCode = 'CM';
            break;
          }
        case 2:
          {
            divName = '시세\n특이';
            divCode = 'SS';
            break;
          }
        case 3:
          {
            divName = '공시\n발생';
            divCode = 'DC';
            break;
          }
        case 4:
          {
            divName = '실적\n발표';
            divCode = 'PM';
            break;
          }
      }
      return Search12DivModel(divName: divName, divCode: divCode);
    });
  }
}

class Search12 {
  final String selectDiv;
  final String beforeOpening;
  final String beforeChart;
  final Search01? search01;
  final String basePrice;
  final List<Search12ChartData> listPriceChart;

  Search12({
    this.selectDiv = '',
    this.beforeOpening = '',
    this.search01,
    this.basePrice = '',
    this.beforeChart = '',
    this.listPriceChart = const [],
  });

  factory Search12.fromJson(Map<String, dynamic> json) {
    bool isBeforeData = false;
    String selectDiv = json['selectDiv'] ?? '';
    String basePrice = json['basePrice'] ?? '';
    String beforeOpening = json['beforeOpening'] ?? '';
    String beforeChart = json['beforeChart'] ?? '';
    return Search12(
      selectDiv: selectDiv,
      beforeOpening: beforeOpening,
      beforeChart: beforeChart,
      search01: Search01.fromJson(json['struct_Price']),
      basePrice: basePrice,
      listPriceChart: json['list_PriceChart'] == null
          ? []
          : ((json['list_PriceChart']) as List).asMap().entries.map((e) {
              if (!isBeforeData && selectDiv == "D1" && beforeOpening == 'N' && beforeChart == 'N') {
                String dd = e.value['tp'] ?? '';
                if (dd.isEmpty) {
                  e.value['tp'] = basePrice;
                  //return ChartData.fromJson(e.value, e.key);
                } else {
                  isBeforeData = true;
                }
              }
              return Search12ChartData.fromJson(e.value, e.key);
            }).toList(),
    );
  }
}

class Search12ChartData {
  String td = ''; //날짜
  String tt = ''; //시간 > D1 에서만 사용
  String tp = ''; //종가
  String fr = ''; //등락률
  String ec = ''; //이벤트
  List<String> titleList = [];
  int index = 0;

  Search12ChartData({
    this.td = '',
    this.tt = '',
    this.tp = '',
    this.fr = '',
    this.ec = '',
    this.titleList = const [],
    this.index = 0,
  });

  Search12ChartData.empty() {
    td = '';
    tt = '';
    tp = '';
    fr = '';
    ec = '';
    titleList = [];
    index = 0;
  }

  factory Search12ChartData.fromJson(Map<String, dynamic> json, int vInedx) {
    return Search12ChartData(
      td: json['td'] ?? '',
      tt: json['tt'] ?? '',
      tp: json['tp'] ?? '',
      fr: json['fr'] ?? '0',
      ec: json['ec'] ?? '0',
      titleList: json['titleList'] == null ? [] : (json['titleList'] as List).map((e) => e as String).toList(),
      index: vInedx,
    );
  }

  @override
  String toString() {
    return '$td|$tt|$tp|$ec';
  }
}
