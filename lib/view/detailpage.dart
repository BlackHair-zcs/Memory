import 'package:flutter/material.dart';
import 'package:memory/model/memory.dart';
import 'package:memory/view/addorsetpage.dart';
import 'package:memory/view/homepage.dart';
import 'package:memory/view/loadingpage.dart';

class DetailPage extends StatefulWidget {
  String memoryId;

  DetailPage(this.memoryId, {Key? key}) : super(key: key);

  @override
  _DetailPageState createState() => new _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  MemoryModel? _memoryData;
  MemoryStore _memoryStore = MemoryStore();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _memoryStore.getMemoryByMemoryId(widget.memoryId).then((post) {
      _isLoading = false;
      if (post != "failure") {
        setState(() {
          _memoryData = post;
        });
      }
    });
  }

  void _showDialog(String title, String content, bool isBack) {
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

                    if (isBack) {
                      // 关闭当前页面和主页面，跳转到主页面使页面刷新
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => HomePage()));
                    }
                  },
                  child: Text('确定')),
            ],
          );
        });
  }

  Widget _buildContent(String type, String title, String content) {
    return Column(children: [
      Padding(
        padding: EdgeInsets.only(top: 24.0, left: 16.0),
        child: Container(
          alignment: Alignment.centerLeft,
          child: Text(title,
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w600)),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: Container(
          alignment: Alignment.centerRight,
          child: Text(
            type,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(12.0),
        child: Container(
          child: Text(content, style: TextStyle(fontSize: 18.0)),
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingPage()
        : Scaffold(
            appBar: new AppBar(
              iconTheme: IconThemeData(
                color: Colors.black, //修改颜色
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                DropdownButton<String>(
                    underline: Container(),
                    onChanged: (String? newValue) {
                      if (newValue == "删除") {
                        // 请求删除接口
                        _memoryStore.removeMemory(widget.memoryId).then((res) {
                          if (res[0] == 'success') {
                            _showDialog('删除成功', res[1], true);
                          } else {
                            _showDialog('删除失败', res[1], false);
                          }
                        });
                      } else if (newValue == "编辑") {
                        // 关闭当前页面, 跳转到编辑页
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddOrSetPage(
                                  1, _memoryData!.createDate,
                                  editMemory: _memoryData),
                            ));
                      }
                    },
                    items: [
                      DropdownMenuItem(value: "删除", child: Text("删除")),
                      DropdownMenuItem(value: "编辑", child: Text("编辑")),
                    ]),
                SizedBox(width: 20),
              ],
              title: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                    _memoryData!.createDate
                        .substring(_memoryData!.createDate.length - 3),
                    style: new TextStyle(color: Colors.black, fontSize: 20.0)),
                Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: Text(_memoryData!.createDate.substring(0, 11),
                        style: new TextStyle(
                            color: Color(0xFFADADAD), fontSize: 14.0)))
              ]),
            ),
            body: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: _buildContent(_memoryData!.type.typeName,
                  _memoryData!.title, _memoryData!.content),
            ),
          );
  }
}
