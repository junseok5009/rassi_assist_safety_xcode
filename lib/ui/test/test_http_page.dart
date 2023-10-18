import 'package:flutter/material.dart';

class TestHttpPage extends StatelessWidget {
  //const TestHttpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: TestHttpWidget(),));
  }
}

class TestHttpWidget extends StatefulWidget {
  //const TestHttpWidget({Key? key}) : super(key: key);

  @override
  State<TestHttpWidget> createState() => _TestHttpWidgetState();
}

class _TestHttpWidgetState extends State<TestHttpWidget> {

  String TAG = 'TestHttpPage';

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [

        Row(
          children: [
            Expanded(
              child: InkWell(
                  onTap: () {
                    f3();
                  },
                  child: Container(height: 50,
                    color: Colors.red,
                    child: Center(
                      child: Text('시작', textAlign: TextAlign.center),),)),
            ),
            Expanded(child: Container(height: 50,
              color: Colors.blue,
              child: Center(
                child: Text('버튼', textAlign: TextAlign.center),),),),
          ],
        ),


      ],
    );
  }

  Future<void> apiFetch() async {
    var status = true;

    await Future.wait([f1(), f2()]).then((v) {
      for (var item in v) {
        print('$item \n');
      }
    }).whenComplete(() {
      status = false;
    });

    print(status == true ? 'Loading' : 'FINISHED');
  }

  Future f1() async {
    print("f1 function is runnion now");
    Future.delayed(Duration(seconds: 8));
    print("f1 function finished processing");
    return 1;
  }

  Future f2() async {
    print("f2 function is runnion now");
    Future.delayed(Duration(seconds: 3));

    print("f2 function finished processing");
    return 2;
  }

  Future<void> f3() async {
    print('Let\'s point to work.');

    await Future.wait([
      makeWorking('Mr.A', 2),
      makeWorking('Mr.B', 4),
      makeWorking('Mr.C', 3),
      makeWorking('Mr.D', 1)
    ]);


  }

  Future<String> makeWorking(String whom, int potential) async {
     return Future.delayed(
      Duration(seconds: potential),
          () {
        String result = '$whom said he was done.';
        print('Future.delayed potential : $potential / '+result);
        return result;
      },
    );
  }

}

