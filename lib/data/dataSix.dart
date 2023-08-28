import 'package:flutter/material.dart';

class ListTest extends ChangeNotifier {
  List<String> list = List.generate(100, (index){
    return index.toString();
  });
  List<int> dys = List.generate(100, (index){
    return index * 100;
  });
  int upLen = 0;
  void transUp(){
    upLen = 100;
    notifyListeners();
  }
}