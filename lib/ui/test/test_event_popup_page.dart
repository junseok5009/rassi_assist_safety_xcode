import 'package:flutter/material.dart';
import 'package:rassi_assist/models/none_tr/stock/stock.dart';
import 'package:rassi_assist/ui/layer/add_stock_layer.dart';

class TestEventPopupPage extends StatefulWidget {
  //const TestEventPopupPage({super.key});

  @override
  State<TestEventPopupPage> createState() => _TestEventPopupPageState();
}

class _TestEventPopupPageState extends State<TestEventPopupPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            InkWell(
              child: Container(
                child: const Text('팝업 생성!'),
              ),
              onTap: () {
                showLayer();
              },
            )
          ],
        ),
      ),
    );
  }

  showLayer() {
    // auto height 레이어
    showModalBottomSheet<dynamic>(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Wrap(
              children: <Widget>[
                AddStockLayer(
                  Stock(stockName: '삼성전자', stockCode: '005930'),
                ),
              ],
            ),
          );
        });
  }
}
