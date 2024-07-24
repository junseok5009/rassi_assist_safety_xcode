import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_firebase_class.dart';
import 'package:rassi_assist/common/strings.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_news.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/main/base_page.dart';
import 'package:rassi_assist/ui/news/news_tag_page.dart';

import '../../common/ui_style.dart';

class NewsTagAllPage extends StatefulWidget {
  static const String TAG_NAME = '라씨로_태그_전체보기';

  const NewsTagAllPage({super.key});

  @override
  State<NewsTagAllPage> createState() => _NewsTagAllPageState();
}

class _NewsTagAllPageState extends State<NewsTagAllPage> with TickerProviderStateMixin {
  final List<List<TagAllModel>> _listListTagAllModel = [];
  late TabController tabController;
  List<TagAllModel> _listTagAllModel = [];
  final Decoration _btnDecorationOn = const BoxDecoration(
    color: Colors.black87,
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
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    CustomFirebaseClass.logEvtScreenView(NewsTagAllPage.TAG_NAME);
    initData();
    _listTagAllModel = _listListTagAllModel[0];
    tabController = TabController(length: 6, vsync: this);
    tabController.addListener(() {
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
      appBar: CommonAppbar.basic(
        buildContext: context,
        title: 'AI속보 태그 전체보기',
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),
            _makeBtnViews(),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _setPageHeader(),
                    _makeTagListViews(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  initData() {
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

      _listListTagAllModel.add(vListTagAllModel);
    }
  }

  Widget _setPageHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      color: const Color(0xffF5F5F5),
      child: const Column(
        children: [
          Text(
            '관심 키워드를 눌러 해당 키워드에 AI속보의 태그를 확인해 보세요.',
            style: TStyle.content14,
          )
        ],
      ),
    );
  }

  Widget _makeBtnViews() {
    return SizedBox(
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
    String title = '';
    switch (vIndex) {
      case 0:
        title = '수급';
        break;
      case 1:
        title = '테마';
        break;
      case 2:
        title = '공시';
        break;
      case 3:
        title = '실적';
        break;
      case 4:
        title = '리포트';
        break;
      case 5:
        title = '시세';
        break;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(30, 14, 30, 14),
      decoration: _clickIndex == vIndex ? _btnDecorationOn : _btnDecorationOff,
      child: Text(
        title,
        style: TextStyle(
          color: _clickIndex == vIndex ? Colors.white : Colors.black,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _makeTagListViews() {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _listTagAllModel.length,
      itemBuilder: (context, index) {
        return _makeTagTile(index);
      },
    );
  }

  Widget _makeTagTile(int vIndex) {
    return InkWell(
      onTap: () {
        basePageState.callPageRouteNews(
          NewsTagPage(),
          PgNews(tagCode: _listTagAllModel[vIndex].tagCode, tagName: _listTagAllModel[vIndex].tagName),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 15),
            child: Container(
              padding: const EdgeInsets.fromLTRB(7, 3, 7, 3),
              decoration: UIStyle.boxRoundLine25c(RColor.mainColor),
              child: Text(
                '#${_listTagAllModel[vIndex].tagName}',
                style: const TextStyle(
                  fontSize: 14,
                  color: RColor.mainColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // child: Text(
            //   '#${_listTagAllModel[vIndex].tagName}',
            //   textAlign: TextAlign.center,
            //   style: const TextStyle(
            //     fontWeight: FontWeight.w500,
            //     fontSize: 16,
            //     color: RColor.mainColor,
            //   ),
            // ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Text(
              _listTagAllModel[vIndex].tagInfo,
              style: TStyle.content15,
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              color: Colors.black12,
              height: 1.2,
            ),
          ),
        ],
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
