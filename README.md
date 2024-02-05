# 라씨 매매비서 ios / android


### ===== android build =====
1. 버전코드 변경 (pubspec.yaml, build.gradle, const.dart)
2. 프로젝트 폴더에서 빌드
~~~
$flutter build apk --release --no-sound-null-safety --target-platform=android-arm64
~~~



#### 라씨 기본 색상 코드 : 6565FF (2024.01.04)

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


