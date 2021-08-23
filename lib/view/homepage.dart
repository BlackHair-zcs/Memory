import 'package:flutter/material.dart';
import 'package:memory/utils/api_client.dart';
import 'package:memory/view/addorsetpage.dart';
import 'package:memory/view/memorypage.dart';
import 'package:memory/view/mypage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // 初始化成员变量
  final APIClient _apiClient = APIClient();

  AnimationController? _animationController;
  Animation<double>? _iconAnimation;

  final List<Widget> _pages = [MemoryPage(), MyPage()];
  final List<String> _unSelectIcon = [
    'assets/icons/home.png',
    'assets/icons/user.png'
  ];
  final List<String> _selectIcon = [
    'assets/icons/home_active.png',
    'assets/icons/user_active.png'
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // 定义动画控制器
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _iconAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.3)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(_animationController!);
  }

  // 改变页面路由
  void _chengPage(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  // 构建动画执行事件
  void _clickIcon() {
    if (_iconAnimation?.status == AnimationStatus.forward ||
        _iconAnimation?.status == AnimationStatus.reverse) {
      return;
    }

    if (_iconAnimation?.status == AnimationStatus.dismissed) {
      _animationController?.forward();
    } else if (_iconAnimation?.status == AnimationStatus.completed) {
      _animationController?.reverse();
    }
  }

  // 构建点击动画tabbar组件
  Widget _getBarItem(int index) {
    if (index == _currentIndex) {
      return ScaleTransition(
          scale: _iconAnimation!,
          child: IconButton(
              onPressed: () {
                _chengPage(index);
                _clickIcon();
              },
              icon: Image.asset(_selectIcon[index], height: 45, width: 45)));
    } else {
      return IconButton(
          onPressed: () {
            _chengPage(index);
            _clickIcon();
          },
          icon: Image.asset(_unSelectIcon[index], height: 45, width: 45));
    }
  }

  // 渲染整个页面
  @override
  Widget build(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width / 3;

    return new Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // 添加按钮
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF000000),
        child: Icon(Icons.add),
        onPressed: () {
          // 从服务器获取当前时间
          _apiClient.getNowTime().then((time) {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddOrSetPage(0, time)));
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // 设置TabBar
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(height: 45, width: itemWidth, child: _getBarItem(0)),
            SizedBox(
              height: 60,
              width: itemWidth,
            ),
            SizedBox(height: 45, width: itemWidth, child: _getBarItem(1))
          ],
        ),
      ),
    );
  }

  // 释放动画控制器
  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
  }
}
