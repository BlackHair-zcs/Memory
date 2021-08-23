import 'package:flutter/cupertino.dart';
import 'package:memory/utils/api_client.dart';
import 'package:memory/utils/cache_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memory/utils/sharedpre_extension.dart';

class UserModel {
  // 用户名
  String name;

  // 用户的账号
  String account;

  // 用户的头像地址
  String avatar;

  UserModel({@required name, @required account, @required avatar})
      : this.name = name,
        this.account = account,
        this.avatar = avatar;

  UserModel.fromJson(Map<String, dynamic> json)
      : this.name = json['name'],
        this.account = json['account'],
        this.avatar = json['avatar'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['account'] = this.account;
    data['avatar'] = this.avatar;

    return data;
  }
}

class UserRepository {
  final APIClient apiClient = APIClient();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // 用户注册
  signup(String username, String account, String password,
      String repassword) async {
    try {
      var result =
          await apiClient.signup(username, account, password, repassword);

      return [result['status'], result['result']['message']['info']];
    } catch (e) {
      return ['failure', '网络连接错误'];
    }
  }

  // 用户登录
  signin(String account, String password) async {
    try {
      var result = await apiClient.signin(account, password);

      return [
        result['status'],
        result['result']['message']['info'],
        result['result']['message']['info']
      ];
    } catch (e) {
      return ['failure', '网络连接错误'];
    }
  }

  // 用户退出登录
  signout() async {
    var prefs = await _prefs;

    prefs.remove(Constants.token);
  }

  // 修改用户密码
  changePassword(String account, String password, String repassword) async {
    try {
      var result =
          await apiClient.changePassword(account, password, repassword);

      return [
        result['status'],
        result['result']['message']['info'],
      ];
    } catch (e) {
      return ['failure', '网络连接错误'];
    }
  }

  // 获取用户信息，网络异常时，返回缓存信息
  getUserByAccount(String account) async {
    var user;
    var prefs = await _prefs;

    try {
      user = await apiClient.getUserByAccount(account);
      if (user != "failure") {
        prefs.setJson(Constants.keyUserInfo, user.toJson());
      }
      return user;
    } catch (e) {
      if (prefs.containsKey(Constants.keyUserInfo))
        return UserModel.fromJson(prefs.getJson(Constants.keyUserInfo));
      return "failure";
    }
  }
}
