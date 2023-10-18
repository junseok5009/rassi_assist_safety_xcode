import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/ui/main_state.dart';


/// Default Page
// 파일 생성시 페이지 기본형
class DefaultPage extends StatelessWidget {
  static const routeName = '/page_';
  static const String TAG = "[DefaultPage] ";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Default',
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      debugShowCheckedModeBanner: false,
      home: DefaultWidget(),
    );
  }
}

class DefaultWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _DefaultState();
}

class _DefaultState extends MainState<DefaultWidget>{

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: Const.TEXT_SCALE_FACTOR),
      child: _setLayout(),);
  }

  Widget _setLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Default page"),
      ),
      body: LayoutBuilder(builder: (context, constraint) {
        final _maxHeight = constraint.biggest.height / 3;
        final _biggerFont = TextStyle(fontSize: _maxHeight / 6);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nome',
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Data de nascimento',
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
              ),


            ],
          ),
        );
      },
      ),
    );
  }

}