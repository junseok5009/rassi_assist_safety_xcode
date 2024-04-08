class TrMgrAgent02 {
  final String retCode;
  final String retMsg;
  final MgrAgent02 retData;

  TrMgrAgent02({this.retCode = '', this.retMsg = '', this.retData = const MgrAgent02()});

  factory TrMgrAgent02.fromJson(Map<String, dynamic> json) {
    var jsonRetData = json['retData'];
    return TrMgrAgent02(
      retCode: json['retCode'],
      retMsg: json['retMsg'] ?? '',
      retData: jsonRetData == null ? const MgrAgent02() : MgrAgent02.fromJson(jsonRetData),
    );
  }
}

class MgrAgent02 {
  final List<MgrAgent02Agent> listAgent;
  const MgrAgent02({
    this.listAgent = const [],
  });
  factory MgrAgent02.fromJson(Map<String, dynamic> json) {
    var jsonListAgent = json['list_Agent'];
    return MgrAgent02(
      listAgent: jsonListAgent == null ? [] : (jsonListAgent as List).map((i) => MgrAgent02Agent.fromJson(i)).toList(),
    );
  }
}

class MgrAgent02Agent {
  final String joinRoute;
  final String routeName;
  final String agentCode;
  final String agentName;
  final String agentSub1;
  final String sub1Name;
  final String agentSub2;
  final String sub2Name;
  final String adminYn;
  final String managerName;
  const MgrAgent02Agent({
    this.joinRoute = '',
    this.routeName = '',
    this.agentCode = '',
    this.agentName = '',
    this.agentSub1 = '',
    this.sub1Name = '',
    this.agentSub2 = '',
    this.sub2Name = '',
    this.adminYn = '',
    this.managerName = '',
  });
  factory MgrAgent02Agent.fromJson(Map<String, dynamic> json) {
    return MgrAgent02Agent(
      joinRoute: json['joinRoute'] ?? '',
      routeName: json['routeName'] ?? '',
      agentCode: json['agentCode'] ?? '',
      agentName: json['agentName'] ?? '',
      agentSub1: json['agentSub1'] ?? '',
      sub1Name: json['sub1Name'] ?? '',
      agentSub2: json['agentSub2'] ?? '',
      sub2Name: json['sub2Name'] ?? '',
      adminYn: json['adminYn'] ?? '',
      managerName: json['managerName'] ?? '',
    );
  }
}