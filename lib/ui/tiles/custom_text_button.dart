import 'package:flutter/material.dart';
import 'package:rassi_assist/common/tstyle.dart';
import 'package:rassi_assist/models/pg_data.dart';


//
class CustomTextButton extends StatelessWidget {
  final PgData item;
  final String pgRoute;
  CustomTextButton(this.item, this.pgRoute);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.deepPurpleAccent.withAlpha(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('이 시간 AI속보', style: TStyle.puplePlainStyle(),),
          Text(' 더보기 +'),
        ],
      ),
      onTap: (){
        // Navigator.push(context, new MaterialPageRoute(
        //   builder: (context) => pgRoute,
        // ));

        Navigator.pushNamed(
          context,
          pgRoute,
          // arguments: PgData(pgSn: item.pocketSn,),
        );


      },
    );
  }

}