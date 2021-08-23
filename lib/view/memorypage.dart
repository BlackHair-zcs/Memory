import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memory/view/timepage.dart';
import 'package:memory/view/typepage.dart';

class MemoryPage extends StatefulWidget {
  MemoryPage({Key? key}) : super(key: key);

  @override
  _MemoryPageState createState() => new _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  final List<String> _tabs = ["时间", "分类"];

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: _tabs.length,
        child: new Scaffold(
            appBar: new AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              title: new Text('简忆',
                  style: new TextStyle(color: Colors.black, fontSize: 18)),
              bottom: TabBar(
                  indicatorColor: Colors.black,
                  indicatorSize: TabBarIndicatorSize.label,
                  unselectedLabelColor: Color(0xFFADADAD),
                  unselectedLabelStyle: TextStyle(fontSize: 12),
                  labelStyle: TextStyle(fontSize: 14),
                  labelColor: Colors.black,
                  tabs: _tabs.map((val) => Tab(text: val)).toList()),
            ),
            body: TabBarView(children: [TimePage(), TypePage()])));
  }
}
