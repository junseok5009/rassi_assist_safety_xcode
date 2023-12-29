import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';

class TestImageFitPage extends StatelessWidget {
  //const TestImageFitPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: TestImageFitWidget(),));
  }
}

class TestImageFitWidget extends StatefulWidget {
  //const TestImageFitWidget({Key? key}) : super(key: key);

  @override
  State<TestImageFitWidget> createState() => _TestImageFitWidgetState();
}

class _TestImageFitWidgetState extends State<TestImageFitWidget> {

  String _testUrl1 = 'https://files.thinkpool.com/rassi_signal/test_0914_0143B1.jpg';
  String _testUrl2 = 'http://files.thinkpool.com/rassi_signal/rassibs_cht_img_5.png';
  String _testUrl3 = 'https://webchart.thinkpool.com/2021ReNew/IndexLineStock360/U0001_360.png';
  String _testUrl4 = 'https://i.picsum.photos/id/1028/200/200.jpg?hmac=thf3cKyzvjBi3Rnf8-hvYRl8MmEPFPIq1G8nJVvoT4I';

  BoxFit _boxFit1 = BoxFit.contain;
  int _bgColorInteger1 = 0xffF3F4F8; // bgWeak

  BoxFit _boxFit2 = BoxFit.contain;
  int _bgColorInteger2 = 0xffF3F4F8; // bgWeak

  bool isIpad = AppGlobal().isTablet;

  @override
  Widget build(BuildContext context) {

    if(isIpad){
      _boxFit1 = BoxFit.contain;
      try{
        int _endSubStringInt = _testUrl1.lastIndexOf('.');
        String _linkColorCode = '0xff' + _testUrl1.substring(_endSubStringInt - 6, _endSubStringInt) ;
        _bgColorInteger1 = int.parse(_linkColorCode);
        _boxFit1 = BoxFit.fitHeight;
      } on FormatException {
        _bgColorInteger1 = 0xffF3F4F8;
      }catch(_){
        _bgColorInteger1 = 0xffF3F4F8;
      }
    }else{
      _boxFit1 = BoxFit.fill;
    }

    try {
      int _endSubStringInt = _testUrl2.lastIndexOf('.');
      String _linkColorCode = '0xff' +
          _testUrl2.substring(_endSubStringInt - 6, _endSubStringInt);
      _bgColorInteger2 = int.parse(_linkColorCode);
      _boxFit2 = BoxFit.fitHeight;
    } on FormatException {
      _bgColorInteger2 = 0xffF3F4F8;
      _boxFit2 = BoxFit.contain;
    } catch (_) {
      _bgColorInteger2 = 0xffF3F4F8;
      _boxFit2 = BoxFit.contain;
    }

    return ListView(
      children: [

        _makeDivider('height : na / fit : ${BoxFit.fill}'),
        Container(
            padding: EdgeInsets.all(10),
            color: Colors.green,
            child: Image.network(_testUrl3, fit: BoxFit.fill,)),

        _makeDivider('height : na / fit : ${BoxFit.contain}'),
        Container(
            padding: EdgeInsets.all(10),
            color: Colors.green,
            child: Image.network(_testUrl3, fit: BoxFit.contain,)),

        _makeDivider('height : na / fit : ${BoxFit.none}'),
        Container(
            padding: EdgeInsets.all(10),
            color: Colors.green,
            child: Image.network(_testUrl3, fit: BoxFit.none,)),

        _makeDivider('SizedBox / fit : ${BoxFit.fill}'),
        Container(
          padding: EdgeInsets.all(10),
          color: Colors.green,
          child: SizedBox(
              width: double.infinity,
              child: Image.network(_testUrl3, fit: BoxFit.fill,),),
        ),

        _makeDivider('SizedBox / fit : ${BoxFit.contain}'),
        Container(
          padding: EdgeInsets.all(10),
          color: Colors.green,
          child: SizedBox(
            width: double.infinity,
            child: Image.network(_testUrl3, fit: BoxFit.contain,),),
        ),

        _makeDivider('SizedBox / fit : ${BoxFit.none}'),
        Container(
          padding: EdgeInsets.all(10),
          color: Colors.green,
          child: SizedBox(
            width: double.infinity,
            child: Image.network(_testUrl3, fit: BoxFit.contain, width: 50, height: 240,),),
        ),
        _makeDivider('SizedBox / fit : ${BoxFit.none}'),
        Container(
          padding: EdgeInsets.zero,
          color: Colors.red,
          child: SizedBox(
            width: double.infinity,
            child: Image.network(_testUrl4, fit: BoxFit.contain, height: 260,),),
        ),
      ],
    );
  }

  Widget _makeDivider(String str){
    return Column(
      children: [
        DottedLine(
          dashColor: Colors.red,
        ),
        Text(str, style: TextStyle(color: Colors.red),),
      ],
    );
  }

}

