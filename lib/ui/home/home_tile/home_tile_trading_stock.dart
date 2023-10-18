import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/tstyle.dart';

import '../../../common/const.dart';
import '../../../models/tr_today/tr_today01.dart';
import '../../common/common_swiper_pagination.dart';

/// [홈_홈 라씨매매비서의 매매종목은?] - 2023.09.07 HJS
class HomeTileTradingStock extends StatefulWidget {
  final List<Today01Model> listToday01Model;
  const HomeTileTradingStock({Key? key, this.listToday01Model = const []})
      : super(key: key);
  @override
  State<HomeTileTradingStock> createState() => _HomeTileTradingStockState();
}

class _HomeTileTradingStockState extends State<HomeTileTradingStock> {
  int _today01Index = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '라씨 매매비서의 매매종목은?',
                style: TStyle.commonTitle,
              ),
              widget.listToday01Model.isEmpty
                  ? const SizedBox()
                  : Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Text(
                          widget.listToday01Model[_today01Index].title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: RColor.mainColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
            ],
          ),
          const SizedBox(
            height: 15.0,
          ),
          widget.listToday01Model.isEmpty
              ? const SizedBox(height: 148,)
              : SizedBox(
                  width: double.infinity,
                  height: widget.listToday01Model.length < 2 ? 138 : 148,
                  child: Swiper(
                    controller: SwiperController(),
                    pagination: widget.listToday01Model.length < 2
                        ? null
                        : CommonSwiperPagenation.getNormalSpWithMargin(8.0, 132, Colors.black,),
                    loop: false,
                    autoplay: false,
                    onIndexChanged: (int index) {
                      setState(() {
                        _today01Index = index;
                      });
                    },
                    itemCount: widget.listToday01Model.length,
                    itemBuilder: (BuildContext context, int index) {
                      return TileTodayS01(
                        widget.listToday01Model[index].listData,
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
