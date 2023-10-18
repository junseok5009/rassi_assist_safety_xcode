import 'package:flutter/material.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/pg_data.dart';
import 'package:rassi_assist/models/tr_atom.dart';
import 'package:rassi_assist/ui/news/catch_viewer.dart';

/// 2020.10.06
/// 캐치 목록 조회
class TrCatch03 extends TrAtom {
  final List<Catch03> retData;

  TrCatch03({String retCode = '', String retMsg = '', this.retData = const []})
      : super(retCode: retCode, retMsg: retMsg);

  factory TrCatch03.fromJson(Map<String, dynamic> json) {
    return TrCatch03(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: (json['retData'] == null) ? [] : (json['retData'] as List).map((i) => Catch03.fromJson(i)).toList() ?? [],
    );
  }
}

//(화면구성)
class Catch03 {
  final String catchSn;
  final String issueTmTx;
  final String title;

  Catch03({
    this.catchSn = '',
    this.issueTmTx = '',
    this.title = '',
  });

  factory Catch03.fromJson(Map<String, dynamic> json) {
    return Catch03(
      catchSn: json['catchSn'],
      issueTmTx: json['issueTmTx'],
      title: json['title'],
    );
  }

  @override
  String toString() {
    return '$catchSn|$issueTmTx|$title';
  }
}

//화면구성
class TileCatch03 extends StatelessWidget {
  final Catch03 item;

  const TileCatch03(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 110,
      margin: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 10.0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'images/rassi_itemar_icon_ar1.png',
                fit: BoxFit.cover,
                scale: 3,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                item.issueTmTx,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.deepOrangeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          _setRoundBox(context),
        ],
      ),
    );
  }

  Widget _setRoundBox(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: 70,
        padding: const EdgeInsets.all(10.0),
        decoration: UIStyle.boxRoundLine6(),
        alignment: Alignment.centerLeft,
        child: Text(
          item.title,
          style: TStyle.subTitle16,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            _createRouteData(
                CatchViewer(),
                RouteSettings(
                  arguments: PgData(userId: '', pgSn: item.catchSn),
                )));
      },
    );
  }

  //페이지 전환 에니메이션 (데이터 전달)
  Route _createRouteData(Widget instance, RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => instance,
      settings: settings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
