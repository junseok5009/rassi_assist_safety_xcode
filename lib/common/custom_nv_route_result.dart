// 라우트 result model class
class CustomNvRouteResult{
  static String fail = 'fail';        // 네트워크 실패, 팝업 띄우기 실패 등의 경우
  static String cancel = 'cancel';    // 주로 사용자에 의한 취소, 닫기 등의 경우
  static String out = 'out';          // 콜백 받고 페이지 나가야 하는 경우
  static String refresh = 'refresh';  // 돌아온 화면에서 갱신이 필요한 경우
  static String landing = 'landing';  // 특정 한 곳으로만 랜딩 시켜줄 경우
  static String landPremiumPopup = 'landPremiumPopup';  // 돌아온 화면에서 프리미엄 팝업을 띄워야 하는 경우 >> success true
  static String landPremiumPage = 'landPremiumPage';  // 돌아온 화면에서 프리미엄 결제 페이지로 넘어가야 하는 경우 >> success true
}