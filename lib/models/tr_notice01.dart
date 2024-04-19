import 'package:flutter/material.dart';
import 'package:rassi_assist/common/common_class.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';

import '../common/const.dart';

/// 2020.11.09
/// 공지/알림 목록 조회
class TrNotice01 {
  final String retCode;
  final String retMsg;
  final List<Notice01> listData;

  TrNotice01({this.retCode = '', this.retMsg = '', this.listData = const []});

  factory TrNotice01.fromJson(Map<String, dynamic> json) {
    var jsonList = json['retData'];
    return TrNotice01(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      listData: jsonList == null ? [] : (jsonList as List).map((i) => Notice01.fromJson(i)).toList(),
    );
  }
}

class Notice01 {
  final String noticeSn;
  final String title;
  final String linkType;
  final String linkPage;
  final String regDttm;

  Notice01({
    this.noticeSn = '',
    this.title = '',
    this.linkType = '',
    this.linkPage = '',
    this.regDttm = '',
  });

  factory Notice01.fromJson(Map<String, dynamic> json) {
    return Notice01(
        noticeSn: json['noticeSn'] ?? '',
        title: json['title'] ?? '',
        linkType: json['linkType'] ?? '',
        linkPage: json['linkPage'] ?? '',
        regDttm: json['regDttm'] ?? '');
  }
}

//화면구성 - MY 알고쓰면 유용한 나의 비서
class TileNotice01 extends StatelessWidget {
  final Notice01 item;

  const TileNotice01(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      margin: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 17.0,
      ),
      alignment: Alignment.centerLeft,
      decoration: UIStyle.boxRoundFullColor10c(
        RColor.greyBox_f5f5f5,
      ),
      child: InkWell(
        splashColor: Colors.deepPurpleAccent.withAlpha(30),
        child: Container(
          width: double.infinity,
          height: 53,
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.title,
                    style: TStyle.content16,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              const ImageIcon(
                AssetImage('images/main_my_icon_arrow.png'),
                size: 20,
                // color: Colors.grey,
              ),
            ],
          ),
        ),
        onTap: () {
          if (item.linkType == 'URL') {
            commonLaunchURL(item.linkPage);
          }
        },
      ),
    );
  }
}
