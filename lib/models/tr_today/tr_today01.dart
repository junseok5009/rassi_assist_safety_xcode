import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/ui/main/base_page.dart';


/// 2020.09.01 - JY
///매매비서 오늘의 종목
class TrToday01 {
  final String retCode;
  final String retMsg;
  final List<Today01> listData;

  TrToday01({this.retCode='', this.retMsg='', this.listData = const []});

  factory TrToday01.fromJson(Map<String, dynamic> json) {
    return TrToday01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: json['retData'] == null
          ? []
          : (json['retData'] as List).map((i) => Today01.fromJson(i)).toList(),
    );
  }
}

class Today01 {
  final String stockDiv;
  final String title;
  final String stockCode;
  final String stockName;

  Today01({
    this.stockDiv='',
    this.title='',
    this.stockCode='',
    this.stockName='',
  });

  factory Today01.fromJson(Map<String, dynamic> json) {
    return Today01(
      stockDiv: json['stockDiv'] ?? '',
      title: json['title'] ?? '',
      stockCode: json['stockCode'] ?? '',
      stockName: json['stockName'] ?? '',
    );
  }
}

class Today01Model {
  final String title;
  final List<Today01> listData;
  Today01Model(this.title, this.listData);
}

//화면구성 (새로운 홈_홈 에서 3종목씩 플리킹)
class TileTodayS01 extends StatelessWidget {
  final List<Today01> listItem;
  const TileTodayS01(this.listItem, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        height: 125,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        child: Row(
          children: [
            listItem.isNotEmpty ? _setDataBox(listItem[0], 0) : _setNoDataBox(),
            const SizedBox(
              width: 10,
            ),
            listItem.length > 1 ? _setDataBox(listItem[1], 1) : _setNoDataBox(),
            const SizedBox(
              width: 10,
            ),
            listItem.length > 2 ? _setDataBox(listItem[2], 2) : _setNoDataBox(),
          ],
        ),
      ),
    );
  }

  Widget _setDataBox(Today01 tItem, int itemIndex) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        decoration: UIStyle.boxWithOpacity16(),
        child: InkWell(
          splashColor: Colors.deepPurpleAccent.withAlpha(30),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _setTitleBotton(
                    tItem.stockName[0],
                    RColor.todayTextBack[itemIndex],
                    RColor.todayText[itemIndex]),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  tItem.stockName,
                  style: TStyle.subTitle,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      tItem.title,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xdd555555),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                )
              ],
            ),
          ),
          onTap: () {
            basePageState.goStockHomePage(
              tItem.stockCode,
              tItem.stockName,
              Const.STK_INDEX_SIGNAL,
            );
          },
        ),
      ),
    );
  }

  Widget _setNoDataBox() {
    return Expanded(
      child: Container(
          //decoration: UIStyle.boxRoundLine6(),
          ),
    );
  }

  // 버튼 형태의 타이틀
  Widget _setTitleBotton(String bTitle, Color bColor, Color fColor) {
    return Container(
      width: 30,
      height: 30,
      padding: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: bColor,
        borderRadius: const BorderRadius.all(Radius.circular(7.0)),
      ),
      child: Text(
        bTitle,
        textAlign: TextAlign.center,
        style:
            TextStyle(fontSize: 16, color: fColor, fontWeight: FontWeight.w800),
      ),
    );
  }
}
