import 'package:flutter/material.dart';
import 'package:student/data/dataOne.dart';

class BodyModel extends ChangeNotifier {
  bool isLoginSucceed = false;
  late String studentNumber;// = '2007310431';
  late String studentName;// = '李弃权';
  late String contestId;// = '1';
  late String contestName;// = '广西大学第一届校赛';
  int curButtonId = 0;

  void switchLoginStatus() {
    isLoginSucceed = true;
    notifyListeners();
  }

  void switchButtonId(int id) {
    if (curButtonId != id) {
      curButtonId = id;
      notifyListeners();
    }
  }

  //通过login来获取信息，不一定要通过构造函数来获取
  //2007310431,123456,127.0.0.1:5051#1
  Future<bool> login(
      String _studentNumber, String password, String contestUrl) async {
    List<String> parts = contestUrl.split('#');
    Map request = {
      'requestType': 'login',
      'info': [
        parts[1],
        _studentNumber,
        password,
        myConfigInfo.getCurTime(':')
      ],
    };
    myConfigInfo.setPath(parts[0]);
    contestId = parts[1];
    studentNumber = _studentNumber;
    bool flag = await dio
        .post('${myConfigInfo.getPath()}/studentJson', data: request)
        .then((value) {
      if (value.data['status'] != 'succeed') {
        return false;
      }
      contestName = value.data['contestName'];
      studentName = value.data['studentName'];
      return true;
    });
    if (flag) {
      //在这一次请求之前，还没有组件依赖该数据，所以这里不用notifyListeners
      switchLoginStatus();
      myConfigInfo.setHostUserName();
      MyBus.emit('intervalTimers');
    }
    return flag;
  }
}
