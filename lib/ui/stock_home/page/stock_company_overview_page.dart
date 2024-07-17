import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rassi_assist/common/const.dart';
import 'package:rassi_assist/common/custom_nv_route_class.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/common/ui_style.dart';
import 'package:rassi_assist/models/none_tr/app_global.dart';
import 'package:rassi_assist/models/tr_shome/tr_shome07.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';
import 'package:rassi_assist/ui/web/inapp_webview_page.dart';

class StockCompanyOverviewPage extends StatelessWidget {
  static const routeName = '/stock_company_overview';

  const StockCompanyOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shome07stockContent = ModalRoute.of(context)!.settings.arguments as Shome07StockContent;
    return Scaffold(
      appBar: CommonAppbar.simpleNoTitleWithExit(
        context,
        RColor.bgBasic_fdfdfd,
        Colors.black,
      ),
      backgroundColor: RColor.bgBasic_fdfdfd,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  //physics: NeverScrollableScrollPhysics(),
                  children: [
                    Row(
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/icon_shome07_1.png',
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Expanded(
                          child: Text(
                            '챗GPT가 요약한 사업 개요',
                            style: TStyle.title17,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${TStyle.getDateLongYmKorFormat(shome07stockContent.refMonth)} 보고서 기준',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      shome07stockContent.content,
                    ),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: RColor.new_basic_line_grey,
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                    ),
                    const Text(
                      '※ ChatGPT를 이용한 사업개요 요약은 DART 자료를 바탕으로 수집되며, 기술적 방법에 따라 일부 내용에 오류가 있을 수 있습니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: RColor.bgTableTextGrey,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '※ ${AppGlobal().stkName}의 공시자료를 GPT-3.5 Turbo로 구동되는 씽크풀의 컨텐츠 생성 및 검수 시스템을 통해 요약한 정보 입니다. 본 컨텐츠는 AI를 이용한 컨텐츠로, AI기술이 가진 구조적 한계를 가지고 있습니다.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: RColor.bgTableTextGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    Platform.isAndroid
                        ? CustomNvRouteClass.createRouteSlow1(
                            InappWebviewPage(title: '${AppGlobal().stkName} 보고서', url: shome07stockContent.linkUrl),
                          )
                        : CustomNvRouteClass.createRoute(
                            InappWebviewPage(title: '${AppGlobal().stkName} 보고서', url: shome07stockContent.linkUrl),
                          ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  decoration: UIStyle.boxRoundLine6bgColor(
                    RColor.bgBasic_fdfdfd,
                  ),
                  alignment: Alignment.center,
                  child: const Text('보고서 원문 보기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
