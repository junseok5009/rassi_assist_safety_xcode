# 라씨 매매비서 ios / android


### ===== android build =====
1. 버전코드 변경 (pubspec.yaml, build.gradle, const.dart)
2. 프로젝트 폴더에서 빌드
~~~
$flutter build apk --release --no-sound-null-safety --target-platform=android-arm64
~~~



#### 라씨 기본 색상 코드 : 6565FF (2024.01.04)

### TODO List
- 앱링크, 딥링크 수정
- 파이어베이스 확인 작업
- 



### AOS 인앱결제
- 1개월정기 -> 6개월정기 로 업그레이드 결제 추가됨
- 기존 프리미엄 유저는 결제창으로 진입을 차단하게 되어 있어서 중복결제를 막는 기능을 했다면
- 이제는 프리미엄 유저가 6개월정기 업그레이드 하는 기능이 추가되어 중복결제의 가능성이 증가
- 현재 ios/aos 결제창이 분리되어 관리되고 있으므로
  ios 유저는 기존대로 최대한 결제창으로의 진입을 차단하는 방법을 유지하고
  android 유저는 결제수단 코드를 활용하여 여러 결제수단에 맞추어 중복결제를 차단할 수 있도록 한다.
- 단건결제 / 무료체험 / 웹결제...의 프리미엄 유저가 결제창으로 진입시 결제수단코드로 구분

### iOS 인앱결제
- ios 에뮬레이터에서는 notification payload 받지 못함.
- 매매신호는 매일 5종목을 열람 가능 ()
- ios 결제는 현재 프리미엄 결제만 가능, 3종목 사용되지 않음 (21.09.14)
- InApp01 이 호출되어야 서버 DB에 데이터 생성
- finishTransaction 되지 않으면 2일 후 자동취소

### 회원가입
- 씽크풀회원가입(씽크풀아이디는 대소문자 구분없음) 
- 푸시토큰이 늦게 들어올 경우가 있음(비동기방식)


|제목|내용|설명|
|---|---|---|
|제목|내용|설명|
|제목|내용|설명|
|제목|내용|설명|
|제목|내용|설명|





### ref
- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


