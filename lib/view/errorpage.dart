import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  String _hintText;

  ErrorPage(this._hintText);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(_hintText),
      ),
    );
  }
}
