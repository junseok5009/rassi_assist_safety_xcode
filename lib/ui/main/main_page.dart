import 'package:flutter/material.dart';


//Collapsing Toolbar +
//TabController +
//TODO (일단 보류)
class MainPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.white,
            floating: false,
            pinned: true,
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text('Sliver title'),
              background: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.black26,
                      width: 1.0
                    )
                  )
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

}

