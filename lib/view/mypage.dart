import 'package:flutter/material.dart';
import 'package:memory/model/user.dart';
import 'package:memory/utils/cache_data.dart';
import 'package:memory/view/aboutpage.dart';
import 'package:memory/view/authorpage.dart';
import 'package:memory/view/changepwpage.dart';
import 'package:memory/view/errorpage.dart';
import 'package:memory/view/loadingpage.dart';
import 'package:memory/view/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPage extends StatefulWidget {
  MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => new _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final UserRepository _userRepository = UserRepository();
  final Future<SharedPreferences> _pres = SharedPreferences.getInstance();
  final String _protocal = "http://";
  final String _host = "47.98.175.209:8080";
  UserModel? _userInfo;
  bool _isLoading = true;
  bool _httpError = false;

  @override
  void initState() {
    super.initState();

    _pres.then((pres) {
      if (pres.containsKey(Constants.accountKey)) {
        _userRepository
            .getUserByAccount(pres.getString(Constants.accountKey)!)
            .then((user) {
          _isLoading = false;
          if (user == 'failure') {
            setState(() {
              _httpError = true;
            });
          } else {
            setState(() {
              _userInfo = user;
            });
          }
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
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text('确定')),
            ],
          );
        });
  }

  /// 构建菜单列表组件
  Widget _buildMenu() {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.change_circle),
          title: Text('修改密码'),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ChangePWPage()));
          },
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('简忆介绍'),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AboutPage()));
          },
        ),
        ListTile(
          leading: Icon(Icons.send),
          title: Text('联系作者'),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AuthorPage()));
          },
        ),
        ListTile(
          leading: Icon(Icons.backspace),
          title: Text('退出'),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            _userRepository.signout();
            _showDialog("退出成功", "期待下次与您见面");
          },
        ),
      ],
    );
  }

  Widget _buildPage() {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              child: Image.asset("assets/icons/mybeijin/beijin1.jpg",
                  fit: BoxFit.fill),
            ),
            Expanded(
              child: Container(
                child: _buildMenu(),
              ),
            )
          ],
        ),
        Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(height: 120),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(
                            _protocal + _host + '/' + _userInfo!.avatar),
                        fit: BoxFit.fill),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    _userInfo!.name,
                    style: TextStyle(fontSize: 18),
                  ),
                )
              ],
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingPage()
        : Scaffold(
            appBar: new AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              title: new Text('我的',
                  style: new TextStyle(color: Colors.black, fontSize: 18)),
            ),
            body: Container(
              child: _httpError ? ErrorPage("网络请求错误，请稍后再试") : _buildPage(),
            ));
  }
}
