
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';

class CommonSwiperPagenation {

  static SwiperPagination getPromBannerSP() {
    return const SwiperPagination(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(top: 94),
      builder: DotSwiperPaginationBuilder(
        size: 7,
        activeSize: 7,
        space: 3,
        color: RColor.bgGrey,
        activeColor: Colors.deepPurpleAccent,
      ),
    );
  }

  static SwiperPagination getNormalSP(double size) {
    return SwiperPagination(
      alignment: Alignment.bottomCenter,
      builder: DotSwiperPaginationBuilder(
        size: size,
        activeSize: size,
        space: 4,
        color: RColor.bgGrey,
        activeColor: Colors.deepPurpleAccent,
      ),
    );
  }

  static SwiperPagination getNormalSpWithMargin(double size, double margin, Color activeColor) {
    return SwiperPagination(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(top: margin),
      builder: DotSwiperPaginationBuilder(
        size: size,
        activeSize: size,
        space: 4,
        color: RColor.bgGrey,
        activeColor: activeColor,
      ),
    );
  }

}