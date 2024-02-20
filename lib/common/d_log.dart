import 'dart:developer' as DevLog;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:rassi_assist/common/const.dart';


class DLog {
  static var logger = Logger();
  static void d(String tag, String message) {
    if(Const.isDebuggable) {
      DateTime now = DateTime.now();
      DevLog.log('${DateFormat('kk:mm:ss.SSS').format(now)} $tag $message');
        }
  }

  static void i(String message) {
    if(Const.isDebuggable) {
      DateTime now = DateTime.now();
      logger.i('${DateFormat('kk:mm:ss.SSS').format(now)}\n$message');
      //DevLog.log('${DateFormat('kk:mm:ss').format(now)} $tag $message');
        }
  }

  static void w(String message) {
    if(Const.isDebuggable) {
      DateTime now = DateTime.now();
      logger.w('${DateFormat('kk:mm:ss.SSS').format(now)}\n$message');
        }
  }

  static void e(String message) {
    if(Const.isDebuggable) {
      DateTime now = DateTime.now();
      logger.e('${DateFormat('kk:mm:ss.SSS').format(now)}\n$message');
        }
  }


}