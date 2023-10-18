import 'package:flutter/material.dart';

import '../../../common/const.dart';
import '../../../common/d_log.dart';
import '../../../common/tstyle.dart';
import '../../../common/ui_style.dart';
import '../../../models/pg_data.dart';
import '../../../models/tr_sns03.dart';
import '../../common/common_view.dart';
import '../../main/base_page.dart';
import '../../sub/social_list_page.dart';


/// 커뮤니티 활동 급상승(소셜지수)
class HomeTileSocial extends StatelessWidget {
  final List<Sns03> _socialList;

  const HomeTileSocial(this._socialList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 15),
          color: RColor.new_basic_grey,
          height: 15.0,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            _setSubTitle('커뮤니티 활동 급상승'),
            Container(
              margin: const EdgeInsets.only(right: 20),
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: const Text(
                  '더보기',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff999999),
                  ),
                ),
                onTap: () async {
                  Navigator.pushNamed(
                      context,
                      SocialListPage.routeName,
                      arguments: PgData(pgSn: '')
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10,),

        // 시간 전 슬라이더
        _setTimeAgoSlider(context, _socialList),

        // 종목 리스트
        _socialList.isNotEmpty ? ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.zero,
          itemCount: _socialList.length,
          itemBuilder: (context, index) {
            return TileSns03N(_socialList[index], index);
          },
        ) :
        CommonView.setNoDataTextView(130,
            '현재 커뮤니티 활동이\n평소보다 급상승한 종목이 없습니다.'),
        const SizedBox(height: 20.0,),
      ],
    );
  }

  Widget _setTimeAgoSlider(BuildContext context, List<Sns03> socialList) {
    var counter = 0.0;
    var alignVal = 0.0;
    var isGen = false;
    var agoNum = '';

    if(socialList.isNotEmpty) {
      for(Sns03 item in socialList) {
        if(item.elapsedTmTx == '1') {
          DLog.d('iehgpw@@@', '3333333333');
          agoNum = '1';
          break;
        } else if(item.elapsedTmTx == '2') {
          DLog.d('iehgpw@@@', '4444444444');
          agoNum = '2';
        }
      }
    }
    var agoText = '$agoNum시간전';

    if(agoNum == '2') {
      counter = 1.0;
      alignVal = -0.33;
      isGen = true;
    } else if(agoNum == '1') {
      counter = 2.0;
      alignVal = 0.33;
      isGen = true;
    }

    return Stack(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 9.0,
            activeTrackColor: RColor.yonbora,
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: Colors.transparent,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0.0),
          ),
          child: Slider(
            min: 0.0,
            max: 3.0,
            value: counter,
            // divisions: 10,
            // label: '${counter.round()}',
            onChanged: (double value) {  },
          ),
        ),

        Align(
          alignment: Alignment(alignVal, 0.0),
          child: Visibility(
            visible: isGen,
            child: Container(
              width: 70,
              height: 35,
              margin: const EdgeInsets.only(top: 7),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: UIStyle.boxRoundFullColor16c(
                RColor.mainColor,
              ),
              child: Text(
                agoText,
                style: const TextStyle(
                  // fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }

  //소항목 타이틀
  Widget _setSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Text(
        subTitle,
        style: TStyle.commonTitle,
      ),
    );
  }
}


//화면구성
class TileSns03N extends StatelessWidget {
  final Sns03 item;
  final int index;

  const TileSns03N(this.item, this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // height: 70,
      margin: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 10.0
      ),
      alignment: Alignment.centerLeft,
      child: InkWell(
        child: SizedBox(
          width: double.infinity,
          // height: 70,
          // padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    item.stockName,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    item.stockCode,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xff999999),
                    ),
                  ),
                ],
              ),
              Text(
                TStyle.getPercentString(
                  item.fluctuationRate
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: TStyle.getMinusPlusColor(
                    item.fluctuationRate
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          // 종목홈
          basePageState.goStockHomePage(
            item.stockCode,
            item.stockName,
            Const.STK_INDEX_HOME,
          );
        },
      ),
    );
  }
}