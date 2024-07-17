import 'package:rassi_assist/common/strings.dart';

enum PocketApiCode {
  successWithData,        // 성공 + 결과값 리턴 코드
  showPopup,              // data는 Map 형식
  unknownFailure,         // 서버 요청, 서버 결과값 받기 등의 이유로 실패, 이유는 알 수 없음
  userCancelled           // 사용자 요청 취소 코드
}

enum PocketApiPopupType {
  premium,      // 무료 사용자에게 유료 사용 권유 팝업 띄워야 하는 코드
  failMsg       // 실패 + 실패 이유를 서버/앱에서 받아옴. 이 이유를 팝업으로 사용자에게 보여줘야 하는 코드
}

class PocketApiResult {
  final PocketApiCode code;
  final dynamic data;
  PocketApiResult({required this.code, this.data});
  PocketApiResult.successWithData({required this.data})
      : code = PocketApiCode.successWithData;
  PocketApiResult.unknownFailure()
      : code = PocketApiCode.unknownFailure,
        data = null;
  PocketApiResult.showPopupPremium()
      : code = PocketApiCode.showPopup,
        data = {'type': PocketApiPopupType.premium,};
  PocketApiResult.showPopupUserCenter()
      : code = PocketApiCode.showPopup,
        data = {'type': PocketApiPopupType.failMsg, 'message': RString.dbEtcErroruserCenterMsg};
  PocketApiResult.showPopupDbMsg({required String message})
      : code = PocketApiCode.showPopup,
        data = {'type': PocketApiPopupType.failMsg, 'message': message};
  PocketApiResult.userCancelled()
      : code = PocketApiCode.userCancelled,
        data = null;
}