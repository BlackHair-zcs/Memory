import 'package:flutter/material.dart';
import 'package:memory/model/memory.dart';
import 'package:memory/model/type.dart';
import 'package:memory/utils/cache_data.dart';
import 'package:memory/view/errorpage.dart';
import 'package:memory/view/homepage.dart';
import 'package:memory/view/loadingpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddOrSetPage extends StatefulWidget {
  /// 发布日记或者编辑日记
  /// 0 表示发布
  /// 1 表示编辑
  int addOrSet;

  /// 当前日记撰写时间
  String memoryTime;

  /// 需要编辑的日记内容
  MemoryModel? editMemory;

  AddOrSetPage(this.addOrSet, this.memoryTime, {Key? key, this.editMemory})
      : super(key: key);

  @override
  _AddOrSetPageState createState() => new _AddOrSetPageState();
}

class _AddOrSetPageState extends State<AddOrSetPage> {
  final TypeRepository _typeRepository = TypeRepository();
  final MemoryStore _memoryStore = MemoryStore();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final Future<SharedPreferences> _pres = SharedPreferences.getInstance();
  final _backImagePath = [
    "assets/icons/beijin/beijin1.jpg",
    "assets/icons/beijin/beijin2.jpg",
    "assets/icons/beijin/beijin3.jpg",
    "assets/icons/beijin/beijin4.jpg",
    "assets/icons/beijin/beijin5.jpg",
    "assets/icons/beijin/beijin6.jpg",
  ];
  String _nowImagePath = "assets/icons/beijin/beijin1.jpg";
  String _username = "";
  List _typeOfMemory = [];
  TypeModel? _memoryType;
  bool _isLoading = true;
  bool _httpError = false;

  // 初始化背景
  @override
  void initState() {
    super.initState();

    if (widget.memoryTime == "failure") {
      setState(() {
        _httpError = true;
      });
    }
    _pres.then((pres) {
      setState(() {
        if (pres.containsKey(Constants.usernameKey)) {
          _username = pres.getString(Constants.usernameKey)!;
        }
      });
    });

    // 从服务器请求需要的数据
    _typeRepository.getAllTypes().then((types) {
      _isLoading = false;
      if (types == "failure") {
        setState(() {
          _httpError = true;
        });
      } else {
        setState(() {
          _typeOfMemory = types;
          _memoryType = types[0];

          // 如果是设置文章, 则需要初始化输入框内容, 更改背景
          if (widget.addOrSet == 1) {
            _nowImagePath = "assets/icons/beijin/beijin6.jpg";
            _memoryType = widget.editMemory!.type;
            _titleController.text = widget.editMemory!.title;
            _contentController.text = widget.editMemory!.content;
          }
        });
      }
    });
  }

  /// 展示底部弹框
  void _showBottomSheet(BuildContext context) {
    //用于在底部打开弹框的效果
    showModalBottomSheet(
        builder: (context) {
          //构建弹框中的内容
          return _buildBottomSheetWidget(context);
        },
        context: context);
  }

  /// 底部弹框内容构建
  Widget _buildBottomSheetWidget(BuildContext context) {
    var selectPath;

    return StatefulBuilder(builder: (context, setBottomSheetState) {
      int indexRadio = 0;

      return Container(
        height: 330,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('取消')),
                Text('设置背景'),
                MaterialButton(
                    onPressed: () {
                      setState(() {
                        _nowImagePath = _backImagePath[selectPath];
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text('确定'))
              ],
            ),
            Container(
              height: 280,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _backImagePath.map((val) {
                  int index = indexRadio++;

                  return Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Container(
                        width: 200,
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Positioned(
                                left: 0,
                                bottom: 0,
                                right: 0,
                                top: 0,
                                child: Image.asset(
                                  val,
                                  fit: BoxFit.fill,
                                )),
                            Radio(
                                activeColor: Color(0xFF6B9FD8),
                                value: index,
                                groupValue: selectPath,
                                onChanged: (value) {
                                  selectPath = index;
                                  setBottomSheetState(() {});
                                }),
                          ],
                        ),
                      ));
                }).toList(),
              ),
            )
          ],
        ),
      );
    });
  }

  void _showDialog(String title, String content, bool isToHome) {
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
                    if (isToHome) {
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

  /// 发布或编辑日记信息
  void _addOrSetMemory() {
    String _memoryTitle = _titleController.text;
    String _memoryContent = _contentController.text;

    if (widget.addOrSet == 0) {
      // 发布文章
      _memoryStore
          .addMemory(
              _memoryTitle, _memoryContent, _memoryType!.id, widget.memoryTime)
          .then((res) {
        if (res[0] == "success") {
          // 发布成功
          _showDialog('发布成功', res[1], true);
        } else {
          // 发布失败
          _showDialog('发布失败', res[1], false);
        }
      });
    } else if (widget.addOrSet == 1) {
      // 编辑文章
      _memoryStore
          .editMemory(widget.editMemory!.id, _memoryTitle, _memoryContent,
              _memoryType!.id)
          .then((res) {
        if (res[0] == "success") {
          // 编辑成功
          _showDialog('编辑成功', res[1], true);
        } else {
          // 编辑失败
          _showDialog('编辑失败', res[1], false);
        }
      });
    }
  }

  /// 更换发布类型标记
  void _popTypeDialog(BuildContext context) {
    var title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("您好, $_username: ",
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        Text(
          "需要记录哪类有趣的事情呢？",
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
        )
      ],
    );

    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: title,
            children: _typeOfMemory.map((val) {
              return MaterialButton(
                child: Text(val.typeName),
                onPressed: () {
                  setState(() {
                    _memoryType = val;
                  });

                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          );
        });
  }

  /// 获取背景图片组件
  Widget _getBackGround() {
    return Positioned(
        left: 0,
        bottom: 0,
        right: 0,
        top: 0,
        child: Image.asset(
          _nowImagePath,
          fit: BoxFit.fill,
        ));
  }

  /// 获取输入卡片顶部组件
  Widget _getInputCardTop(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(widget.memoryTime.substring(8, 10),
              style: new TextStyle(fontSize: 30)),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.memoryTime.substring(widget.memoryTime.length - 3),
              style: new TextStyle(fontSize: 12, color: Color(0xFFA1A1A1))),
          Text(widget.memoryTime.substring(0, 8),
              style: new TextStyle(fontSize: 12, color: Color(0xFFA1A1A1)))
        ]),
        Spacer(),
        IconButton(
            onPressed: () {
              _popTypeDialog(context);
            },
            icon: Image.asset('assets/icons/sun.png', height: 30, width: 30)),
        IconButton(
            onPressed: () {
              _addOrSetMemory();
            },
            icon: Image.asset('assets/icons/send.png', height: 20, width: 20)),
      ],
    );
  }

  Widget _getTitleInputField() {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: TextField(
          maxLength: 6,
          controller: _titleController,
          decoration: InputDecoration(
              hintText: "请输入日志标题...",
              hintStyle: TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
              isCollapsed: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              enabledBorder: OutlineInputBorder(

                  ///用来配置边框的样式
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(
                    color: Color(0xFFDCDCDC),
                    width: 1.0,
                  )),
              focusedBorder: OutlineInputBorder(

                  ///用来配置边框的样式
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(
                    color: Color(0xFFB0C4DE),
                    width: 1.0,
                  ))),
        ));
  }

  /// 获取输入卡片输入框组件
  Widget _getInputField() {
    return Padding(
        padding: EdgeInsets.all(12.0),
        child: TextField(
          maxLength: 5000,
          keyboardType: TextInputType.multiline,
          controller: _contentController,
          maxLines: 14,
          style: TextStyle(
            fontSize: 12.0,
            letterSpacing: 1.0,
            height: 1.2,
          ),
          decoration: InputDecoration(
              isCollapsed: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              hintText: "这一天发生了什么有趣的事呢？",
              hintStyle: TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
              enabledBorder: OutlineInputBorder(

                  ///用来配置边框的样式
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(
                    color: Color(0xFFDCDCDC),
                    width: 1.0,
                  )),
              focusedBorder: OutlineInputBorder(

                  ///用来配置边框的样式
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(
                    color: Color(0xFFB0C4DE),
                    width: 1.0,
                  ))),
        ));
  }

  /// 获取输入卡片组件
  Widget _getInputCard() {
    return Positioned(
        left: 0,
        top: 100.0,
        right: 60.0,
        child: SingleChildScrollView(
            child: Container(
          decoration: new BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              color: Color(0xFFFFFFFF)),
          child: Column(children: [
            Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(_memoryType!.typeName,
                    style: new TextStyle(fontSize: 18))),
            _getInputCardTop(context),
            _getTitleInputField(),
            _getInputField()
          ]),
        )));
  }

  /// 渲染整个页面
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: _isLoading
            ? LoadingPage()
            : Scaffold(
                appBar: new AppBar(
                  iconTheme: IconThemeData(
                    color: Colors.black, //修改颜色
                  ),
                  backgroundColor: Colors.white,
                  centerTitle: true,
                  title: new Text(widget.addOrSet == 0 ? '发布' : '修改',
                      style: new TextStyle(color: Colors.black, fontSize: 18)),
                ),
                body: _httpError
                    ? ErrorPage("网络请求错误，请稍后再试")
                    : ConstrainedBox(
                        constraints: BoxConstraints.expand(),
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[_getBackGround(), _getInputCard()],
                        ),
                      ),
                floatingActionButton: FloatingActionButton(
                    backgroundColor: Color(0xFFFFFFFF),
                    child: ImageIcon(AssetImage('assets/icons/clothes.png'),
                        color: Colors.black),
                    onPressed: () {
                      _showBottomSheet(context);
                    }),
              ));
  }
}
