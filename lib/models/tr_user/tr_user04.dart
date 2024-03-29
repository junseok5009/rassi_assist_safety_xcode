import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 회원의 상품정보 조회
class TrUser04 {
  final String retCode;
  final String retMsg;
  final User04 retData;

  TrUser04({
    this.retCode = '',
    this.retMsg = '',
    this.retData = const User04(),
  });

  factory TrUser04.fromJson(Map<String, dynamic> json) {
    return TrUser04(
      retCode: json['retCode'],
      retMsg: json['retMsg'],
      retData: json['retData'] == null ? const User04() : User04.fromJson(json['retData']),
    );
  }
}

class User04 {
  final String cashRemain;
  final String prodCateg;
  final AccountData accountData;
  final CashData? cashData;

  const User04({
    this.cashRemain = '',
    this.prodCateg = '',
    this.accountData = const AccountData(),
    this.cashData,
  });

  factory User04.fromJson(Map<String, dynamic> json) {
    AccountData acntData = AccountData.fromJson(json['struct_Account']);
    CashData? cItem;
    json['struct_Cash'] == null ? cItem = null : cItem = CashData.fromJson(json['struct_Cash']);
    return User04(
      cashRemain: '',
      prodCateg: '',
      accountData: acntData,
      cashData: cItem,
    );
  }
}

class AccountData {
  final String userId;
  final String userStatus;
  final String payErrStatus;
  final String joinRoute;
  final String prodCateg;
  final String prodCode;
  final String prodName;
  final String payMethod;
  final String productId;
  final String isFreeUser;
  final String subsStatus;
  // test agent 추가
  final String joinLink1;
  final String joinLink2;
  final String isAgent;
  final String isWelcomeCheck;

  const AccountData({
    this.userId = '',
    this.userStatus = '',
    this.payErrStatus = '',
    this.joinRoute = '',
    this.prodCateg = '',
    this.prodCode = '',
    this.prodName = '',
    this.payMethod = '',
    this.productId = '',
    this.isFreeUser = '',
    this.subsStatus = '',
    this.joinLink1 = '',
    this.joinLink2 = '',
    this.isAgent = 'Y',
    this.isWelcomeCheck = 'N',
  });

  factory AccountData.fromJson(Map<String, dynamic> json) {
    return AccountData(
      userId: json['userId'] ?? '',
      userStatus: json['userStatus'] ?? '',
      payErrStatus: json['payErrStatus'] ?? '',
      joinRoute: json['joinRoute'] ?? '',
      prodCateg: json['prodCateg'] ?? '',
      prodCode: json['prodCode'] ?? '',
      prodName: json['prodName'] ?? '',
      payMethod: json['payMethod'] ?? '',
      productId: json['productId'] ?? '',
      isFreeUser: json['isFreeUser'] ?? '',
      subsStatus: json['subsStatus'] ?? '',
      joinLink1: json['joinLink1'] ?? '',
      joinLink2: json['joinLink2'] ?? '',
      isAgent: json['isAgent'] ?? 'Y',
      isWelcomeCheck: json['isWelcomeCheck'] ?? 'N',
    );
  }

  Future<bool> initUserStatus() async {
    final AppGlobal appGlobal = AppGlobal();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(Const.PREFS_USER_ID, userId);
    AppGlobal().userId = userId;
    if (userId.isEmpty) {
      return false;
    }
    await prefs.setString(Const.PREFS_CUR_PROD, productId);
    if (prodCode == 'AC_PR') {
      //프리미엄 사용자
      appGlobal.isFreeUser = false;
      appGlobal.isPremium = true;
    } else if (prodCode == 'AC_S3') {
      //3종목 알림 사용자
      appGlobal.isFreeUser = false;
      appGlobal.isPremium = false;
    } else {
      //무료 사용자
      appGlobal.isFreeUser = true;
      appGlobal.isPremium = false;
    }
    return true;
  }

  Future<bool> initUserStatusAfterPayment() async {
    DLog.d('TR_USER04 AccountData initUserStatusAfterPayment()', 'AccountData toString() : ${toString()}');

    final AppGlobal appGlobal = AppGlobal();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Const.PREFS_CUR_PROD, productId);

    if (prodCode == 'AC_PR') {
      //프리미엄 사용자
      appGlobal.isFreeUser = false;
      appGlobal.isPremium = true;
    } else if (prodCode == 'AC_S3') {
      //3종목 알림 사용자
      appGlobal.isFreeUser = false;
      appGlobal.isPremium = false;
    } else {
      //무료 사용자
      appGlobal.isFreeUser = true;
      appGlobal.isPremium = false;
    }

    if (subsStatus == 'S') {
      CustomFirebaseClass.setUserProperty(CustomFirebaseProperty.SUBS_STATUS, 'subs_on');
    } else if (subsStatus == 'C') {
      CustomFirebaseClass.setUserProperty(CustomFirebaseProperty.SUBS_STATUS, 'cancel_on');
    } else if (subsStatus == 'E') {
      CustomFirebaseClass.setUserProperty(CustomFirebaseProperty.SUBS_STATUS, 'cancel_off');
    } else if (subsStatus == 'P') {
      CustomFirebaseClass.setUserProperty(CustomFirebaseProperty.SUBS_STATUS, 'product');
    } else if (subsStatus == 'N') {
      CustomFirebaseClass.setUserProperty(CustomFirebaseProperty.SUBS_STATUS, 'none');
    }
    await prefs.setString(Const.PREFS_CUR_PROD, productId); //사용중 상품코드 등록

    if (productId.isNotEmpty) {
      CustomFirebaseClass.setUserProperty(CustomFirebaseProperty.PAYING_PD, productId);
    }

    return true;
  }

  void setFreeUserStatus() async {
    final AppGlobal appGlobal = AppGlobal();
    //final SharedPreferences prefs = await SharedPreferences.getInstance();
    appGlobal.isFreeUser = true;
    appGlobal.isPremium = false;
    //await prefs.setString(Const.PREFS_CUR_PROD, '');
    CustomFirebaseClass.setUserProperty(CustomFirebaseProperty.PAYING_PD, 'none');
  }

  @override
  String toString() {
    return 'prodCode:$prodCode/prodName:$prodName/subsStatus:$subsStatus'
        '/productId:$productId/payMethod:$payMethod/isFreeUser:$isFreeUser'
        '/joinRoute:$joinRoute/prodCateg:$prodCateg';
  }
}

class CashData {
  final String cashRemain;
  final String prodCateg;

  CashData({
    this.cashRemain = '',
    this.prodCateg = '',
  });

  factory CashData.fromJson(Map<String, dynamic> json) {
    return CashData(
      cashRemain: json['cashRemain'],
      prodCateg: json['prodCateg'],
    );
  }

  @override
  String toString() {
    return '$cashRemain|$prodCateg';
  }
}
