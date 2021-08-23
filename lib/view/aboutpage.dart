import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //修改颜色
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Text("简忆介绍", style: TextStyle(color: Colors.black)),
        ),
        body: Container(
          child: Padding(
            padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "欢迎来到",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "简忆",
                        style: TextStyle(
                          fontSize: 36.0,
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                      """简忆 是一款用于记录你的故事的日记app，拥有十分简约的软件风格，用户完全不会被广告等冗余功能所打扰。作者希望以此能够带给用户更好的软件体验。在现代社会中，或许你会有许多烦恼，压力没有地方倾诉。在这里，简忆 会慢慢倾听你的诉说，记录你的故事。

简忆 能够记录你生活中的故事，并将它们分类展示。你也可以通过 首页日历 看到自己某一天的故事。由于作者经验不足，可能会有很多不足的地方，欢迎联系作者指出，感谢你的支持☞。"""),
                )
              ],
            ),
          ),
        ));
  }
}
