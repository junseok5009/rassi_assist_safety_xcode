import 'dart:developer' as DLog;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:rassi_assist/models/none_tr/stock/stock_tab_data.dart';
import 'package:rassi_assist/models/pg_notifier.dart';
import 'package:rassi_assist/provider/login_rassi_provider.dart';
import 'package:rassi_assist/provider/pocket_provider.dart';
import 'package:rassi_assist/provider/signal_provider.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_stock_info_provider.dart';
import 'package:rassi_assist/provider/stock_home/stock_home_tab_name_provider.dart';
import 'package:rassi_assist/provider/user_info_provider.dart';
import 'package:rassi_assist/ui/login/intro_page.dart';

void main() async {
  //flutter 엔진과 widget 바인딩 미리 완료(비동기 데이터 다룰 경우)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //initFirebaseDynamicLinks();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  KakaoSdk.init(nativeAppKey: "9581feb9ceb27a4206e30b1d02ed446f");

  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // await FirebaseMessaging.instance.setAutoInitEnabled(true);
  } catch (_) {
    DLog.log('>>>>>>> Pre Run Exception >>>>>>>');
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => UserInfoProvider()),
      ChangeNotifierProvider(create: (context) => StockTabData()),
      ChangeNotifierProvider(create: (context) => PageNotifier()),
      ChangeNotifierProvider(create: (context) => PocketProvider()),
      ChangeNotifierProvider(create: (context) => SignalProvider()),
      ChangeNotifierProvider(create: (context) => StockInfoProvider()),
      ChangeNotifierProvider(create: (context) => StockTabNameProvider()),
      ChangeNotifierProvider(create: (context) => LoginRassiProvider()),
    ],
    child: const IntroPage(),
  ));
  DLog.log('>>>>>>> Run App >>>>>>>');
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firestore와 같은 백그라운드에서 다른 Firebase 서비스를 사용하려는 경우
  // 다른 Firebase 서비스를 사용하기 전에`initializeApp`을 호출해야합니다.
/*  if (Platform.isAndroid) {
    Firebase.initializeApp();

    //TODO 로그인 여부 추가

    AndroidNotification android = message.notification?.android;
    Map<String, dynamic> msgData = message.data;

    if(msgData != null) {
      debugPrint("Handling a background message: ${msgData.toString()}");

      flutterLocalNotificationsPlugin.show(
        // notification.hashCode,
        msgData['pushSn'] == null ? 0 : int.parse(msgData['pushSn']),
        msgData['pushTitle'],
        msgData['pushContent'],
        NotificationDetails(
          android: AndroidNotificationDetails(
            BasePageState.channel.id,
            BasePageState.channel.name,
            channelDescription: BasePageState.channel.description,
            icon: android?.smallIcon,
            // other properties...
          ),
        ),
        payload: jsonEncode(msgData),
      );
    }
  }*/

  // debugPrint("Handling a background message: ${message.messageId}");
  // DLog.log('Message : ${message.notification.title}');
  // DLog.log('Message : ${message.notification.body}');
  // DLog.log('Message : ${message.data.toString()}');
}
