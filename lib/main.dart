import 'package:flutter/material.dart';
import 'package:memory/view/loginpage.dart';

void main() => runApp(SimpleMemory());

class SimpleMemory extends StatefulWidget {
  SimpleMemory({Key? key}) : super(key: key);

  @override
  _SimpleMemoryState createState() => new _SimpleMemoryState();
}

class _SimpleMemoryState extends State<SimpleMemory> {
  // UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '简忆',
      home: new LoginPage(),
    );
  }
}
