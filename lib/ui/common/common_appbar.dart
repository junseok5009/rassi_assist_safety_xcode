import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rassi_assist/common/tstyle.dart';

/// Made by HJS 23.08.24
/// 전체 파일에서 써야할 공통 앱바 클래스

class CommonAppbar{
  CommonAppbar.privateConstructor();
  static final CommonAppbar _instance = CommonAppbar.privateConstructor();
  factory CommonAppbar(){
    return _instance;
  }

  /*DEFINE - none
     앱바 없이 scaffold 사용 시에 이것을 사용해주세요.
     기본 컬러는 Colors.white 입니다. */
  static PreferredSizeWidget none(Color color){
    return PreferredSize(
      preferredSize: const Size.fromHeight(0),
      child: AppBar(
        backgroundColor: color,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: color,
          statusBarIconBrightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
          statusBarBrightness: (Platform.isIOS) ? Brightness.light : Brightness.light, //<-- For iOS SEE HERE (dark icons)
        ),
        leading: null,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: false,
      ),
    );
  }




  /*DEFINE - basic
     [ < 버튼 + 타이틀 ] 형태의 앱바 입니다.
     기본 컬러는 Colors.white 입니다. */
  static PreferredSizeWidget basic({
    required BuildContext buildContext, required String title, required double elevation
  }){
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: TStyle.commonTitle,
        ),
        leading: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: (){
            if(buildContext != null && buildContext.mounted){
              Navigator.pop(buildContext);
            }
          },
          child: const Icon(Icons.arrow_back_ios_sharp,),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: elevation,
        centerTitle: false,
        leadingWidth: 40,
        titleSpacing: 5.0,
      ),
    );
  }




  /*DEFINE - basicColor
     [ < 버튼 + 타이틀 ] 형태의 앱바 입니다. 컬러를 변수로 받습니다.
     -title : 메뉴명
     -bgColor : 앱바의 바탕 컬러
     -titleColor : 메뉴명 텍스트 컬러
     -elevation : 앱바와 body 사이의 회색 구분선의 높이 (구분이 필요없다면 0 / 구분이 필요하다면 1)*/
  static PreferredSizeWidget basicColor({
    required BuildContext buildContext, required String title,
    required Color bgColor, required Color titleColor,
    required Color iconColor, required double elevation,
  }){
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        backgroundColor: bgColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: (Platform.isIOS && bgColor != Colors.white) ? Brightness.dark : Brightness.light, //<-- For iOS SEE HERE (dark icons)
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: titleColor,
          ),
        ),
        leading: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: (){
            if(buildContext != null && buildContext.mounted){
              Navigator.pop(buildContext);
            }
          },
          child: const Icon(Icons.arrow_back_ios_sharp,),
        ),
        iconTheme: IconThemeData(color: iconColor,),
        elevation: elevation,
        centerTitle: false,
        leadingWidth: 40,
        titleSpacing: 5.0,
      ),
    );
  }




  /*DEFINE - basicWithAction
     [ < 버튼 + 타이틀 + 오른쪽에 필요 위젯들 ] 형태의 앱바 입니다. 컬러를 변수로 받습니다.
     -title : 메뉴명
     -listActionWidget : 앱바 오른쪽에 들어갈 위젯들 입니다.
                        widget은 InkWell 이나 IconButton으로 감싸서 클릭 했을 때의 처리 부분은 사용할 화면에서 정의하고 넘겨주시면 됩니다.*/
  static PreferredSizeWidget basicWithAction (BuildContext buildContext, String title, List<Widget> listActionWidget,){
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: TStyle.commonTitle,
        ),
        leading: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: (){
            if(buildContext != null && buildContext.mounted){
              Navigator.pop(buildContext);
            }
          },
          child: const Icon(Icons.arrow_back_ios_sharp,),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: listActionWidget,
        elevation: 1,
        centerTitle: false,
        leadingWidth: 40,
        titleSpacing: 5.0,
      ),
    );
  }




  /*DEFINE - basicColorWithAction
     [ < 버튼 + 타이틀 + 오른쪽에 필요 위젯들 ] 형태의 앱바 입니다. 컬러를 변수로 받습니다.
     -title : 메뉴명
     -bgColor : 앱바의 바탕 컬러
     -titleColor : 메뉴명 텍스트 컬러
     -elevation : 앱바와 body 사이의 회색 구분선의 높이 (구분이 필요없다면 0 / 구분이 필요하다면 1)
     -listActionWidget : 앱바 오른쪽에 들어갈 위젯들 입니다.
                        widget은 InkWell 이나 IconButton으로 감싸서 클릭 했을 때의 처리 부분은 사용할 화면에서 정의하고 넘겨주시면 됩니다.*/
  static PreferredSizeWidget basicColorWithAction(
      BuildContext buildContext, String title, Color bgColor, Color titleColor,
      double elevation, List<Widget> listActionWidget,
      ){
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        backgroundColor: bgColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: bgColor,
          statusBarIconBrightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: titleColor,
          ),
        ),
        leading: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: (){
            if(buildContext != null && buildContext.mounted){
              Navigator.pop(buildContext);
            }
          },
          child: const Icon(Icons.arrow_back_ios_sharp,),
        ),
        iconTheme: IconThemeData(color: titleColor,),
        actions: listActionWidget,
        elevation: elevation,
        centerTitle: false,
        leadingWidth: 40,
        titleSpacing: 5.0,
      ),
    );
  }




  /*DEFINE - simple
     [ 타이틀 ] 형태의 앱바 입니다.
     기본 컬러는 Colors.white 입니다.
     */
  static PreferredSizeWidget simple(String title){
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: TStyle.title18T,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: null,
        leadingWidth: 10,
        titleSpacing: 10,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }




  /*DEFINE - simpleWithAction
     [ 타이틀 + 위젯 ] 형태의 앱바 입니다.
     기본 컬러는 Colors.white 입니다.
     -listActionWidget : 앱바 오른쪽에 들어갈 위젯들 입니다.
                        widget은 InkWell 이나 IconButton으로 감싸서 클릭 했을 때의 처리 부분은 사용할 화면에서 정의하고 넘겨주시면 됩니다.*/
  static PreferredSizeWidget simpleWithAction(String title, List<Widget> listActionWidget,){
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: TStyle.title18T,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: null,
        leadingWidth: 10,
        titleSpacing: 10,
        elevation: 1,
        centerTitle: false,
        actions: listActionWidget,
      ),
    );
  }




  /*DEFINE - simpleWithExit
     [ 타이틀 + X버튼 ] 형태의 앱바 입니다.
     -titleColor : 메뉴명 텍스트 컬러
     -bgColor : 앱바의 바탕 컬러
     -iconColor : x버튼의 컬러
     -isCenterTitle : true : 타이틀 센터, false : 타이틀 좌측 정렬
     x 버튼으로 닫는 앱바는 기본적으로 구분선(elevation) 없이 구현합니다.
     */
  static PreferredSizeWidget simpleWithExit(BuildContext buildContext, String title, Color titleColor, Color bgColor, Color iconColor,){
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        backgroundColor: bgColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: bgColor,
          statusBarIconBrightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: titleColor,
          ),
        ),
        leading: null,
        leadingWidth: 10,
        titleSpacing: 10,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            color: iconColor,
            onPressed: (){
              if(buildContext != null && buildContext.mounted){
                Navigator.pop(buildContext);
              }
            },
          ),
        ],
      ),
    );
  }



  /*DEFINE - simpleNoTitleWithExit
     [ 우측 X버튼 ] 형태의 앱바 입니다.
     기본 컬러는 Colors.white 입니다.
     -bgColor : 앱바의 바탕 컬러
     -iconColor : x버튼의 컬러
      x 버튼으로 닫는 앱바는 기본적으로 구분선(elevation) 없이 구현합니다.*/
  static PreferredSizeWidget simpleNoTitleWithExit(BuildContext buildContext, Color bgColor, Color iconColor){
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        backgroundColor: bgColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: bgColor,
          statusBarIconBrightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
        ),
        leading: null,
        leadingWidth: 10,
        titleSpacing: 10,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            color: iconColor,
            onPressed: (){
              if(buildContext != null && buildContext.mounted){
                Navigator.pop(buildContext);
              }
            },
          ),
        ],
      ),
    );
  }

}