import 'package:flutter/material.dart';

import '../common/common_popup.dart';

class TestPopupCheckPage extends StatelessWidget {
  //const TestPopupCheckPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: TestPopupCheckWidget());
  }
}

class TestPopupCheckWidget extends StatefulWidget {
  //const TestPopupCheckWidget({Key? key}) : super(key: key);

  @override
  State<TestPopupCheckWidget> createState() => _TestPopupCheckWidgetState();
}

class _TestPopupCheckWidgetState extends State<TestPopupCheckWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                      onTap: (){

                      },
                      child: Container(height: 50, color: Colors.red, child: Center(child: Text('확인', textAlign: TextAlign.center),),)),
                ),
                Expanded(child: InkWell(
                    onTap: (){
                      CommonPopup().showDialogNetErr(context);
                    },
                    child: Container(height: 50, color: Colors.blue, child: Center(child: Text('네트워크\n에러팝업', textAlign: TextAlign.center),),)),),
              ],
            ),


          ],
        ),
      ),
    );
  }



}

