import 'package:flutter/material.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_atom.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/sub/keyword_viewer.dart';


/// 2022.05.13
/// 네이버 인기종목의 키워드
class TrKWord03 extends TrAtom {
  final List<String>? retData;

  TrKWord03({String retCode = '', String retMsg = '', this.retData}) :
        super(retCode: retCode, retMsg: retMsg);

  factory TrKWord03.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<String>? rtList;
    list == null ? rtList = null : rtList = list.map((i) => i.toString()).toList();

    return TrKWord03(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: rtList,
    );
  }
}


//(사용안함)
class KWord03 {
  final String keyword;

  KWord03({this.keyword = '',});

  factory KWord03.fromJson(Map<String, dynamic> json) {
    return KWord03(
      keyword: json['keyword'],
    );
  }
}



//화면구성
class ChipKeyword extends StatelessWidget {
  final String item;
  final Color bColor;

  ChipKeyword(this.item, this.bColor);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Chip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Colors.white),
        ),
        label: Text(item, style: TStyle.content15,),
        backgroundColor: bColor,
      ),
      onTap: (){
        basePageState.callPageRouteUpData(KeywordViewer(),
            PgData(userId: '', pgSn: '', pgData: item));
      },
    );
  }
}

// Route _createRoute(PgData pgData) {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) => IssueViewer(),
//     settings: RouteSettings(arguments: pgData),
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       var begin = Offset(0.0, 1.0);
//       var end = Offset.zero;
//       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
//       var offsetAnimation = animation.drive(tween);
//
//       return SlideTransition(
//         position: offsetAnimation,
//         child: child,);
//     },
//   );
// }
