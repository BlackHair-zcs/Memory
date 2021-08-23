import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memory/model/memory.dart';
import 'package:memory/utils/api_client.dart';
import 'package:memory/view/detailpage.dart';
import 'package:memory/view/errorpage.dart';

class TimePage extends StatefulWidget {
  TimePage({Key? key}) : super(key: key);

  @override
  _TimePageState createState() => new _TimePageState();
}

class _TimePageState extends State<TimePage> {
  // 创建 黑色的 MaterialColor
  final MaterialColor _black = const MaterialColor(
    0xFF000000,
    const <int, Color>{
      50: const Color(0xFF000000),
      100: const Color(0xFF000000),
      200: const Color(0xFF000000),
      300: const Color(0xFF000000),
      400: const Color(0xFF000000),
      500: const Color(0xFF000000),
      600: const Color(0xFF000000),
      700: const Color(0xFF000000),
      800: const Color(0xFF000000),
      900: const Color(0xFF000000),
    },
  );

  final MemoryStore _memoryStore = MemoryStore();
  final APIClient _apiClient = APIClient();

  bool _isLoading = true;
  bool _httpError = false;

  // 当前选中时间
  DateTime _selectedDate = DateTime(2021, 8, 1);

  // 日记数据
  List _memoryData = [];

  String dateTimeToString(DateTime dateTime) {
    return DateFormat('yyyy年MM月dd日').format(dateTime);
  }

  DateTime stringToDateTime(String time) {
    int year = int.parse(time.substring(0, 4));
    int month = int.parse(time.substring(5, 7));
    int day = int.parse(time.substring(8, 10));

    return DateTime(year, month, day);
  }

  @override
  void initState() {
    super.initState();

    // 从服务器获取时间
    _apiClient.getNowTime().then((time) {
      if (time == "failure") {
        _isLoading = false;
        setState(() {
          _httpError = true;
        });
      } else {
        time = time.substring(0, 11);

        // 从服务器获取日记数据
        _memoryStore.getMemoryByTime(time).then((posts) {
          _isLoading = false;
          if (posts == "failure") {
            setState(() {
              _httpError = true;
            });
          } else {
            setState(() {
              _memoryData = posts;
            });

            setState(() {
              _selectedDate = stringToDateTime(time);
            });
          }
        });
      }
    });
  }

  Widget _buildMemoryItem(String date, String content, String memoryId) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => DetailPage(memoryId)));
        },
        child: Container(
          decoration: BoxDecoration(color: Color(0xFFFFFFFF)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(children: [
                  Text(date.substring(8, 10),
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.w600)),
                  Padding(
                      padding: EdgeInsets.only(bottom: 2.0),
                      child: Text(date.substring(date.length - 3),
                          style: TextStyle(fontSize: 12.0))),
                  Text(date.substring(12, 17),
                      style:
                          TextStyle(fontSize: 12.0, color: Color(0xFFADADAD)))
                ]),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 1,
                height: 60,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black),
                ),
              ),
            ),
            // 日记内容
            Expanded(
              child: Container(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 复刻时间数据，防止选中时间和最后时间等同步改变
    DateTime _lastDate = _selectedDate;
    DateTime _initialtDate = _selectedDate;
    DateTime _firstDate = _selectedDate.subtract(Duration(days: 180));
    DateTime _currentDate = _selectedDate;

    return _isLoading
        ? ErrorPage("正在加载，请稍后")
        : _httpError
            ? ErrorPage("网络请求错误，请稍后再试")
            : Container(
                decoration: BoxDecoration(color: Color(0xF5F5F5)),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          height: 260,
                          child: Theme(
                            data: ThemeData(primarySwatch: _black),
                            child: CalendarDatePicker(
                              currentDate: _currentDate,
                              onDateChanged: (date) {
                                setState(() {
                                  _currentDate = date;
                                });
                                // 从服务器获取日记数据
                                _memoryStore
                                    .getMemoryByTime(dateTimeToString(date))
                                    .then((posts) {
                                  if (posts.runtimeType == String) {
                                    setState(() {
                                      _httpError = true;
                                    });
                                  } else {
                                    setState(() {
                                      _memoryData = posts;
                                    });
                                  }
                                });
                              },
                              initialDate: _initialtDate,
                              firstDate: _firstDate,
                              lastDate: _lastDate,
                            ),
                          )),
                      SizedBox(width: double.infinity, height: 15.0),
                      Container(
                        height: 220,
                        child: ListView(
                          children: _memoryData
                              .map((val) => _buildMemoryItem(
                                  val.createDate, val.content, val.id))
                              .toList(),
                        ),
                      )
                    ],
                  ),
                ));
  }
}
