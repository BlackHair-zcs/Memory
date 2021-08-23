import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthorPage extends StatelessWidget {
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
          title: Text("联系作者", style: TextStyle(color: Colors.black)),
        ),
        body: Container(
          child: Center(
              child: Text(
            """作者联系方式：
QQ: 1486077252""",
            style: TextStyle(fontSize: 20.0, fontStyle: FontStyle.italic),
          )),
        ));
  }
}
