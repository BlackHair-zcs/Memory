import 'package:flutter/cupertino.dart';
import 'package:memory/utils/api_client.dart';
import 'package:memory/utils/cache_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memory/utils/sharedpre_extension.dart';

class TypeModel {
  // 类型 id
  String id;

  // 类型名称
  String typeName;

  // 类型背景图片 URL
  String backImgURL;

  // 类型构造函数
  TypeModel({@required id, @required typeName, @required backImgURL})
      : this.id = id,
        this.typeName = typeName,
        this.backImgURL = backImgURL;

  TypeModel.fromJson(Map<String, dynamic> json)
      : this.id = json['_id'],
        this.typeName = json['typeName'],
        this.backImgURL = json['backImgURL'];

  // 将实例转换为 json 格式
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['typeName'] = this.typeName;
    data['backImgURL'] = this.backImgURL;

    return data;
  }
}

class TypeRepository {
  final APIClient apiClient = APIClient();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // 获取所有的种类信息，网络异常时，返回缓存信息
  getAllTypes() async {
    var type;
    List<dynamic> jsonList;
    var pref = await _prefs;

    try {
      type = await apiClient.getAllTypes();

      if (type != "failure") {
        jsonList = type.map((date) => date.toJson()).toList();
        pref.setJsonList(Constants.keyTypeInfo, jsonList);
      }

      return type;
    } catch (e) {
      if (pref.containsKey(Constants.keyTypeInfo)) {
        jsonList = pref.getJsonList(Constants.keyTypeInfo);
        return jsonList.map((item) {
          return TypeModel.fromJson(item);
        }).toList();
      }
      return "failure";
    }
  }
}
