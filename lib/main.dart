import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:student/components/body.dart';
import 'package:student/data/dataFive.dart';
import 'package:student/data/dataFour.dart';
import 'package:student/data/dataOne.dart';
import 'package:student/data/dataThree.dart';
import 'package:student/data/dataTwo.dart';
import 'package:student/data/myProvider.dart';
import 'package:student/components/login.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1000, 700);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Custom window of Gxu oj";
    win.show();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BodyModel>(
        data: BodyModel(),
        child: ChangeNotifierProvider<HomeModel>(
          data: HomeModel(),
          child: ChangeNotifierProvider<ProblemsModel>(
            data: ProblemsModel(),
            child: ChangeNotifierProvider<StatusModel>(
              data: StatusModel(),
              child: ChangeNotifierProvider<RankModel>(
                data: RankModel(),
                child: ChangeNotifierProvider<MessageModel>(
                  data: MessageModel(),
                  child: IntervalTimer(
                    child: Builder(
                      builder: (context) {
                        bool isLoginSuccess =
                            ChangeNotifierProvider.of<BodyModel>(context)
                                .isLoginSucceed;
                        return isLoginSuccess
                            ? const BodyRoute()
                            : const LoginRoute();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

class IntervalTimer extends StatefulWidget {
  const IntervalTimer({Key? key, required this.child}) : super(key: key);
  final Widget child; //这里变成final会有什么影响？？？
  @override
  State<IntervalTimer> createState() => _IntervalTimerState();
}

class _IntervalTimerState extends State<IntervalTimer> {
  @override
  void initState() {
    //如果登录成功，就启动该订阅器
    MyBus.on('intervalTimers', intervalTimers);
    debugPrint("这里应该只启动一次才对");
    super.initState();
  }

  @override
  void dispose() {
    MyBus.off('intervalTimers');
    super.dispose();
  }

  //好像不能直接在initState方法内调用该函数，要等到其初始化完成(build方法开始执行，才能得到BuildContext)后才能调用
  //循环定时器的集合
  void intervalTimers(_) async {
    //多次移除也是安全操作
    MyBus.off('intervalTimers');
    int checkContestStartIntervalTime = 10;
    // 检测比赛是否开始，如果开始就启动相应的循环定时器，让他们开始工作
    // 好像初始化完成后就启动了，不要再手动启动(比如这样:contestStartTimer.start())
    Timer.periodic(Duration(seconds: checkContestStartIntervalTime), (timer) {
      String contestStartTime =
          ChangeNotifierProvider.of<HomeModel>(context, listen: false)
              .startTime;
      String curTime = myConfigInfo.getCurTime(':');
      if (myConfigInfo.compareTime(curTime, contestStartTime)) {
        launchBusinessTimers();
        timer.cancel();
      }
    });
  }

  //这里的参数应该是引用吧
  void launchBusinessTimers() {
    // 检测后台是否有新增的题目(其实这些循环定时器就是为了获取信息，同时还要考虑效率)
    late final Timer problemTimer;
    // 定期获取选手的提交信息
    late final Timer statusTimer;
    // 定期获取排名数据
    late final Timer rankTimer;
    // 定期获取有关比赛的信息
    late final Timer newsTimer;
    // 反正检查比赛是否结束消耗的都是客户端的资源，不会影响到服务器，所以间隔小一点也没事，
    // 而且为了公平起见，检查的间隔也应该小一点
    int checkContestEndIntervalTime = 10;
    int problemIntervalTime = 5 * 60;
    int statusIntervalTime = 2 * 60;
    int rankIntervalTime = 3 * 60; //2 * 60; //即使是站在不考虑客户端的资源消耗角度来看，也太耗资源了
    int newsIntervalTime = 1 * 60;

    // 检测比赛是否结束，如果比赛结束，就关闭各个相应的循环定时器，以免造成服务器压力太大
    // 可以搭配timer.isActive来使用，以免多次关闭一个循环定时器造成报错
    Timer.periodic(Duration(seconds: checkContestEndIntervalTime), (timer) {
      String contestEndTime =
          ChangeNotifierProvider.of<HomeModel>(context).endTime;
      String curTime = myConfigInfo.getCurTime(':');
      if (myConfigInfo.compareTime(curTime, contestEndTime)) {
        if (problemTimer.isActive) {
          problemTimer.cancel();
        }
        if (statusTimer.isActive) {
          statusTimer.cancel();
        }
        if (rankTimer.isActive) {
          rankTimer.cancel();
        }
        if (newsTimer.isActive) {
          newsTimer.cancel();
        }
        timer.cancel();
      }
    });
    //====================================缓存数据===================================
    String contestName =
        ChangeNotifierProvider.of<BodyModel>(context).contestName;
    String contestId = ChangeNotifierProvider.of<BodyModel>(context).contestId;
    String studentNumber =
        ChangeNotifierProvider.of<BodyModel>(context).studentNumber;
    String contestStartTime =
        ChangeNotifierProvider.of<HomeModel>(context).startTime;
    //这里先请求一遍
    ChangeNotifierProvider.of<ProblemsModel>(context)
        .requestProblemsData(contestName);
    //提前初始化，防止请求数据失败导致未初始化报错
    List<String> problemNameList =
        ChangeNotifierProvider.of<ProblemsModel>(context).getProblemNameList();

    //=============================各种功能的循环计数器====================================
    problemTimer =
        Timer.periodic(Duration(seconds: problemIntervalTime), (timer) {
      debugPrint('problemTimer');
      ChangeNotifierProvider.of<ProblemsModel>(context)
          .requestProblemsData(contestName);
      problemNameList = ChangeNotifierProvider.of<ProblemsModel>(context)
          .getProblemNameList();
    });

    statusTimer =
        Timer.periodic(Duration(seconds: statusIntervalTime), (timer) {
      debugPrint('statusTimer');
      ChangeNotifierProvider.of<StatusModel>(context)
          .requestStatusInfo(contestName, studentNumber);
    });

    rankTimer = Timer.periodic(Duration(seconds: rankIntervalTime), (timer) {
      debugPrint('rankTimer');
      ChangeNotifierProvider.of<RankModel>(context)
          .requestRankInfo(contestId, studentNumber, contestStartTime);
    });

    newsTimer = Timer.periodic(Duration(seconds: newsIntervalTime), (timer) {
      debugPrint('newsTimer');
      ChangeNotifierProvider.of<MessageModel>(context)
          .requestContestNews(contestId, studentNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
