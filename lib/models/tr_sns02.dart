import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';


/// 2020.12.15
/// 종목 소셜지수 일자별 조회
class TrSns02 {
  final String retCode;
  final String retMsg;
  final List<Sns02> listData;

  TrSns02({this.retCode = '', this.retMsg = '', this.listData = const [],});

  factory TrSns02.fromJson(Map<String, dynamic> json) {
    var list = json['retData'] as List;
    List<Sns02>? rtList;
    list == null ? rtList = null : rtList = list.map((i) => Sns02.fromJson(i)).toList();

    return TrSns02(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: list.map((i) => Sns02.fromJson(i)).toList(),
    );
  }
}

class Sns02 {
  final String issueDate;
  final String concernGrade;

  Sns02({this.issueDate = '', this.concernGrade = '',});

  factory Sns02.fromJson(Map<String, dynamic> json) {
    return Sns02(
      issueDate: json['issueDate'],
      concernGrade: json['concernGrade'],
    );
  }
}

//화면구성
class TileSns02 extends StatelessWidget {
  final Sns02 item;
  TileSns02(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.only(left: 15.0, right: 15.0,),
      decoration: const BoxDecoration(
        color: RColor.bgWeakGrey,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _setListItem1(),
              _setListItem2(),
            ],
          ),
        ),
        onTap: (){
          //TODO 상세뷰로 이동
          // print(item.stockCode);
        },
      ),
    );
  }

  Widget _setListItem1() {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: Colors.grey, width: 1),
            right: BorderSide(color: Colors.grey, width: 1),),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.issueDate, style: TStyle.content14,),
          ],
        ),
      ),
    );
  }

  Widget _setListItem2() {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_getSocialString(item.concernGrade), style: TStyle.content14,),
          ],
        ),
      ),
    );
  }

  String _getSocialString(String num) {
    if(num == '1') return '조용';
    else if(num == '2') return '수군';
    else if(num == '3') return '왁자지껄';
    else if(num == '4') return '폭발';
    return '';
  }
}