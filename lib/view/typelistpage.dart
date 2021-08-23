import 'package:flutter/material.dart';
import 'package:memory/model/memory.dart';
import 'package:memory/model/type.dart';
import 'package:memory/view/addorsetpage.dart';
import 'package:memory/view/detailpage.dart';
import 'package:memory/view/errorpage.dart';
import 'package:memory/view/loadingpage.dart';

class TypeListPage extends StatefulWidget {
  TypeModel type;

  TypeListPage(this.type, {Key? key}) : super(key: key);

  @override
  _TypeListPageState createState() => new _TypeListPageState();
}

class _TypeListPageState extends State<TypeListPage> {
  final String _protocal = "http://";
  final String _host = "47.98.175.209:8080";
  final MemoryStore _memoryStore = MemoryStore();
  List _memoryData = [];
  bool _isLoading = true;
  bool _httpError = false;

  @override
  void initState() {
    super.initState();
    _getServerData();
  }

  _getServerData() {
    // 从服务器获取数据
    _isLoading = true;
    _memoryStore.getMemoryByTypeId(widget.type.id).then((posts) {
      _isLoading = false;
      if (posts == "failure") {
        setState(() {
          _httpError = true;
        });
      } else {
        setState(() {
          _memoryData = posts;
        });
      }
    });
  }

  void _showDialog(String title, String content) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
                child: Text(
              title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            )),
            content: Text(content),
            actions: <Widget>[
              MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('确定')),
            ],
          );
        });
  }

  /// 构建种类展示卡片
  Widget _buildTypeCard(MemoryModel data) {
    return Padding(
        padding:
            EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0, bottom: 20.0),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DetailPage(data.id)));
          },
          child: Container(
            child: Column(children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(
                          _protocal + _host + '/' + data.type.backImgURL),
                      fit: BoxFit.fill),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                ),
              ),
              Container(
                height: 35,
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 219, 219, 219),
                      offset: Offset(3.0, 3.0), //阴影y轴偏移量
                      blurRadius: 6.0, //阴影模糊程度
                    )
                  ],
                ),
                child: Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(left: 12.0),
                            child: Text(data.title,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600))),
                        DropdownButton<String>(
                            underline: Container(),
                            onChanged: (String? newValue) {
                              if (newValue == "删除") {
                                // 请求删除接口
                                _memoryStore.removeMemory(data.id).then((res) {
                                  if (res[0] == 'success') {
                                    _getServerData();
                                    _showDialog('删除成功', res[1]);
                                  } else {
                                    _showDialog('删除失败', res[1]);
                                  }
                                });
                              } else if (newValue == "编辑") {
                                // 关闭当前页面, 跳转到编辑页
                                Navigator.of(context).pop();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddOrSetPage(
                                          1, data.createDate,
                                          editMemory: data),
                                    ));
                              }
                            },
                            items: [
                              DropdownMenuItem(value: "删除", child: Text("删除")),
                              DropdownMenuItem(value: "编辑", child: Text("编辑")),
                            ]),
                      ]),
                ),
              ),
            ]),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingPage()
        : Scaffold(
            appBar: new AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                centerTitle: true,
                title: new Text(widget.type.typeName,
                    style: new TextStyle(color: Colors.black, fontSize: 18)),
                iconTheme: IconThemeData(
                  color: Colors.black, //修改颜色
                )),
            body: _httpError
                ? ErrorPage("网络请求错误，请稍后再试")
                : Container(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 0.8),
                      itemCount: _memoryData.length,
                      itemBuilder: (context, index) {
                        return _buildTypeCard(_memoryData[index]);
                      },
                    ),
                  ),
          );
  }
}
