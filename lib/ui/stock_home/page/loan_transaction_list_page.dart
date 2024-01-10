import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/d_log.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/const.dart';
import '../../../common/net.dart';
import '../../common/common_popup.dart';
import '../../../custom_lib/sticky_header/custom_table_sticky_header_basic/custom_table_sticky_header_basic.dart';
import '../../../custom_lib/sticky_header/custom_table_sticky_header_basic/custom_table_sticky_header_basic.dart'
as custom_class_scroller;
import '../../../models/tr_invest/tr_invest21.dart';
import '../../../models/tr_invest/tr_invest22.dart';
import '../../../models/tr_invest/tr_invest23.dart';

/// 23.03.20 HJS
/// 종목홈_대차거래/공매_일자별 현황_리스트 화면
/// /// 23.07.11 HJS
// /// 신용융자 추가
class LoanTransactionListPage extends StatefulWidget {
  static const String TAG_NAME = '일자별_현황';
  const LoanTransactionListPage({Key? key}) : super(key: key);
  @override
  State<LoanTransactionListPage> createState() =>
      _LoanTransactionListPageState();
}

class _LoanTransactionListPageState
    extends State<LoanTransactionListPage> {
  late SharedPreferences _prefs;
  String _userId = "";
  String _stockCode = '';
  final _controller = ScrollController();

  int _selectDiv = 0; // 0 : 대차거래 / 1 : 공매 // 2 : 신용융자

  // 대차거래
  final List<Invest21ChartData> _lendingListData = [];
  int _lendingPageNo = 0;
  int _lendingTotalPageSize = 0;
  final List<String> _lendingListTitle = ['일자', '체결', '상환', '잔고', '잔고금'];

  // 공매
  final List<Invest22ChartData> _sellingListData = [];
  int _sellingPageNo = 0;
  int _sellingTotalPageSize = 0;
  final List<String> _sellingListTitle = ['일자', '거래량', '공매도량', '매매비중', '금액'];

  // 공매
  final List<Invest23ChartData> _loanListData = [];
  int _loanPageNo = 0;
  int _loanTotalPageSize = 0;
  final List<String> _loanListTitle = ['신규주수', '상환주수', '잔고주수', '공여율', '잔고율'];

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(
      LoanTransactionListPage.TAG_NAME,
    );
    _stockCode = AppGlobal().stkCode;
    _loadPrefData().then(
          (_) => {
        _requestTrInvest21(),
      },
    );
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (!isTop) {
          if (_selectDiv == 0 &&
              _lendingPageNo < _lendingTotalPageSize) {
            _lendingPageNo++;
            _requestTrInvest21();
          } else if (_selectDiv == 1 &&
              _sellingPageNo < _sellingTotalPageSize) {
            _sellingPageNo++;
            _requestTrInvest22();
          } else if (_selectDiv == 2 &&
              _loanPageNo < _loanTotalPageSize) {
            _loanPageNo++;
            _requestTrInvest23();
          }
        }
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  Future<void> _loadPrefData() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString(Const.PREFS_USER_ID) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '일자별 현황',
              style: TStyle.title18T,
            ),
            IconButton(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                //horizontal: 10,
              ), // 패딩 설정
              constraints: const BoxConstraints(), // constraints
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              icon: const Icon(
                Icons.close,
                color: Colors.black,
                size: 26,
              ),
            ),
          ],
        ),
        //iconTheme: IconThemeData(color: Colors.black),
        centerTitle: false,
        leadingWidth: 0,
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              _setDivButtons(),
              (_selectDiv == 0 && _lendingListData.isNotEmpty) ||
                  (_selectDiv == 1 && _sellingListData.isNotEmpty) ||
                  (_selectDiv == 2 && _loanListData.isNotEmpty)
                  ? _setDataView()
                  : _setNoDataView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _setNoDataView() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(
        top: 20,
      ),
      decoration: UIStyle.boxRoundLine6(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 1,
                color: RColor.new_basic_text_color_grey,
              ),
              color: Colors.transparent,
            ),
            child: const Center(
              child: Text(
                '!',
                style: TextStyle(
                  fontSize: 18,
                  color: RColor.new_basic_text_color_grey,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            _selectDiv == 0
                ? '대차거래 내역이 없습니다.'
                : _selectDiv == 1
                ? '공매도 내역이 없습니다.'
                : '신용융자 내역이 없습니다.',
            style: const TextStyle(
              fontSize: 14,
              color: RColor.new_basic_text_color_grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _setDataView() {
    return _selectDiv == 0 || _selectDiv == 1
        ? Expanded(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.centerRight,
            child: const Text(
              '잔고금 : 백만',
              style: TextStyle(
                color: RColor.bgTableTextGrey,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Expanded(
            child: ListView(
              controller: _controller,
              children: [
                Table(
                  /*  border: TableBorder.symmetric(
                      outside: BorderSide(color: Colors.redAccent, width: 1, style: BorderStyle.solid, strokeAlign: 10,),
                      inside:  BorderSide(color: Colors.blueAccent, width: 2, style: BorderStyle.solid, strokeAlign:5,),
                    ),*/
                  children: List.generate(
                    _selectDiv == 0
                        ? _lendingListData.length + 1
                        : _sellingListData.length + 1,
                        (index) => _setTableRow(index),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        : Expanded(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: CustomStickyHeadersTableBasic(
              columnsLength: _loanListTitle.length,
              rowsLength: _loanListData.length,
              columnsTitleBuilder: (columnIndex) => Container(
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: 1.0,
                      color: RColor.bgTableTextGrey,
                    ),
                  ),
                  color: RColor.bgTableGrey,
                ),
                child: Text(
                  _loanListTitle[columnIndex],
                  style: const TextStyle(
                    fontSize: 16,
                    color: RColor.bgTableTextGrey,
                  ),
                ),
              ),
              rowsTitleBuilder: (rowIndex) {
                return Container(
                  height: 40,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 1.0,
                        color: RColor.lineGrey,
                      ),
                    ),
                    //color: RColor.bgTableGrey,
                  ),
                  child: Center(
                    child: Text(
                      TStyle.getDateDivFormat(
                          _loanListData[rowIndex].tradeDate),
                      style: const TextStyle(
                        fontSize: 14,
                        color: RColor.bgTableTextGrey,
                      ),
                    ),
                  ),
                );
              },
              legendCell: Container(
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: 1.0,
                      color: RColor.bgTableTextGrey,
                    ),
                  ),
                  color: RColor.bgTableGrey,
                ),
                child: const Text(
                  '일자',
                  style: TextStyle(
                    fontSize: 16,
                    color: RColor.bgTableTextGrey,
                  ),
                ),
              ),
              contentCellBuilder: (columnIndex, rowIndex) {
                return Container(
                  height: 40,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 1.0,
                        color: RColor.lineGrey,
                      ),
                    ),
                    //color: RColor.bgTableGrey,
                  ),
                  child: Center(
                    child: Text(
                      columnIndex == 0
                          ? TStyle.getMoneyPoint(_loanListData[rowIndex].volumeNew,)
                          : columnIndex == 1
                          ? TStyle.getMoneyPoint(_loanListData[rowIndex].volumeRepay)
                          : columnIndex == 2
                          ? TStyle.getMoneyPoint(_loanListData[rowIndex].volumeBalance)
                          : columnIndex == 3
                          ? '${_loanListData[rowIndex].creditRate}%'
                          : columnIndex == 4
                          ? '${_loanListData[rowIndex].balanceRate}%'
                          : '데이터 없음',
                      style: const TextStyle(
                        fontSize: 14,
                        color: RColor.bgTableTextGrey,
                      ),
                    ),
                  ),
                );
              },
              scrollControllers: custom_class_scroller.ScrollControllers(
                verticalBodyController: _controller,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _setDivButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: InkWell(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 1.4,
                  color: _selectDiv == 0 ? Colors.black : RColor.lineGrey,
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(
                    5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '대차거래',
                  style: _selectDiv == 0
                      ? TStyle.commonTitle15
                      : const TextStyle(fontSize: 15, color: RColor.lineGrey),
                ),
              ),
            ),
            onTap: () {
              if (_selectDiv != 0) {
                setState(() {
                  _selectDiv = 0;
                  //_requestTrInvest21();
                });
              }
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: InkWell(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 1.4,
                  color: _selectDiv == 1 ? Colors.black : RColor.lineGrey,
                ),
              ),
              child: Center(
                child: Text(
                  '공매도',
                  style: _selectDiv == 1
                      ? TStyle.commonTitle15
                      : const TextStyle(
                    fontSize: 15,
                    color: RColor.lineGrey,
                  ),
                ),
              ),
            ),
            onTap: () {
              if (_selectDiv != 1) {
                setState(() {
                  _selectDiv = 1;
                  if (_sellingPageNo == 0) {
                    _requestTrInvest22();
                  }
                });
              }
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: InkWell(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 1.4,
                  color: _selectDiv == 2 ? Colors.black : RColor.lineGrey,
                ),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(
                    5,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '신용융자',
                  style: _selectDiv == 2
                      ? TStyle.commonTitle15
                      : const TextStyle(
                    fontSize: 15,
                    color: RColor.lineGrey,
                  ),
                ),
              ),
            ),
            onTap: () {
              if (_selectDiv != 2) {
                setState(() {
                  _selectDiv = 2;
                  if (_loanPageNo == 0) {
                    _requestTrInvest23();
                  }
                });
              }
            },
          ),
        ),
      ],
    );
  }

  _setTableRow(int row) {
    return TableRow(
      children: List.generate(
        5,
            (index) => _setTableView(row, index),
      ),
    );
  }

  _setTableView(int row, int column) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 1,
          color: row == 0 ? RColor.bgTableTextGrey : RColor.lineGrey,
        ),
        row == 0
            ? Container(
            color: RColor.bgTableGrey,
            height: 32,
            alignment: Alignment.center,
            child: _setTitleView(column))
            : _setValueView(row - 1, column),
        Visibility(
          visible: _selectDiv == 0
              ? _lendingListData.length == row
              : _sellingListData.length == row,
          child: Container(
            height: 1,
            color: RColor.bgTableTextGrey,
          ),
        ),
      ],
    );
  }

  _setTitleView(int column) {
    return Text(
      _selectDiv == 0 ? _lendingListTitle[column] : _sellingListTitle[column],
      style: const TextStyle(
        fontSize: 16,
        color: RColor.bgTableTextGrey,
      ),
    );
  }

  _setValueView(int row, int column) {
    String value = '';
    if (column == 0) {
      value = TStyle.getDateDivFormat(_selectDiv == 0
          ? _lendingListData[row].td
          : _sellingListData[row].td);
    } else if (column == 1) {
      value = TStyle.getMoneyPoint(_selectDiv == 0
          ? _lendingListData[row].tv
          : _sellingListData[row].tv);
    } else if (column == 2) {
      value = TStyle.getMoneyPoint(_selectDiv == 0
          ? _lendingListData[row].rv
          : _sellingListData[row].sv);
    } else if (column == 3) {
      value = TStyle.getMoneyPoint(_selectDiv == 0
          ? _lendingListData[row].bl
          : _sellingListData[row].sr);
    } else if (column == 4) {
      value = TStyle.getMoneyPoint(_selectDiv == 0
          ? _lendingListData[row].ba
          : _sellingListData[row].sa);
    }
    return SizedBox(
      height: 40,
      child: Center(
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: RColor.bgTableTextGrey,
          ),
        ),
      ),
    );
  }

  _requestTrInvest21() async {
    _fetchPosts(
      TR.INVEST21,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'stockCode': _stockCode,
          'pageNo': '$_lendingPageNo',
          'pageItemSize': _lendingPageNo == 0 ? '20' : '10',
        },
      ),
    );
  }

  _requestTrInvest22() async {
    _fetchPosts(
      TR.INVEST22,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'stockCode': _stockCode,
          'pageNo': '$_sellingPageNo',
          'pageItemSize': _sellingPageNo == 0 ? '20' : '10',
        },
      ),
    );
  }

  _requestTrInvest23() async {
    _fetchPosts(
      TR.INVEST23,
      jsonEncode(
        <String, String>{
          'userId': _userId,
          'stockCode': _stockCode,
          'pageNo': '$_loanPageNo',
          'pageItemSize': _loanPageNo == 0 ? '20' : '10',
        },
      ),
    );
  }

  void _fetchPosts(String trStr, String json) async {
    try {
      var url = Uri.parse(Net.TR_BASE + trStr);
      final http.Response response = await http.post(
        url,
        body: json,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: Net.NET_TIMEOUT_SEC));

      _parseTrData(trStr, response);
    } on TimeoutException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    } on SocketException catch (_) {
      CommonPopup.instance.showDialogNetErr(context);
    }
  }

  void _parseTrData(String trStr, final http.Response response) {
    DLog.w(trStr + response.body);
    // NOTE 대차거래
    if (trStr == TR.INVEST21) {
      final TrInvest21 resData =
      TrInvest21.fromJsonWithIndex(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Invest21 invest21 = resData.retData;
        _lendingTotalPageSize = int.parse(invest21.totalPageSize);
        //_lendingListData.clear();
        if (_lendingPageNo == 0) _lendingPageNo++;
        if (invest21.listChartData.isNotEmpty) {
          _lendingListData.addAll(
            invest21.listChartData,
          );
        } else {}
      } else {
        if (_selectDiv == 0 &&
            _lendingPageNo == 0 &&
            _lendingTotalPageSize == 0) {}
      }
      setState(() {});
    }

    // NOTE 공매도
    else if (trStr == TR.INVEST22) {
      final TrInvest22 resData =
      TrInvest22.fromJsonWithIndex(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Invest22 invest22 = resData.retData;
        _sellingTotalPageSize = int.parse(invest22.totalPageSize);
        if (_sellingPageNo == 0) _sellingPageNo++;
        if (invest22.listChartData.isNotEmpty) {
          _sellingListData.addAll(
            invest22.listChartData,
          );
        } else {}
      } else {}
      setState(() {});
    }

    // NOTE 신용융자
    else if (trStr == TR.INVEST23) {
      final TrInvest23 resData =
      TrInvest23.fromJsonWithIndex(jsonDecode(response.body));
      if (resData.retCode == RT.SUCCESS) {
        Invest23 invest23 = resData.retData;
        _loanTotalPageSize = int.parse(invest23.totalPageSize);
        if (_loanPageNo == 0) _loanPageNo++;
        if (invest23.listChartData.isNotEmpty) {
          _loanListData.addAll(
            invest23.listChartData,
          );
        } else {}
      } else {}
      setState(() {});
    }
  }
}
