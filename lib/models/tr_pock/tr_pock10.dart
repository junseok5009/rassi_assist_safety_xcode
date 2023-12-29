import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_pkt_chart.dart';

import '../none_tr/stock/stock.dart';

/// 2023.12.05
/// 포켓의 종목별 현황 조회
class TrPock10 {
  final String retCode;
  final String retMsg;
  final Pock10? retData;

  TrPock10({this.retCode = '', this.retMsg = '', this.retData});

  factory TrPock10.fromJson(Map<String, dynamic> json) {
    return TrPock10(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? null : Pock10.fromJson(json['retData']),
    );
  }
}

class Pock10 {
  String selectDiv = '';
  String beforeOpening = '';
  String stockCount = '';
  String pocketSn = '';
  List<StockPktChart> stockList = [];
  List<StockIssueInfo> issueList = [];
  List<StockSupplyDemand> sdList = [];

  Pock10({
    this.selectDiv = '',
    this.beforeOpening = '',
    this.stockCount = '',
    this.pocketSn = '',
    this.stockList = const [],
    this.issueList = const [],
    this.sdList = const [],
  });

  factory Pock10.fromJson(Map<String, dynamic> json) {
    return Pock10(
      selectDiv: json['selectDiv'] ?? '',
      beforeOpening: json['beforeOpening'] ?? '',
      stockCount: json['stockCount'] ?? '0',
      pocketSn: json['pocketSn'] ?? '',
      stockList: json['list_Stock'] == null ? [] : (json['list_Stock'] as List).map((i) => StockPktChart.fromJson(i)).toList(),
      issueList: json['list_Stock'] == null ? [] : (json['list_Stock'] as List).map((i) => StockIssueInfo.fromJson(i)).toList(),
      sdList: json['list_Stock'] == null ? [] : (json['list_Stock'] as List).map((i) => StockSupplyDemand.fromJson(i)).toList(),
    );
  }

  Pock10.emptyWithSelectDiv(String getSelectDiv) {
    selectDiv = getSelectDiv;
    stockList = [];
    issueList = [];
    sdList = [];
  }

  bool isEmpty() {
    if (selectDiv.isEmpty) {
      return true;
    } else {
      if ((selectDiv == 'UP' || selectDiv == 'DN' || selectDiv == 'TS') && (stockList.isNotEmpty)) {
        return false;
      } else if ((selectDiv == 'IS') && (issueList.isNotEmpty)) {
        return false;
      } else if ((selectDiv == 'SP' || selectDiv == 'CH') && (sdList.isNotEmpty)) {
        return false;
      } else {
        return true;
      }
    }
  }

  String getEmptyTitle() {
    if (selectDiv == 'UP') {
      return '오늘 상승한 종목이 없습니다.';
    } else if (selectDiv == 'DN') {
      return '오늘 하락한 종목이 없습니다.';
    } else if (selectDiv == 'TS') {
      return '내 종목 중\n오늘 발생한 매매신호가 없습니다.';
    } else if (selectDiv == 'IS') {
      return '내 종목에 대한 오늘 발생한 이슈가 없습니다.';
    } else if (selectDiv == 'SP') {
      return '수급 특이사항이 없습니다.';
    } else if (selectDiv == 'CH') {
      return '차트 특이사항이 없습니다.';
    } else {
      return '';
    }
  }

  @override
  String toString() {
    return '$pocketSn|$selectDiv|${stockList.length}|${issueList.length}|${sdList.length}|';
  }
}

class Pock10ChartModel {
  final List<FlSpot> listChartData;
  double chartYAxisMin;
  double chartMarkLineYAxis;
  Color? chartLineColor;

  Pock10ChartModel({
    this.listChartData = const [],
    this.chartYAxisMin = 0.0,
    this.chartMarkLineYAxis = 0.0,
    this.chartLineColor,
  });
}

// 포켓종목에 대한 이슈 정보
class StockIssueInfo {
  final String newsSn;
  final String issueDttm;
  final String issueSn;
  final String keyword;
  final String title;
  final String content;
  final String imageUrl;
  final String issueStatus;
  final String avgFluctRate;
  final List<Stock> stockList;

  StockIssueInfo({
    this.newsSn = '',
    this.issueDttm = '',
    this.issueSn = '',
    this.keyword = '',
    this.title = '',
    this.content = '',
    this.imageUrl = '',
    this.issueStatus = '',
    this.avgFluctRate = '',
    this.stockList = const [],
  });

  factory StockIssueInfo.fromJson(Map<String, dynamic> json) {
    return StockIssueInfo(
      newsSn: json['newsSn'] ?? '',
      issueDttm: json['issueDttm'] ?? '',
      issueSn: json['issueSn'] ?? '',
      keyword: json['keyword'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      issueStatus: json['issueStatus'] ?? '',
      avgFluctRate: json['avgFluctRate'] ?? '',
      stockList: json['list_Stock'] == null ? [] : (json['list_Stock'] as List).map((i) => Stock.fromJson(i)).toList(),
    );
  }

  @override
  String toString() {
    return '$keyword|$title|$stockList|';
  }
}

// 포켓종목에 대한 수급 정보, 차트 정보
class StockSupplyDemand {
  final String pocketSn;
  final String pocketName;
  final String stockCode;
  final String stockName;
  final String issueTitle;

  StockSupplyDemand({
    this.pocketSn = '',
    this.pocketName = '',
    this.stockCode = '',
    this.stockName = '',
    this.issueTitle = '',
  });

  factory StockSupplyDemand.fromJson(Map<String, dynamic> json) {
    return StockSupplyDemand(
      pocketSn: json['pocketSn'] ?? '',
      pocketName: json['pocketName'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
      issueTitle: json['issueTitle'] ?? '',
    );
  }

  @override
  String toString() {
    return '$pocketName|$stockName|$issueTitle|';
  }
}
