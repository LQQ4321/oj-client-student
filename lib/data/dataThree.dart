import 'dart:io';

import 'package:flutter/material.dart';
import 'package:student/data/dataOne.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class HomeModel extends ChangeNotifier {
  bool isRequest = false;
  late String startTime = '2023-08-21 10:51:00';
  late String endTime = '2023-09-22 10:51:00';
  Future<bool> getContestTime(String contestId) async {
    if (isRequest) {
      return true;
    }
    Map request = {
      'requestType': 'macroRequest',
      'info': ['contestTime', contestId]
    };
    bool flag = await dio
        .post('${myConfigInfo.getPath()}/studentJson', data: request)
        .then((value) {
      if (value.data['status'] != 'succeed') {
        return false;
      }
      //这里多加了一个类型转换
      List<dynamic> list = value.data['contestTime'];
      startTime = list[0];
      endTime = list[1];
      return true;
    });
    if (flag) {
      isRequest = true;
      notifyListeners();
      debugPrint('$startTime-$endTime');
    }
    return flag;
  }
}

class Problem {
  //题目在problems数据表中的id
  late String problemId;
  late String problemName;
  late String problemPdf;
  late String time;
  late String memory;
  late String maxSubmitFileSize;
  late List<String> exampleList;

  Problem(
      {required this.problemId,
      required this.problemName,
      required this.problemPdf,
      required this.time,
      required this.memory,
      required this.maxSubmitFileSize,
      required this.exampleList});

  factory Problem.fromList(List<dynamic> list) {
    return Problem(
        problemId: list[0],
        problemName: list[1],
        time: list[2],
        memory: list[3],
        maxSubmitFileSize: list[4],
        problemPdf: list[5],
        exampleList: list[6].toString() == "null"
            ? []
            : (list[6] as String) //强制类型转换dynamic -> String
                .split(':')); //不懂这样有没有初始化成功，还是一定要List.generate来初始化
  }
}

//不一定要在ChangeNotifierProvider之前就准备好所有的数据，可以等到需要数据来构建界面的时候再请求,
// 不过这样好像就没有缓存了,不过我们可以把该数据放在widget树中较高的位置，这样重新构建的次数就会减少，
//或者只构建一次,不过如果一个页面是新的页面(一个route)，那可能每次打开都要重新构建了
class ProblemsModel extends ChangeNotifier {
  //false表示还没有请求过数据,我们可以定期将该值设为false，然后就可以定期更新数据了
  bool isRequest = false;
  //直接给一个[]好像也算是完成初始化了，只不过该List是空的而已
  late List<Problem> problemList = [];
  String contestName = '广西大学第一届校赛';
  int curProblemId = 0; //-1; //这里是假设至少有一道题目

  void switchProblemId(int id) {
    if (curProblemId != id) {
      curProblemId = id;
      notifyListeners();
    }
  }
  //返回的是一个初始化了的List
  List<String> getProblemNameList(){
    List<String> list = [];
    for (var element in problemList) {
      list.add(element.problemName);
    }
    return list;
  }

  //还有一个点就是如果请求到了数据，直接无脑地将新数据数据全部重新赋值到成员上，
//  那么如果用户原本就在更新的界面，那么会不会有影响
  Future<bool> requestProblemsData(String _contestName) async {
    Map request = {
      'requestType': 'requestContestInfo',
      'info': ['contest', _contestName],
    };
    bool flag = await dio
        .post('${myConfigInfo.getPath()}/studentJson', data: request)
        .then((value) {
      if (value.data['status'] != 'succeed') {
        return false;
      }
      //数据解析过程
      //value.data.['problems'](dynamic) -> List<dynamic> problems
      //problems[0](dynamic) -> List<dynamic> list
      //list[0](dynamic) -> String
      List<dynamic> problems =
          value.data['problems']; //后端传过来的只是一个二维数组，所以第二维应该是一个dynamic
      // debugPrint(problems.toString());
      problemList = List.generate(problems.length, (index) {
        return Problem.fromList(problems[index]);
      });
      // debugPrint(problemList[0].exampleList.toString());
      // debugPrint(problemList[0].exampleList.length.toString());
      // return false;
      if (problemList.isEmpty) {
        contestName = _contestName;
        curProblemId = -1;
      }
      return true;
    });
    //将isRequest的值设为true，表示关于题目的数据已经请求成功，然后可以将没有数据的提示页面换成对应的页面
    if (flag) {
      isRequest = true;
      notifyListeners();
    }
    //由于该函数只调用一次，该函数调用之前，没有组件依赖它的数据，所以没有使用notifyListeners()的必要
    return flag;
  }

  //{1,pdf},{1,in,1},{1,out,1}
  Future<bool> downloadProblemFiles(int index, String option,
      {String exampleId = "0"}) async {
    String filePath = problemList[index].problemName;
    if (option == 'pdf') {
      filePath += '.pdf';
    } else {
      filePath += '$option$exampleId.txt';
    }
    //如果存在文件名以filePath结尾，那么就不用再下载了,打开其所在的文件夹即可
    if (await myConfigInfo.isExistFile(
        myConfigInfo.downloadFilePath, filePath)) {
      myConfigInfo.openFolder(myConfigInfo.downloadFilePath);
      return true;
    }

    Map request = {
      'requestType': 'downloadContestFiles',
      'info': [contestName, problemList[index].problemName, option]
    };
    if (option != "pdf") {
      //这里request的值类型无法得知，不知道是否要强转,好像不用
      request['info'].add(exampleId);
    }
    bool flag = false;
    try {
      Response response = await dio.post(
          '${myConfigInfo.getPath()}/studentJson',
          data: request,
          options: Options(responseType: ResponseType.bytes));
      File file = File(myConfigInfo.downloadFilePath + filePath);
      await file.writeAsBytes(response.data);
      flag = true;
    } catch (e) {
      debugPrint(e.toString());
    }
    if (flag) {
      myConfigInfo.openFolder(myConfigInfo.downloadFilePath);
    }
    return flag;
  }

  Future<List<String>> submitPreprocessing(int problemId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String filePath = result.files.single.path!;
      String fileName = result.files.single.name;
      //将字节单位转换为kb单位
      String fileSize = (result.files.single.size >> 10).toString();

      if (problemList[problemId].maxSubmitFileSize.compareTo(fileSize) < 0) {
        return ["The file size is too large for submission"];
      }
      //这个列表在后续的优化过程中，应该由后端来获得
      List<String> fileSuffixList = ['c', 'cpp', 'go', 'java', 'py'];
      List<String> languageList = ['c', 'c++', 'golang', 'java', 'python3'];
      for (int i = 0; i < fileSuffixList.length; i++) {
        if (fileName.endsWith(fileSuffixList[i])) {
          return [filePath, fileName, languageList[i]];
        }
      }
      return ['Unsupported language'];
    }
    return ['You have not selected any file'];
  }

  //[filePath,fileName,selectedLanguage,studentNumber]
  Future<String> formalSubmission(List<String> list, int problemId) async {
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(list[0], filename: list[1]),
      'requestType': 'submit',
      'contestName': contestName,
      'problemName': problemList[problemId].problemName,
      'student_number': list[3],
      'submit_time': myConfigInfo.getCurTime('-'),
      'language': list[2],
    });

    return await dio
        .post('${myConfigInfo.getPath()}/studentForm', data: formData)
        .then((value) {
      return value.data['status'];
    });
  }
}
