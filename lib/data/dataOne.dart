import 'package:dio/dio.dart';
import 'package:platform/platform.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

var dio = Dio();

ConfigModel myConfigInfo = ConfigModel();

class ConfigModel {
  late String netPath;// = 'http://175.178.57.154:5051';
  late String hostUserName;// = 'QQ123456';
  late String downloadFilePath;// = 'C:\\Users\\QQ123456\\Downloads\\';
  void setPath(String path) {
    // netPath = 'http://175.178.57.154:5051';
    netPath = 'http://$path';
  }

  String getPath() {
    return netPath;
  }

  void setHostUserName() {
    Platform platform = LocalPlatform();
    if (platform.isWindows) {
      hostUserName = platform.environment['USERNAME']!;
      downloadFilePath = 'C:\\Users\\$hostUserName\\Downloads\\';
    }
  }

  String getHostUserName() {
    return hostUserName;
  }

  //打开指定文件夹
  Future<bool> openFolder(String dirPath) async {
    final url = Uri(scheme: 'file', path: dirPath);
    if (await canLaunchUrl(url)) {
      return await launchUrl(url);
    }
    return false;
  }

  //查看指定文件夹是否具有指定文件
  Future<bool> isExistFile(String dirPath, String filePath) async {
    Directory folder = Directory(dirPath);
    if (await folder.exists()) {
      List<FileSystemEntity> files = folder.listSync();
      for (int i = 0; i < files.length; i++) {
        if (files[i].path.endsWith(filePath)) {
          return true;
        }
      }
    }
    return false;
  }

  String getCurTime(String delimiter) {
    DateTime now = DateTime.now();
    String curTime = '${now.year}-';
    if (now.month < 10) {
      curTime += '0${now.month}-';
    } else {
      curTime += '${now.month}-';
    }
    if (now.day < 10) {
      curTime += '0${now.day} ';
    } else {
      curTime += '${now.day} ';
    }
    if (now.hour < 10) {
      curTime += '0${now.hour}$delimiter';
    } else {
      curTime += now.hour.toString() + delimiter;
    }
    if (now.minute < 10) {
      curTime += '0${now.minute}$delimiter';
    } else {
      curTime += now.minute.toString() + delimiter;
    }
    if (now.second < 10) {
      curTime += '0${now.second}';
    } else {
      curTime += now.second.toString();
    }
    return curTime;
  }

  //aTime > bTime return true,otherwise return false
  bool compareTime(String aTime, String bTime, {String delimiter = ':'}) {
    List<String> aList = aTime.split(' ');
    List<String> bList = bTime.split(' ');
    List<String> AList = aList[0].split('-') + aList[1].split(delimiter);
    List<String> BList = bList[0].split('-') + bList[1].split(delimiter);
    for (int i = 0; i < AList.length; i++) {
      if (AList[i].compareTo(BList[i]) > 0) {
        return true;
      } else if (AList[i].compareTo(BList[i]) < 0) {
        return false;
      }
    }
    return false;
  }

  String timeCalc(String aTime, String bTime) {
    aTime = aTime.replaceAll(':', '-');
    bTime = bTime.replaceAll(':', '-');
    print(bTime);
    List<int> aList =
        aTime.split(' ')[0].split('-').map((e) => int.parse(e)).toList() +
            aTime.split(' ')[1].split('-').map((e) => int.parse(e)).toList();
    List<int> bList =
        bTime.split(' ')[0].split('-').map((e) => int.parse(e)).toList() +
            bTime.split(' ')[1].split('-').map((e) => int.parse(e)).toList();

    DateTime startTime =
        DateTime(aList[0], aList[1], aList[2], aList[3], aList[4], aList[5]);
    DateTime endTime =
        DateTime(bList[0], bList[1], bList[2], bList[3], bList[4], bList[5]);
    Duration difference = endTime.difference(startTime);
    return difference.inSeconds.toString();
  }
}

var MyBus = MyEventBus();

//subscriber callback signature
typedef void MyEventCallback(arg);

class MyEventBus {
  //private constructors
  MyEventBus._internal();
  //saving singletons
  static MyEventBus _singleton = MyEventBus._internal();
  //factory constructors
  factory MyEventBus() => _singleton;
  //save the event subscriber queue,key:eventName,value:subscriber queue for the corresponding event
  final _emap = Map<Object, List<MyEventCallback>?>();
  //add a subscriber
  void on(eventName, MyEventCallback f) {
    _emap[eventName] ??= <MyEventCallback>[];
    _emap[eventName]!.add(f);
  }

  //delete subscriber
  void off(eventName, [MyEventCallback? f]) {
    var list = _emap[eventName];
    if (eventName == null || list == null) return;
    if (f == null) {
      _emap[eventName] = null;
    } else {
      list.remove(f);
    }
  }

  //emit event
  void emit(eventName, [arg]) {
    var list = _emap[eventName];
    if (list == null) return;
    int len = list.length - 1;
    for (var i = len; i > -1; --i) {
      list[i](arg);
    }
  }
}
