import 'package:flutter/material.dart';
import 'package:student/data/dataOne.dart';

class OneSubmitInfo {
  late String submitTime;
  late String problemName;
  late String language;
  late String curStatus;

  OneSubmitInfo(
      {required this.submitTime,
      required this.problemName,
      required this.language,
      required this.curStatus});
  //可以试试把参数List<dynamic>换成List<String>，可以下一步到位会不会报错(有点懒，还没尝试)
  factory OneSubmitInfo.fromList(List<dynamic> list) {
    List<String> li = (list[1] as String).split(':');

    return OneSubmitInfo(
      submitTime:
          '${(list[0] as String).split(' ')[0]} ${(list[0] as String).split(' ')[1].replaceAll('-', ':')}',
      problemName: li[0],
      language: li[1],
      curStatus: li[2],
    );
  }
}

class StatusModel extends ChangeNotifier {
  bool isRequest = false;
  late List<OneSubmitInfo> submitList;
  //好像后端返回的数据就是按时间排序好的，不需要排序
  void sortFromSubmitTime() {
    submitList.sort((a, b) {
      return myConfigInfo.compareTime(a.submitTime, b.submitTime) ? 1 : -1;
    });
  }

  Future<void> requestStatusInfo(
      String contestName, String studentNumber) async {
    Map request = {
      'requestType': 'requestContestInfo',
      'info': ['status', contestName, studentNumber],
    };
    await dio
        .post('${myConfigInfo.getPath()}/studentJson', data: request)
        .then((value) {
      if (value.data['status'] == 'succeed') {
        List<dynamic> list = value.data['allSubmit'];
        submitList = List.generate(list.length, (index) {
          //不懂dynamic -> List<dynamic>行不行
          return OneSubmitInfo.fromList(list[index] as List<dynamic>);
        });

        isRequest = true;
        //如果数据没有渲染到界面上，可能是notifyListeners写再then回调函数里面的问题
        notifyListeners();
      }
    });
  }

  static Color switchColor(String status) {
    if (status == 'Accepted') {
      return Colors.greenAccent;
    } else if (status == 'firstAc') {
      return Colors.green;
    } else if (status == 'pending') {
      return Colors.yellowAccent;
    }
    return Colors.red;
  }
}

class OneMessage {
  late String messageId;
  late String senderType;
  late String senderName; //managerName or studentNumber
  late String text;
  late String sendTime;
  OneMessage(
      {required this.messageId,
      required this.senderType,
      required this.senderName,
      required this.text,
      required this.sendTime});
  factory OneMessage.fromList(List<dynamic> list) {
    return OneMessage(
        messageId: list[0],
        senderType: list[1],
        senderName: list[2],
        text: list[3],
        sendTime: list[4]);
  }
}

class MessageModel extends ChangeNotifier {
  //当没有数据的时候可能显示正在加载可能会好一点，当我们定时去请求数据的时候，
  // 可以等到所有数据都加载完再去notifyListeners,
  //请求应该是自动完成的，也就是我们可以弄一个总的循环定时器，其实没有必要弄isRequest这个变量
  //也就是说选手不能获取数据，只能被动地通过程序来获取
  // bool isRequest = false;
  // 还是先初始化好了，因为选手也是可以发送数据的，到时候还没有请求数据，
  // messageList也就没有初始化成功，将数据插入会引发未初始化报错
  late List<OneMessage> messageList = [];
// 由于后端数据的更新是有滞后性的，所以可能会出现执行下面的函数后，得到的数据比原来的数据还要少
  Future<void> requestContestNews(
      String contestId, String studentNumber) async {
    Map request = {
      'requestType': 'requestContestInfo',
      'info': ['news', contestId]
    };

    await dio
        .post('${myConfigInfo.getPath()}/studentJson', data: request)
        .then((value) {
      if (value.data['status'] != 'succeed') {
        return;
      }
      List<dynamic> list = value.data['news'];
      messageList.clear();
      for (int i = 0; i < list.length; i++) {
        //因为List<String>是List<dynamic>的子类型？所以可以将list放在参数类型是List<dynamic>的位置 ? ? ?
        messageList.add(OneMessage.fromList(list[i] as List<dynamic>));
      }
      messageList.removeWhere((element) {
        if (element.senderType == 'manager' ||
            (element.senderType == 'user' &&
                element.senderName == studentNumber)) {
          return false;
        }
        return true;
      });
      notifyListeners();
    });
  }

  Future<bool> insertSelfMessage(
      String userOneMessage, String contestName, String studentNumber) async {
    String curTime = myConfigInfo.getCurTime(':');
    Map request = {
      'requestType': 'macroRequest',
      'info': [
        'userMessage',
        contestName,
        studentNumber,
        userOneMessage,
        curTime
      ]
    };
    bool flag = await dio
        .post('${myConfigInfo.getPath()}/studentJson', data: request)
        .then((value) {
      return value.data['status'] == 'succeed';
    });
    if (flag) {
      messageList.add(OneMessage(
          messageId: '',
          senderType: 'user',
          senderName: '',
          text: userOneMessage,
          sendTime: curTime));
      notifyListeners();
    }
    return flag;
  }
}
