import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:rassi_assist/ui/common/common_appbar.dart';

class TestWebview extends StatefulWidget {
  //const TestWebview({super.key});
  @override
  State<TestWebview> createState() => _TestWebviewState();
}

class _TestWebviewState extends State<TestWebview> {
  @override
  Widget build(BuildContext context) {

    String _strDoc =
        '''


 <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
 <head>
  <meta content="text/html; charset=EUC-KR" http-equiv="Content-Type">
  </style>
 </head> 
 <body> 
  <p class="SECTION-1"> <a>주권매매거래정지</a> </p> 
  <table cellpadding="1" cellspacing="0" bordercolorlight="black" bordercolordark="white" width="608" border="1"> 
   
    <tr valign="TOP" align="LEFT"> 
     <td height="24" width="180" align="LEFT" colspan="2" rowspan="1" class="TH">1.대상종목</td> 
     <td height="24" width="251" align="LEFT" colspan="1" rowspan="1">(주)유비쿼스</td> 
     <td height="24" width="187" align="LEFT" colspan="1" rowspan="1">보통주</td> 
    </tr> 
    <tr valign="TOP" align="LEFT"> 
     <td height="24" width="180" align="LEFT" colspan="2" rowspan="1" class="TH">2.정지사유</td> 
     <td height="24" width="428" align="LEFT" colspan="2" rowspan="1"> <pre style="FONT-FAMILY:돋움; FONT-SIZE:12px;white-space:pre-wrap;margin:0px;">단일판매공급계？？</pre> </td> 
    </tr> 
    <tr valign="TOP" align="LEFT"> 
     <td height="48" width="90" align="LEFT" colspan="1" rowspan="2" class="TH">3.정지기간</td> 
     <td height="24" width="90" align="LEFT" colspan="1" rowspan="1" class="TH">가.정지일시</td> 
     <td height="24" width="228" align="LEFT" colspan="1" rowspan="1">2023-10-12</td> 
     <td height="24" width="200" align="LEFT" colspan="1" rowspan="1">12:23:00</td> 
    </tr> 
    <tr valign="TOP" align="LEFT"> 
     <td height="24" width="90" align="LEFT" colspan="1" rowspan="1" class="TH">나.만료일시</td> 
     <td height="24" width="428" align="LEFT" colspan="2" rowspan="1"><pre style="FONT-FAMILY:돋움; FONT-SIZE:12px;white-space:pre-wrap;margin:0px;">매매거래 정지시점부터 30분 경과시점까지</pre></td> 
    </tr> 
    <tr valign="TOP" align="LEFT"> 
     <td height="24" width="180" align="LEFT" colspan="2" rowspan="1" class="TH">4.근거규정</td> 
     <td height="24" width="428" align="LEFT" colspan="2" rowspan="1"><pre style="FONT-FAMILY:돋움; FONT-SIZE:12px;white-space:pre-wrap;margin:0px;">코스닥시장공시규정 제37조 및 동규정시행세칙 제18조</pre></td> 
    </tr> 
    <tr valign="TOP" align="LEFT"> 
     <td height="24" width="180" align="LEFT" colspan="2" rowspan="1" class="TH">5.기타</td> 
     <td height="24" width="428" align="LEFT" colspan="2" rowspan="1"><pre style="FONT-FAMILY:돋움; FONT-SIZE:12px;white-space:pre-wrap;margin:0px;">코스닥시장 업무규정 제18조에 따라 매매거래 재개 시점부터 10분간 
단일가격에 의한 개별경쟁매매 방식으로 가격이 결정됨
(단일가매매 임의종료(랜덤엔드) 적용)</pre></td> 
    </tr> 
  
  </table>   
 </body>
</html>

       

        ''';

    return Scaffold(
      appBar: CommonAppbar.simpleNoTitleWithExit(context, Colors.white, Colors.black),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: 500,
          color: Colors.cyan,
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                width: 300,
                height: 300,
                child:
                ListView(
                  shrinkWrap: true,
                  children: [
                    Html(
                      data: _strDoc,
                      shrinkWrap: true,
                      style: {
                        "html": Style(
                          fontSize: FontSize(14.0),
                          width: Width.auto(),
                          height: Height.auto(),
                        ),
                        "body": Style(
                          fontSize: FontSize(14.0),
                          width: Width.auto(),
                          height: Height.auto(),
                        ),
                        "div": Style(
                          fontSize: FontSize(14.0),
                          width: Width.auto(),
                          height: Height.auto(),
                        ),
                        "span": Style(
                          fontSize: FontSize(14.0),
                          width: Width.auto(),
                          height: Height.auto(),
                        ),
                        "table": Style(
                          fontSize: FontSize(14.0),
                          width: Width.auto(),
                          height: Height.auto(),
                        ),
                        "TABLE": Style(
                          fontSize: FontSize(14.0),
                          width: Width.auto(),
                          height: Height.auto(),
                        ),
                        "colgroup": Style(
                          fontSize: FontSize(14.0),
                          width: Width.auto(),
                          height: Height.auto(),
                        ),
                        "col": Style(
                          fontSize: FontSize(14.0),
                          width: Width.auto(),
                          height: Height.auto(),
                        ),
                        "nb": Style(
                          fontSize: FontSize(14.0),
                          width: Width.auto(),
                          height: Height.auto(),
                        ),
                        "pre": Style(
                          fontSize: FontSize(14.0),
                          width: Width.auto(),
                          height: Height.auto(),
                        ),
                        "tbody": Style(
                          fontSize: FontSize(14.0),
                          width: Width.auto(),
                          height: Height.auto(),
                        ),
                        "tr": Style(
                          width: Width.auto(),
                          height: Height.auto(),
                        ),
                        "th": Style(
                          width: Width.auto(),
                          height: Height.auto(),
                          border: const Border(
                            left: BorderSide(color: Colors.black, width: 0.5),
                            bottom:
                            BorderSide(color: Colors.black, width: 0.5),
                            top: BorderSide(color: Colors.black, width: 0.5),
                          ),
                        ),
                        "TH": Style(
                          width: Width.auto(),
                          height: Height.auto(),
                          border: const Border(
                            left: BorderSide(color: Colors.black, width: 0.5),
                            bottom:
                            BorderSide(color: Colors.black, width: 0.5),
                            top: BorderSide(color: Colors.black, width: 0.5),
                          ),
                        ),
                        "td": Style(
                          width: Width.auto(),
                          height: Height.auto(),
                          border: const Border(
                            left: BorderSide(color: Colors.black, width: 0.5),
                            bottom:
                            BorderSide(color: Colors.black, width: 0.5),
                            top: BorderSide(color: Colors.black, width: 0.5),
                            right:
                            BorderSide(color: Colors.black, width: 0.5),
                          ),
                        ),
                        "TD": Style(
                          width: Width.auto(),
                          height: Height.auto(),
                          border: const Border(
                            left: BorderSide(color: Colors.black, width: 0.5),
                            bottom:
                            BorderSide(color: Colors.black, width: 0.5),
                            top: BorderSide(color: Colors.black, width: 0.5),
                            right:
                            BorderSide(color: Colors.black, width: 0.5),
                          ),
                        ),
                      },
                      onLinkTap: (url, attributes, element) {

                      },
                      extensions: [

                        TagExtension(
                          tagsToExtend: {"p", "pre"},
                          builder: (extensionContext) {
                            return Text(
                              extensionContext.element!.text,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                        const TableHtmlExtension(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
