import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:rassi_assist/common/const.dart';

/* DEFINE
      플루터에서 사용하는 날짜 선택 하는 클래스 입니다.
   */
class CommonDatePicker {
  // 연도는 현재 연도 디폴트, 월만 선택, 사용자는 년도 선택가능 >> 즉, 년/월만 선택하기
  static Future<DateTime?> showYearMonthPicker(BuildContext context, DateTime initDateTime) async {
    return await showMonthPicker(
      context: context,
      initialDate: initDateTime,
      roundedCornersRadius: 10,
      headerColor: Colors.white,
      headerTextColor: Colors.black,
      selectedMonthTextColor: Colors.white,
      unselectedMonthTextColor: Colors.black,
      selectedMonthBackgroundColor: Colors.black,
      locale: const Locale('ko', 'KR'),
      cancelWidget: const Text(
        '취소',
        style: TextStyle(
          fontSize: 15,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      confirmWidget: const Text(
        '확인',
        style: TextStyle(
          fontSize: 15,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    ).then((date) {
      if (date != null) {
        return date;
      } else {
        return null;
      }
    });
  }

  // 년도만 선택가능함
  static Future<DateTime> showYearPicker(BuildContext context, DateTime initDateTime) async {
    final dateFormat = DateFormat('yyyy');
    late DateTime returnDateTime;

    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${dateFormat.format(initDateTime)}년'),
          content: SizedBox(
            // Need to use container to add size constraint.
            width: MediaQuery.of(context).size.width * 3 / 4,
            height: MediaQuery.of(context).size.height * 2 / 5,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: RColor.mainColor, // header background color
                  onPrimary: Colors.white, // header text color
                  onSurface: Colors.black, // body text color
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red, // button text color
                  ),
                ),
              ),
              child: YearPicker(
                firstDate: DateTime(DateTime.now().year - 10, 1),
                lastDate: DateTime(DateTime.now().year + 2, 1),
                //initialDate: initDateTime,
                selectedDate: initDateTime,
                currentDate: initDateTime,
                onChanged: (DateTime dateTime) {
                  // close the dialog when year is selected.
                  Navigator.pop(context);
                  returnDateTime = dateTime;
                },
              ),
            ),
          ),
        );
      },
    ).then((value) => returnDateTime);
  }
}
