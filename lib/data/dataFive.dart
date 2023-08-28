import 'package:flutter/material.dart';
import 'package:student/data/dataOne.dart';

class ProblemStatus {
  late String problemName; //题目编号，如A，B//如果已经提交过，那么就是submitCount - lastSubmitTime
  late String status; //题目状态{firstAc,Accepted,WrongAnswer,pending,unSubmitted}
  late String submitCount; //提交次数
  late String
      lastSubmitTime; //该题的最后一次提交时间 = lastSubmitTime - contestStartTime,单位是分钟，(只有通过才有必要计算)
  ProblemStatus(
      {required this.problemName,
      required this.status,
      required this.submitCount,
      required this.lastSubmitTime});
  factory ProblemStatus.fromList(List<String> list) {
    return ProblemStatus(
        problemName: list[0],
        status: list[2],
        submitCount: list[1],
        lastSubmitTime: list[3]);
  }
}

class PlayerInfo {
  late String studentNumber;
  late String studentName;
  String rank = '1'; //排名
  late String acProblemCount; //通过的题目数量
  late String penaltyTime; //罚时，以分钟为单位，是所有通过题目罚时的总和
  late List<ProblemStatus> problemStatusList; //哪怕没提交，每道题目也应该在该List中有它的位置

  PlayerInfo({
    required this.studentNumber,
    required this.studentName,
    required this.acProblemCount,
    required this.penaltyTime,
    required this.problemStatusList,
  });

  factory PlayerInfo.fromList(List<dynamic> list, String contestStartTime) {
    //该字符串如果没有'#'应该也不会报错吧
    List<String> problemsStatus = (list[2] as String).split('#');
    //可能一次题目也没有提交过，那就是空数组
    if (list[2].toString() == 'null') {
      problemsStatus = [];
    }
    List<List<String>> arr = [];
    int acCount = 0;
    int totalTime = 0;
    for (int i = 0; i < problemsStatus.length; i++) {
      List<String> li = problemsStatus[i].split(':');
      li[3] = myConfigInfo.timeCalc(li[3], contestStartTime);
      if (li[2] == 'Accepted' || li[2] == 'firstAc') {
        acCount++;
        totalTime += int.parse(li[3]);
      }
      li[3] = (int.parse(li[3]) ~/ 60).toString();
      arr.add(li);
    }
    return PlayerInfo(
        studentNumber: list[0],
        studentName: list[1],
        acProblemCount: acCount.toString(), //这里的单位是秒，但是显示在界面上是分钟，但是比较的时候应该是秒
        penaltyTime: totalTime.toString(),
        problemStatusList: List.generate(arr.length, (index) {
          return ProblemStatus.fromList(arr[index]);
        }));
  }
}

class ProblemPassRate {
  late String problemName;
  late String totalCount;
  late String acCount;
  ProblemPassRate(
      {required this.problemName,
      required this.totalCount,
      required this.acCount});
  factory ProblemPassRate.fromList(List<dynamic> list) {
    return ProblemPassRate(
        problemName: list[0],
        totalCount: (list[1] as String).split(':')[0],
        acCount: (list[1] as String).split(':')[1]);
  }
}

class RankModel extends ChangeNotifier {
  //isRequest表示是否进行过一次成功的请求,如果进行过一次成功的请求，那么下面的成员都会被初始化
  bool isRequest = false;
  late String curStudentNumber; //当前客户端的选手学号
  late String contestStartTime; //比赛开始时间
  late List<PlayerInfo> playerList;
  late List<ProblemPassRate> passRateList;

  Future<void> requestRankInfo(
      String contestId, String studentNumber, String matchStartTime) async {
    curStudentNumber = studentNumber;
    contestStartTime = matchStartTime;
    Map request = {
      'requestType': 'requestContestInfo',
      'info': ['rank', contestId]
    };
    await dio
        .post('${myConfigInfo.getPath()}/studentJson', data: request)
        .then((value) {
      if (value.data['status'] != 'succeed') {
        return;
      }
      List<dynamic> rankList = value.data['rank'];
      playerList = List.generate(rankList.length, (index) {
        return PlayerInfo.fromList(rankList[index], contestStartTime);
      });
      playerList.sort((a, b) {
        if (int.parse(a.acProblemCount) > int.parse(b.acProblemCount)) {
          return -1; //返回负值，应该是排在前面吧
        }
        return int.parse(a.penaltyTime) - int.parse(b.penaltyTime);
      });

      for (int i = 1; i < playerList.length; i++) {
        if (playerList[i].acProblemCount == playerList[i - 1].acProblemCount &&
            playerList[i].penaltyTime == playerList[i - 1].penaltyTime) {
          playerList[i].rank = int.parse(playerList[i - 1].rank).toString();
        } else {
          playerList[i].rank =
              (int.parse(playerList[i - 1].rank) + 1).toString();
        }
      }
      //  解析并获取题目通过率
      List<dynamic> problemPassRateList = value.data['problemsRate'];
      passRateList = List.generate(problemPassRateList.length, (index) {
        //dynamic可以作为List<dynamic>的参数，应该是自动转换
        return ProblemPassRate.fromList(problemPassRateList[index]);
      });
      isRequest = true;
      notifyListeners();
    });
  }
}
