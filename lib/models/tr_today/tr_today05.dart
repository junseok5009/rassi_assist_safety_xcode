

/// 2023.06.22 - JS
/// 땡정보 타임라인 라씨 데스크
class TrToday05 {
  final String retCode;
  final String retMsg;
  final Today05 retData;

  TrToday05({this.retCode='', this.retMsg='', this.retData = defToday05});

  factory TrToday05.fromJson(Map<String, dynamic> json) {
    return TrToday05(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData:
      json['retData'] == null ? defToday05 : Today05.fromJson(json['retData']),
    );
  }
}


const defToday05 = Today05();

class Today05 {
  final String deskTitle;
  final List<RassiroNewsDdInfo> listRassiroNewsDdInfo;

  const Today05({
    this.deskTitle='',
    this.listRassiroNewsDdInfo = const [],
  });

  bool isEmpty() {
    if (listRassiroNewsDdInfo.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  factory Today05.fromJson(Map<String, dynamic> json) {
    var jsonList = json['list_Rassiro'];
    return Today05(
      deskTitle: json['deskTitle'] ?? '',
      listRassiroNewsDdInfo: jsonList == null ? [] : (jsonList as List).map((i) => RassiroNewsDdInfo.fromJson(i)).toList(),
    );
  }
}

class RassiroNewsDdInfo {
  final String contentDiv;
  final String representYn; // 현재 메인에 노출되어야 할 NOW 인 상태일 때 Y
  final String displayYn;
  final String displayTime;
  final String displaySubject;
  final String displayTitle;
  final List<Item> listItem;

  RassiroNewsDdInfo({
    this.contentDiv='',
    this.representYn='',
    this.displayYn='',
    this.displayTime='',
    this.displaySubject='',
    this.displayTitle='',
    this.listItem = const [],
  });

  factory RassiroNewsDdInfo.fromJson(Map<String, dynamic> json) {
    var list = json['list_Item'] as List?;
    List<Item> itemList = [];
    if (list != null) itemList = list.map((i) => Item.fromJson(i)).toList();
    return RassiroNewsDdInfo(
      contentDiv: json['contentDiv'] ?? '',
      representYn: json['representYn'] ?? 'N',
      displayYn: json['displayYn'] ?? '',
      displayTime: json['displayTime'] ?? '',
      displaySubject: json['displaySubject'] ?? '',
      displayTitle: json['displayTitle'] ?? '',
      listItem: itemList,
    );
  }
}

class Item {
  final String itemName;
  final String itemCode;

  Item({
    this.itemName='',
    this.itemCode='',
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemName: json['itemName'] ?? '',
      itemCode: json['itemCode'] ?? '',
    );
  }
}


