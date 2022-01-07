import 'package:dio/dio.dart';
import 'package:memory/model/memory.dart';
import 'package:memory/model/type.dart';
import 'package:memory/model/user.dart';
import 'package:memory/utils/cache_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APIClient {
  final String protocal = "http://";
  final String host = "120.26.166.10:8000";
  final String signinRouter = "/signin";
  final String signupRouter = "/signup";
  final String usersRouter = "/users";
  final String postsRouter = "/posts";
  final String typesRouter = "/types";
  final String timesRouter = "/times";
  final Future<SharedPreferences> _pres = SharedPreferences.getInstance();
  get dio async {
    final pres = await _pres;
    var dio = new Dio();

    dio.options.connectTimeout = 2000;
    dio.options.baseUrl = protocal + host;

    if (pres.containsKey(Constants.token)) {
      dio.options.headers['authorization'] = pres.getString(Constants.token);
    }

    return dio;
  }

  // 用户注册
  signup(String username, String account, String password,
      String repassword) async {
    var dioCopy = await dio;

    try {
      Response response = await dioCopy.post(signupRouter, data: {
        'name': username,
        'account': account,
        'password': password,
        'repassword': repassword
      });

      return response.data;
    } catch (e) {
      throw StateError('网络连接出错');
    }
  }

  // 用户登录
  signin(String account, String password) async {
    var dioCopy = await dio;

    try {
      Response response = await dioCopy
          .post(signinRouter, data: {'account': account, 'password': password});

      return response.data;
    } catch (e) {
      throw StateError('网络连接出错');
    }
  }

  // 修改用户密码
  changePassword(String account, String password, String repassword) async {
    var dioCopy = await dio;

    try {
      Response response = await dioCopy.post(usersRouter + "/changepw", data: {
        'account': account,
        'password': password,
        'repassword': repassword
      });

      return response.data;
    } catch (e) {
      throw StateError('网络连接出错');
    }
  }

  // 通过 account 获取用户信息
  getUserByAccount(String account) async {
    var dioCopy = await dio;

    try {
      Response response = await dioCopy.get(usersRouter + "/" + account);

      if (response.data['status'] == 'success') {
        return UserModel.fromJson(response.data['result']['message']['info']);
      } else {
        return 'failure';
      }
    } catch (e) {
      throw StateError('网络连接出错');
    }
  }

  // 发布一篇日记
  addMemory(
      String title, String content, String typeId, String createDate) async {
    var dioCopy = await dio;

    try {
      Response response = await dioCopy.post(postsRouter + "/create", data: {
        'title': title,
        'content': content,
        'typeId': typeId,
        'createDate': createDate
      });

      return response.data;
    } catch (e) {
      throw StateError('网络连接出错');
    }
  }

  // 删除日记
  removeMemory(String postId) async {
    var dioCopy = await dio;

    try {
      Response response =
          await dioCopy.get(postsRouter + "/" + postId + "/remove");

      return response.data;
    } catch (e) {
      throw StateError('网络连接出错');
    }
  }

  // 修改日记
  editMemory(String postId, String title, String content, String typeId) async {
    var dioCopy = await dio;

    try {
      Response response = await dioCopy.post(
          postsRouter + "/" + postId + "/edit",
          data: {'title': title, 'content': content, 'typeId': typeId});

      return response.data;
    } catch (e) {
      throw StateError('网络连接出错');
    }
  }

  // 通过 Id 获取某一篇日记内容
  getMemoryByMemoryId(String postId) async {
    var dioCopy = await dio;

    try {
      Response response = await dioCopy.get(postsRouter + '/' + postId);

      if (response.data['status'] == "success") {
        response.data['result']['message']['info']['type'] = TypeModel.fromJson(
            response.data['result']['message']['info']['type']);
        return MemoryModel.fromJson(response.data['result']['message']['info']);
      } else {
        return "failure";
      }
    } catch (e) {
      throw StateError('网络连接出错');
    }
  }

  // 通过 typeId 获取每一类型的所有日记
  getMemoryByTypeId(String typeId) async {
    var dioCopy = await dio;

    try {
      Response response = await dioCopy.get(typesRouter + '/' + typeId);

      if (response.data['status'] == "success") {
        List posts = response.data['result']['message']['info'].map((item) {
          item['type'] = TypeModel.fromJson(item['type']);
          return MemoryModel.fromJson(item);
        }).toList();

        return posts;
      } else {
        return "failure";
      }
    } catch (e) {
      throw StateError('网络连接出错');
    }
  }

  // 通过 time 获取某一天的所有日记
  getMemoryByTime(String time) async {
    var dioCopy = await dio;

    try {
      Response response =
          await dioCopy.post(timesRouter + '/memory', data: {'time': time});

      // print(time);
      // print(response.data);
      if (response.data['status'] == 'success') {
        List posts = response.data['result']['message']['info'].map((item) {
          item['type'] = TypeModel.fromJson(item['type']);
          return MemoryModel.fromJson(item);
        }).toList();

        return posts;
      } else {
        return "failure";
      }
    } catch (e) {
      throw StateError('网络连接出错');
    }
  }

  // 获取所有的日记种类
  getAllTypes() async {
    var dioCopy = await dio;

    try {
      Response response = await dioCopy.get(typesRouter + '/alltype');

      if (response.data['status'] == 'success') {
        return response.data['result']['message']['info'].map((item) {
          return TypeModel.fromJson(item);
        }).toList();
      } else {
        return "failure";
      }
    } catch (e) {
      throw StateError('网络连接出错');
    }
  }

  // 获取当前的时间
  getNowTime() async {
    var dioCopy = await dio;

    try {
      Response response = await dioCopy.get(timesRouter + '/now');

      if (response.data['status'] == "success") {
        return response.data['result']['message']['info'];
      } else {
        return "failure";
      }
    } catch (e) {
      return "failure";
    }
  }
}
