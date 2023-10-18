import 'package:flutter/material.dart';

class TestHalfLayerMain extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.redAccent,
        ),
      ),
    );
  }

 /* Widget _showHalfBottomSheet(String vLinkUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (_) {
        return
          DraggableScrollableSheet(
            expand: false,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            initialChildSize: 0.4,
            builder: (BuildContext context, ScrollController scrollController) {
              return HalfOnlyWebView(vLinkUrl, scrollController);
            },
          );
      },
    );
  }*/
  
}
