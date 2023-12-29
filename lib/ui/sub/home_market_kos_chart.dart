import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/net.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/tr_index01.dart';

class HomeMarketKosChartPage extends StatelessWidget {
  //const HomeMarketKosChartWidget({Key? key}) : super(key: key);
  static const String TAG_NAME = '코스피_코스닥_차트';

  @override
  Widget build(BuildContext context) {
    DLog.w('HomeMarketKosChartPage $TAG_NAME');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KospiProvider()),
        ChangeNotifierProvider(create: (_) => KosdaqProvider()),
        ChangeNotifierProvider(create: (_) => Counts()),
      ],
      child: SafeArea(
        child: Scaffold(
          body: HomeMarketKosChartWidget(),
        ),
      ),
    );
  }
}

class HomeMarketKosChartWidget extends StatefulWidget {
  //const HomeMarketKosChartWidget({Key? key}) : super(key: key);
  @override
  State<HomeMarketKosChartWidget> createState() =>
      _HomeMarketKosChartWidgetState();
}

class _HomeMarketKosChartWidgetState extends State<HomeMarketKosChartWidget> {
  final int _kospiKey = 8;
  final int _kosdaqKey = 9;

  String _kospi = '';
  String _kospiSub = '';
  Color _kospiColor = Colors.grey;
  final List _kospiChartUrlList = [
    'https://webchart.thinkpool.com/2022Mobile/IndexDay/U1001.png',
    'https://webchart.thinkpool.com/2022Mobile/IndexLineStock92/U1001_92.png',
    'https://webchart.thinkpool.com/2022Mobile/IndexLineStock360/U1001_360.png'
  ];

  String _kosdaq = '';
  String _kosdaqSub = '';
  Color _kosdaqColor = Colors.grey;
  final List _kosdaqChartUrlList = [
    'https://webchart.thinkpool.com/2022Mobile/IndexDay/U2001.png',
    'https://webchart.thinkpool.com/2022Mobile/IndexLineStock92/U2001_92.png',
    'https://webchart.thinkpool.com/2022Mobile/IndexLineStock360/U2001_360.png'
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) {
        KospiProvider();
        KosdaqProvider();
        Counts();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),

            Container(
              width: double.infinity,
              alignment: Alignment.centerRight,
              child: InkWell(
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              '차트보기',
              style: TStyle.title18T,
            ),
            const SizedBox(
              height: 20,
            ),

            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // 코스피
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Center(
                        child: Text(
                          '코스피',
                          style: TStyle.commonTitle,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _kospi,
                            style: TStyle.title20,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            '$_kospiSub',
                            style: TextStyle(
                              color: _kospiColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Expanded(
                    child: Consumer<KospiProvider>(
                      builder: (_, value, __) {
                        return Column(
                          children: [
                            Wrap(
                              spacing: 10,
                              alignment: WrapAlignment.center,
                              children: List.generate(
                                3,
                                (index) => _makeKosBtnViews(index, _kospiKey),
                              ),
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            Expanded(
                              child: Image.network(
                                _kospiChartUrlList[value.getIndex],
                                fit: BoxFit.fill,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            //코스닥
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Center(
                          child: Text(
                        '코스닥',
                        style: TStyle.commonTitle,
                      )),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _kosdaq,
                            style: TStyle.title20,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            '$_kosdaqSub',
                            style: TextStyle(
                              color: _kosdaqColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Expanded(
                    child: Consumer<KosdaqProvider>(
                      builder: (_, value, __) {
                        return Column(
                          children: [
                            Wrap(
                              spacing: 10,
                              alignment: WrapAlignment.center,
                              children: List.generate(
                                3,
                                (index) =>
                                    _makeKosBtnViews(index, _kosdaqKey),
                              ),
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            Expanded(child: Image.network(_kosdaqChartUrlList[value.getIndex], fit: BoxFit.fill, ),),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 10,
            ),

          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(HomeMarketKosChartPage.TAG_NAME);
    _fetchPosts();
  }

  void _fetchPosts() async {
    var url = Uri.parse(Net.TR_BASE + TR.INDEX01);
    try {
      final http.Response response = await http.post(
            url,
            body: jsonEncode(<String, String>{
              'userId': AppGlobal().userId,
            }),
            headers: Net.headers,
          ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      final TrIndex01 resData = TrIndex01.fromJson(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Kospi kospi = resData.retData.kospi;
        Kosdaq kosdaq = resData.retData.kosdaq;

        _kospi = kospi.priceIndex;
        if (kospi.fluctuationRate.contains('-')) {
          _kospiSub = '▼${kospi.indexFluctuation.replaceAll('-', '')}  ${kospi.fluctuationRate}%';
          _kospiColor = RColor.sigSell;
        } else if (kospi.fluctuationRate == '0.00') {
          _kospiSub =
              '${kospi.indexFluctuation}  ${kospi.fluctuationRate}%';
        } else {
          _kospiSub = '▲${kospi.indexFluctuation}  +${kospi.fluctuationRate}%';
          _kospiColor = RColor.sigBuy;
        }

        _kosdaq = kosdaq.priceIndex;
        if (kosdaq.fluctuationRate.contains('-')) {
          _kosdaqSub = '▼${kosdaq.indexFluctuation.replaceAll('-', '')}   ${kosdaq.fluctuationRate}%';
          _kosdaqColor = RColor.sigSell;
        } else if (kosdaq.fluctuationRate == '0.00') {
          _kosdaqSub =
              '${kosdaq.indexFluctuation}  ${kosdaq.fluctuationRate}%';
        } else {
          _kosdaqSub = '▲${kosdaq.indexFluctuation}   +${kosdaq.fluctuationRate}%';
          _kosdaqColor = RColor.sigBuy;
        }

        setState(() {});
      } else {
        Navigator.pop(context);
      }
    } catch (error) {}
  }

  Widget _makeKosBtnViews(int index, int key) {
    String btnTitle = '';
    Decoration btnDecoration = UIStyle.boxRoundLine6();
    Color btnFontColor = Colors.black;

    if (index == 0) {
      btnTitle = '1일';
    } else if (index == 1) {
      btnTitle = '3개월';
    } else if (index == 2) {
      btnTitle = '1년';
    }

    if ((key == _kospiKey &&
            Provider.of<KospiProvider>(context, listen: false)._index ==
                index) ||
        (key == _kosdaqKey &&
            Provider.of<KosdaqProvider>(context, listen: false)._index ==
                index)) {
      btnDecoration = UIStyle.boxBtnSelectedMainColor6Cir();
      btnFontColor = Colors.white;
    }

    return InkWell(
      onTap: () {
        if (key == _kospiKey && _kospiKey != index) {
          Provider.of<KospiProvider>(context, listen: false).modify(index);
        } else if (key == _kosdaqKey && _kosdaqKey != index) {
          Provider.of<KosdaqProvider>(context, listen: false).modify(index);
        }
      },
      child: Container(
        width: 60,
        decoration: btnDecoration,
        padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
        alignment: Alignment.center,
        child: Text(
          btnTitle,
          style: TextStyle(
            color: btnFontColor,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class KospiProvider with ChangeNotifier {
  int _index = 0;

  int get getIndex => _index;

  void modify(int value) {
    _index = value;
    notifyListeners();
  }
}

class KosdaqProvider with ChangeNotifier {
  int _index = 0;

  int get getIndex => _index;

  void modify(int value) {
    _index = value;
    notifyListeners();
  }
}

class Counts with ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void add() {
    _count++;
    notifyListeners();
  }

  void remove() {
    _count--;
    notifyListeners();
  }
}
