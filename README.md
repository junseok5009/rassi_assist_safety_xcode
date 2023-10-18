# 라씨 매매비서 ios / android



### ===== android build =====
1. 버전코드 변경 (pubspec.yaml, build.gradle, const.dart)
2. 프로젝트 폴더에서 빌드
~~~
$flutter build apk --release --no-sound-null-safety --target-platform=android-arm64
~~~

### 널세이프티 기준 버전
23.09.18 메인_홈 개편된 버전
  
### 22.08.19 기준 버전
Flutter 2.10.4 / Dart 2.16.2 • DevTools 2.9.2

### 예정 업데이트
- 1.0.30 ( 22 / 10 ~  )
  (1) 파이어베이스 ScreenView Event / Class Name 정리 및 추가 업데이트
  (2) GTM 추가 (진행중)
  (3) 버전 업데이트 (예정)
  (2) IOS 상시 수정 업데이트

### 최근 업데이트
- 1.0.29 ( 22 / 08 ~ 09 )
  (1) 마켓뷰 개편
  (2) IOS 상시 수정 업데이트
  (3) 회원가입 웹 joinChannel=SM 추가 ( 핸드폰 번호 없는 간편로그인에만 )
  (4) 배너 수정 작업 ( Ipad 와 같은 디스플레이 큰 화면에서 배너 영역 최적화 )

### 현재 테스트중
- AppDelegate 에서 인앱메시지에 대한 incomingUrl 이 들어올 경우 return false
- 

### TODO List
- 홈_홈 테마 추가 예정
- 검색에서 계속 생성되는 페이지 제한 필요
- 화면 이동에 대한 상태 관리
- 홈탭에 있는 홈_홈, AI매매신호, 종목캐치, 마켓뷰가 열려진 상태에서 랜딩 이동
- pull to refresh
- 마케팅 동의 화면
- 앱 시작시 유저의 상품코드 저장될때 프리미엄 만기 되어 무료일 경우 상품코드 삭제?
- 종목 추가 UI 좀더 자연스럽게 변경 필요
- 날짜 캘린더 호출 팝업 흐름을 자연스럽게 변경 필요
- 홈_홈 - 마케팅동의 팝업

### App 전역데이터
- Provider 를 이용한 공통 데이터 사용예시 : UserCenterPage
- Singleton 패턴을 이용한 공통 데이터 사용예시 : 캐치에서 userId

### 참고사항
- ios 에뮬레이터에서는 notification payload 받지 못함.
- null safety 변환은 DES 라이브러리가 잘 안되서 보류함.
- 매매신호는 매일 5종목을 열람 가능 ()
- ios 결제는 현재 프리미엄 결제만 가능, 3종목 사용되지 않음 (21.09.14)
- InApp01 이 호출되어야 서버 DB에 데이터 생성
- finishTransaction 되지 않으면 2일 후 자동취소

### 회원가입
- 파일 흐름
1. IntroSearchPage (로그인전 검색페이지)
2. LoginDivisionPage (로그인 선택페이지)
3. 전화번호/카카오/네이버/애플/씽크풀
4. JoinRoutePage (처음 가입시 경로입력)

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


