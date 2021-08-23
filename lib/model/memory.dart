import 'package:flutter/cupertino.dart';
import 'package:memory/model/type.dart';
import 'package:memory/utils/api_client.dart';

class MemoryModel {
  // 日记id
  String id;

  // 日记标题
  String title;

  // 日记内容
  String content;

  // 日记类型
  TypeModel type;

  // 日记上传时间
  String createDate;

  MemoryModel(
      {@required id,
      @required title,
      @required content,
      @required createDate,
      @required type})
      : this.id = id,
        this.title = title,
        this.content = content,
        this.type = type,
        this.createDate = createDate;
  MemoryModel.fromJson(Map<String, dynamic> json)
      : this.id = json['_id'],
        this.title = json['title'],
        this.content = json['content'],
        this.type = json['type'],
        this.createDate = json['createDate'];
}

abstract class Stroe {
  // 发布一篇日记
  addMemory(
      String title, String content, String typeId, String createDate) async {}

  // 删除日记
  removeMemory(String postId) async {}

  // 修改日记
  editMemory(
      String postId, String title, String content, String typeId) async {}

  // 通过 Id 获取某一篇日记内容
  getMemoryByMemoryId(String postId) async {}

  // 通过 typeId 获取每一类型的所有日记
  getMemoryByTypeId(String typeId) async {}

  // 通过 time 获取某一天的所有日记
  getMemoryByTime(String time) async {}
}

class MemoryStore extends Stroe {
  final APIClient apiClient = APIClient();

  @override
  addMemory(
      String title, String content, String typeId, String createDate) async {
    try {
      var result =
          await apiClient.addMemory(title, content, typeId, createDate);

      return [result['status'], result['result']['message']['type']];
    } catch (e) {
      return ['failure', '网络连接错误'];
    }
  }

  @override
  removeMemory(String postId) async {
    try {
      var result = await apiClient.removeMemory(postId);

      return [result['status'], result['result']['message']['info']];
    } catch (e) {
      return ['failure', '网络连接错误'];
    }
  }

  @override
  editMemory(String postId, String title, String content, String typeId) async {
    try {
      var result = await apiClient.editMemory(postId, title, content, typeId);

      return [result['status'], result['result']['message']['info']];
    } catch (e) {
      return ['failure', '网络连接错误'];
    }
  }

  @override
  getMemoryByMemoryId(String postId) async {
    try {
      var result = await apiClient.getMemoryByMemoryId(postId);

      return result;
    } catch (e) {
      return 'failure';
    }
  }

  @override
  getMemoryByTime(String time) async {
    try {
      var result = await apiClient.getMemoryByTime(time);

      return result;
    } catch (e) {
      return 'failure';
    }
  }

  @override
  getMemoryByTypeId(String typeId) async {
    try {
      var result = await apiClient.getMemoryByTypeId(typeId);

      return result;
    } catch (e) {
      return 'failure';
    }
  }
}
