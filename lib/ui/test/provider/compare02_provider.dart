import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Compare02Provider extends ChangeNotifier{
  String _selectDiv = 'SCALE';

  String get getSelectDiv => _selectDiv;

  void selectDiv1(){
    _selectDiv = 'SCALE';
    notifyListeners();
  }

  void selectDiv2(){
    _selectDiv = 'VALUE';
    notifyListeners();
  }

  void selectDiv3(){
    _selectDiv = 'GROWTH';
    notifyListeners();
  }

  void selectDiv4(){
    _selectDiv = 'FLUCT';
    notifyListeners();
  }


}

class PCompare02View1 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Consumer<Compare02Provider>(
        builder: (context, compare02provider, child) =>
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: (){
                      Provider.of<Compare02Provider>(context, listen:false).selectDiv1();
                    },
                    child: Container(
                      color: Provider.of<Compare02Provider>(context).getSelectDiv == 'SCALE' ? Colors.redAccent : Colors.white54,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      child: Text('SCALE'),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () => Provider.of<Compare02Provider>(context, listen: false).selectDiv2(),
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      color: Provider.of<Compare02Provider>(context).getSelectDiv == 'VALUE' ? Colors.redAccent : Colors.white54,
                      child: Text('VALUE'),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    // Provider 의 위젯 트리 외부에서 Listen을 전달할 수 없기 때문 입니다
                    onTap: () => Provider.of<Compare02Provider>(context, listen: false).selectDiv3(),
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      color: Provider.of<Compare02Provider>(context).getSelectDiv == 'GROWTH' ? Colors.redAccent : Colors.white54,
                      child: Text('GROWTH'),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    // Provider 의 위젯 트리 외부에서 Listen을 전달할 수 없기 때문 입니다
                    onTap: () => Provider.of<Compare02Provider>(context, listen: false).selectDiv4(),
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      color: Provider.of<Compare02Provider>(context).getSelectDiv == 'FLUCT' ? Colors.redAccent : Colors.white54,
                      child: Text('FLUCT'),
                    ),
                  ),
                ),
              ],
            )
      ),
    );
  }

}
