import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/news/news_tag_page.dart';


class NewsTagAllPage extends StatelessWidget {
  //const NewsTagAllPage({Key? key}) : super(key: key);
  static const String TAG_NAME = '라씨로_태그_전체보기';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _setCustomAppBar(),
      /* AppBar(toolbarHeight: 0,
        backgroundColor: RColor.deepStat, elevation: 0,),*/
      body: SafeArea(child: NewsTagAllPageWidget()),
    );
  }

  // 타이틀바(AppBar)
  PreferredSizeWidget _setCustomAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(55),
      child: AppBar(
        centerTitle: true,
        title: const Text(
          'AI속보 태그 전체보기',
          style: TStyle.commonTitle,
        ),
        /*    Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('AI속보 태그 전체보기', style: TStyle.commonTitle,),
            const SizedBox(width: 55.0,),
          ],
        ),*/
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        toolbarHeight: 50,
        elevation: 1,
      ),
    );
  }
}

class TagAllModel {
  String tagName;
  String tagInfo;
  String tagCode;

  TagAllModel({this.tagName = '', this.tagInfo = '', this.tagCode = ''});

  @override
  String toString() {
    return '$tagName|$tagInfo|$tagCode';
  }
}

class NewsTagAllPageWidget extends StatefulWidget {
  List<List<TagAllModel>> initData() {
    final List<List<TagAllModel>> vListListTagAllModel = [];

    for (int i = 0; i < 6; i++) {
      final List<TagAllModel> vListTagAllModel = [];

      List<String> vListTagName = [];
      List<String> vListTagInfo = [];
      List<String> vListTagCode = [];

      switch (i) {
        case 0:
          vListTagName = RString.str_list_tag_all_0_name;
          vListTagInfo = RString.str_list_tag_all_0_info;
          vListTagCode = RString.str_list_tag_all_0_code;
          break;
        case 1:
          vListTagName = RString.str_list_tag_all_1_name;
          vListTagInfo = RString.str_list_tag_all_1_info;
          vListTagCode = RString.str_list_tag_all_1_code;
          break;
        case 2:
          vListTagName = RString.str_list_tag_all_2_name;
          vListTagInfo = RString.str_list_tag_all_2_info;
          vListTagCode = RString.str_list_tag_all_2_code;
          break;
        case 3:
          vListTagName = RString.str_list_tag_all_3_name;
          vListTagInfo = RString.str_list_tag_all_3_info;
          vListTagCode = RString.str_list_tag_all_3_code;
          break;
        case 4:
          vListTagName = RString.str_list_tag_all_4_name;
          vListTagInfo = RString.str_list_tag_all_4_info;
          vListTagCode = RString.str_list_tag_all_4_code;
          break;
        case 5:
          vListTagName = RString.str_list_tag_all_5_name;
          vListTagInfo = RString.str_list_tag_all_5_info;
          vListTagCode = RString.str_list_tag_all_5_code;
          break;
      }

      for (int k = 0; k < vListTagName.length; k++) {
        vListTagAllModel.add(
          TagAllModel(
            tagName: vListTagName[k],
            tagInfo: vListTagInfo[k],
            tagCode: vListTagCode[k],
          ),
        );
      }

      vListListTagAllModel.add(vListTagAllModel);
    }

    return vListListTagAllModel;
  }

  @override
  State<NewsTagAllPageWidget> createState() => _NewsTagAllPageWidgetState(initData());
}

class _NewsTagAllPageWidgetState extends State<NewsTagAllPageWidget>
    with TickerProviderStateMixin {
  final List<List<TagAllModel>> _listListTagAllModel;
  late TabController tabController;
  List<TagAllModel> _listTagAllModel = [];

  _NewsTagAllPageWidgetState(this._listListTagAllModel);

  final Decoration _btnDecorationOn = const BoxDecoration(
    color: RColor.mainColor,
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
  );

  final Decoration _btnDecorationOff = BoxDecoration(
    color: Colors.white,
    border: Border.all(
      color: RColor.lineGrey,
      width: 0.8,
    ),
    borderRadius: const BorderRadius.all(Radius.circular(30.0)),
  );

  int _clickIndex = 0;

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(NewsTagAllPage.TAG_NAME);
    _listTagAllModel = _listListTagAllModel[0];
    tabController = TabController(length: 6, vsync: this);
    tabController.addListener((){
      if (_clickIndex != tabController.index) {
        setState(() {
          _clickIndex = tabController.index;
          _listTagAllModel = _listListTagAllModel[tabController.index];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        //physics: NeverScrollableScrollPhysics(),
        children: [
          Container(
            color: RColor.bgWeakGrey,
            child: Column(
              children: [
                const SizedBox(
                  height: 14,
                ),
                _makeBtnViews(),
                const SizedBox(
                  height: 14,
                ),
              ],
            ),
          ),
          _makeTagViews(),
        ],
      ),
    );
  }

  Widget _makeBtnViews() {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            controller: tabController,
            isScrollable: true,
            labelPadding: const EdgeInsets.symmetric(horizontal: 6.0),
            indicatorColor: Colors.transparent,
            tabs: List.generate(
              6,
              (i) => Tab(
                height: 48,
                child: _makeBtnTile(i),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _makeBtnTile(int vIndex) {
    String _title = '';
    switch (vIndex) {
      case 0:
        _title = '수급';
        break;
      case 1:
        _title = '테마';
        break;
      case 2:
        _title = '공시';
        break;
      case 3:
        _title = '실적';
        break;
      case 4:
        _title = '리포트';
        break;
      case 5:
        _title = '시세';
        break;
    }



    return Container(
      padding: const EdgeInsets.fromLTRB(30, 14, 30, 14),
      decoration:
      _clickIndex == vIndex ? _btnDecorationOn : _btnDecorationOff,
      child: Text(
        _title,
        //textAlign: TextAlign.center,
        style: TextStyle(
          color: _clickIndex == vIndex ? Colors.white : Colors.black,
          fontSize: 15,
        ),
      ),
    );

  }

  Widget _makeTagViews() {
    return Expanded(
      child: ListView.separated(
        itemBuilder: (context, index) {
          return _makeTagTile(index);
        },
        separatorBuilder: (context, index) {
          return const Divider(
            thickness: 1.4,
            color: RColor.lineGrey,
          );
        },
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: _listTagAllModel.length,
        // physics: ScrollPhysics(),
      ),
    );
  }

  Widget _makeTagTile(int vIndex) {
    return InkWell(
      onTap: () {
        basePageState.callPageRouteNews(
            NewsTagPage(),
            PgNews(
                tagCode: _listTagAllModel[vIndex].tagCode,
                tagName: _listTagAllModel[vIndex].tagName));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 6,
            ),
            child: Text(
              '#${_listTagAllModel[vIndex].tagName}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: RColor.mainColor,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Text(
              _listTagAllModel[vIndex].tagInfo,
              style: TStyle.content15,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
        ],
      ),
    );
  }
}
