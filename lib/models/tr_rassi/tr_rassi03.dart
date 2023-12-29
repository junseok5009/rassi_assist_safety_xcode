import 'package:rassi_assist/models/opinion.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/models/tag_info.dart';


/// 라씨로 뉴스 상세
class TrRassi03 {
  final String retCode;
  final String retMsg;
  final Rassi03 retData;

  TrRassi03({this.retCode = '', this.retMsg = '', this.retData = defaultObj});

  factory TrRassi03.fromJson(Map<String, dynamic> json) {
    return TrRassi03(
      retCode: json['retCode'] ?? '',
      retMsg: json['retMsg'] ?? '',
      retData: json['retData'] == null ? defaultObj : Rassi03.fromJson(json['retData']['struct_Rassiro']),
    );
  }

}

const defaultObj = Rassi03(newsDiv: '', issueDttm: '', title: '',
    content: '', listTag: [], listStock: [], listOpinion: []);

class Rassi03 {
  final String newsDiv;
  final String issueDttm;
  final String title;
  final String content;
  final List<Tag> listTag;
  final List<Stock> listStock;
  final List<Opinion> listOpinion;

  const Rassi03({
    this.newsDiv = '',
    this.issueDttm = '',
    this.title = '',
    this.content = '',
    this.listTag = const [],
    this.listStock = const [],
    this.listOpinion = const [],
  });

  factory Rassi03.fromJson(Map<String, dynamic> json) {
    // List<Tag>? rtTagList;
    // List<Stock>? rtStkList;
    // List<Opinion>? rtOpnList;

    var listT = json['list_Tag'] as List;
    // listT == null ? rtTagList = null : rtTagList = listT.map((i) => Tag.fromJson(i)).toList();
    var listS = json['list_Stock'] as List;
    // listS == null ? rtStkList = null : rtStkList = listS.map((i) => Stock.fromJson(i)).toList();
    var listO = json['list_Opinion'] as List;
    // listO == null ? rtOpnList = null : rtOpnList = listO.map((i) => Opinion.fromJson(i)).toList();

    return Rassi03(
      newsDiv: json['newsDiv'] ?? '',
      issueDttm: json['issueDttm'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      listTag: listT.map((i) => Tag.fromJson(i)).toList(),
      listStock: listS.map((i) => Stock.fromJson(i)).toList(),
      listOpinion: listO.map((i) => Opinion.fromJson(i)).toList(),
    );
  }
}