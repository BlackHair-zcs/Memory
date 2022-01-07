import 'package:flutter/material.dart';
import 'package:memory/model/type.dart';
import 'package:memory/utils/api_client.dart';
import 'package:memory/view/errorpage.dart';
import 'package:memory/view/typelistpage.dart';

class TypePage extends StatefulWidget {
  TypePage({Key? key}) : super(key: key);

  @override
  _TypePageState createState() => new _TypePageState();
}

class _TypePageState extends State<TypePage> {
  final TypeRepository _typeRepository = TypeRepository();
  final APIClient _apiClient = APIClient();
  final String _protocal = "http://";
  final String _host = "120.26.166.10:8000";
  List _typeOfMemory = [];
  bool _isLoading = true;
  bool _httpError = false;
  String _nowTime = "";

  @override
  void initState() {
    super.initState();
    _apiClient.getNowTime().then((time) {
      _isLoading = false;
      if (time == "failure") {
        setState(() {
          _httpError = true;
        });
      } else {
        setState(() {
          _nowTime = time;
        });
      }
    });

    _typeRepository.getAllTypes().then((types) {
      if (types == "failure") {
        setState(() {
          _httpError = true;
        });
      } else {
        setState(() {
          _typeOfMemory = types;
        });
      }
    });
  }

  /// 构建种类展示卡片
  Widget _buildTypeCard(int i, TypeModel typeModel) {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => TypeListPage(typeModel)));
        },
        child: Container(
          width: 230,
          child: Column(children: [
            Container(
              height: 240,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        _protocal + _host + '/' + typeModel.backImgURL),
                    fit: BoxFit.fill),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
              ),
            ),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 219, 219, 219),
                    offset: Offset(6.0, 6.0), //阴影y轴偏移量
                    blurRadius: 6.0, //阴影模糊程度
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text(
                          "$i",
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Text(typeModel.typeName,
                            style: TextStyle(fontSize: 18.0)),
                      ),
                    ],
                  ),
                  Divider(
                      color: Color(0xFFAEADAD), indent: 15.0, endIndent: 15.0),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  /// 种类卡片列表组件
  List<Widget> _buildTypeList() {
    List<Widget> typeList = [];
    for (int i = 0; i < _typeOfMemory.length; i++) {
      typeList.add(_buildTypeCard(i + 1, _typeOfMemory[i]));
    }

    return typeList;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> item = _buildTypeList();

    return _isLoading
        ? ErrorPage("正在加载，请稍后")
        : _httpError
            ? ErrorPage("网络请求错误，请稍后再试")
            : Container(
                decoration: BoxDecoration(color: Color(0xFF5F5F5)),
                child: Column(children: [
                  Container(
                      height: 360,
                      child: item.length > 0
                          ? ListView(
                              scrollDirection: Axis.horizontal,
                              children: item,
                            )
                          : Container()),
                  Padding(
                    padding: EdgeInsets.only(top: 24.0, left: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text("Today",
                                style: TextStyle(fontSize: 22.0))),
                        Row(
                          children: [
                            Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text(_nowTime.substring(5, 11),
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Color(0xFFAEADAD)))),
                            Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text(
                                    _nowTime.substring(
                                        _nowTime.length - 3, _nowTime.length),
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Color(0xFFAEADAD))))
                          ],
                        )
                      ],
                    ),
                  ),
                ]),
              );
  }
}
