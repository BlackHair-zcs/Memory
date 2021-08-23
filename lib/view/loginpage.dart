import 'package:flutter/material.dart';
import 'package:memory/model/user.dart';
import 'package:memory/utils/cache_data.dart';
import 'package:memory/view/changepwpage.dart';
import 'package:memory/view/homepage.dart';
import 'package:memory/view/registrationpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoginContent(),
    );
  }
}

class LoginContent extends StatefulWidget {
  @override
  _LoginContentState createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  UserRepository _userRepository = UserRepository();
  String _account = '';
  String _password = '';

  bool _enable = false;
  bool _obscureText = true;

  final accountEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    _prefs.then((pres) {
      if (pres.containsKey(Constants.accountKey) &&
          pres.containsKey(Constants.passwordKey)) {
        _account = pres.getString(Constants.accountKey).toString();
        _password = pres.getString(Constants.passwordKey).toString();
      }

      accountEditingController.text = _account;
      passwordEditingController.text = _password;
      _checkLoginState();
    });
    super.initState();
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

  // 登录事件
  void _clickEvent() async {
    _userRepository.signin(this._account, this._password).then((res) async {
      if (res[0] == "success") {
        final pres = await _prefs;
        pres.setString(Constants.accountKey, accountEditingController.text);
        pres.setString(Constants.passwordKey, passwordEditingController.text);
        await pres.setString(Constants.usernameKey, res[2]['name']);
        await pres.setString(Constants.token, res[2]['token']);

        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ));
      } else {
        _showDialog('登录失败', res[1]);
      }
    });
  }

  // 检测按钮是否可用
  void _checkLoginState() {
    setState(() {
      if (this._account != "" && this._password != "")
        this._enable = true;
      else
        this._enable = false;
    });
  }

  // Logo图片
  Widget _imageWidget() {
    return Container(
      child: Image.asset(
        "assets/icons/logo.png",
        height: 120,
      ),
    );
  }

  // 欢迎文字
  Widget _textWidget() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        "想你所想，写你所写",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13.0,
        ),
      ),
    );
  }

  //
  // 账号输入框
  Widget _accountTextField() {
    return Padding(
      padding: EdgeInsets.only(top: 36.0),
      child: TextField(
        controller: accountEditingController,
        decoration: InputDecoration(
          hintText: "请输入您的账号",
          suffixIcon: IconButton(
            icon: Image.asset("assets/icons/yonghu.png",
                height: 18.0, width: 18.0),
            onPressed: () {},
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: Color(0xFF000000),
            width: 1.0,
          )),
        ),
        onChanged: (value) {
          this._account = value;
          _checkLoginState();
        },
      ),
    );
  }

  // 密码输入框
  Widget _passwordTextField() {
    return Padding(
      padding: EdgeInsets.only(top: 12.0),
      child: TextField(
        controller: passwordEditingController,
        decoration: InputDecoration(
            hintText: "请输入您的密码",
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
              color: Color(0xFF000000),
              width: 1.0,
            )),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  this._obscureText = !this._obscureText;
                });
              },
              icon: Image.asset(
                this._obscureText
                    ? "assets/icons/closeEye.png"
                    : "assets/icons/openEye.png",
                width: 20.0,
                height: 20.0,
              ),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            )),
        obscureText: this._obscureText,
        onChanged: (value) {
          this._password = value;
          _checkLoginState();
        },
      ),
    );
  }

  // 登录按钮
  Widget _loginButton() {
    return Row(
      children: [
        Expanded(
          child: RaisedButton(
            child: Text("登录"),
            color: Color(0xFF000000),
            disabledColor: Colors.black26,
            textColor: Colors.white,
            disabledTextColor: Colors.black38,
            onPressed: this._enable ? _clickEvent : null,
          ),
        )
      ],
    );
  }

  // 注册提示文字
  Widget _registerText() {
    return Padding(
      padding: EdgeInsets.only(top: 5.0),
      child: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrationPage(),
                  ));
            },
            child: Text(
              "新用户？点击注册",
              style: TextStyle(
                  fontSize: 12.0,
                  color: Color(0xFFADADAD),
                  fontStyle: FontStyle.italic),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePWPage(),
                  ));
            },
            child: Text(
              "忘记密码",
              style: TextStyle(
                  fontSize: 12.0,
                  color: Color(0xFFADADAD),
                  fontStyle: FontStyle.italic),
            ),
          )
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Padding(
          padding: EdgeInsets.only(top: 80.0, left: 24.0, right: 24.0),
          child: Container(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _imageWidget(),
                _textWidget(),
                _accountTextField(),
                _passwordTextField(),
                SizedBox(
                  height: 12.0,
                ),
                _loginButton(),
                _registerText()
              ],
            ),
          )),
        ));
  }
}
