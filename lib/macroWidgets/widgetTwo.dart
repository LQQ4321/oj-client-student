import 'package:flutter/material.dart';
import 'dart:async';

import 'package:student/data/dataOne.dart';

//这个是倒计时组件，需要显示的东西有day,hour,minute,second
class CountdownTimer extends StatefulWidget {
  const CountdownTimer(
      {Key? key, required this.startTime, required this.endTime})
      : super(key: key);
  final String startTime;
  final String endTime;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  int count = 0;
  int seconds = 0;
  late Timer countdownTimer;
  int listId = 0;
  List<List<int>> timeList =
      List.generate(2, (index) => List.generate(4, (index) => 0));
  List<String> timeUnitNameList = ['day', 'hour', 'minute', 'second'];
  @override
  void initState() {
    List<int> timeUnitList = [24 * 60 * 60, 60 * 60, 60];
    seconds =
        int.parse(myConfigInfo.timeCalc(widget.endTime, widget.startTime));

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds == 0) {
        timer.cancel();
        return; //加个return,应该可以防止执行下面的代码
      }
      setState(() {
        seconds--;
        int temp = seconds;
        listId = (listId + 1) ~/ 2;
        for (int i = 0; i < 4; i++) {
          if (i == 3) {
            timeList[listId][i] = temp;
            break;
          }
          timeList[listId][i] = temp ~/ timeUnitList[i];
          temp = temp % timeUnitList[i];
        }
        count++;
      });
      //不懂要不要加setState
      debugPrint(count.toString());
    });
    super.initState();
  }

  @override
  void dispose() {
    if (countdownTimer.isActive) {
      countdownTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(timeList[listId].length, (index) {
        return Expanded(
            flex: 1,
            child: Row(
              children: [
                SizedBox(
                  width: 150,
                  height: 100,
                  child: AnimationNumber(
                    count: count,
                    newTime: addPreZero(timeList[listId][index]),
                    oldTime: addPreZero(timeList[(listId + 1) ~/ 2][index]),
                  ),
                ),
                Text(timeUnitNameList[index])
              ],
            ));
      }),
    );
  }

  String addPreZero(int num) {
    return num < 10 ? '0$num' : num.toString();
  }
}




class AnimationNumber extends StatelessWidget {
  const AnimationNumber(
      {Key? key,
      required this.count,
      required this.newTime,
      required this.oldTime})
      : super(key: key);
  final int count;
  final String newTime;
  final String oldTime;
  @override
  Widget build(BuildContext context) {
    return Center(child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constrains) {
      return TweenAnimationBuilder(
        duration: const Duration(seconds: 1),
        tween: Tween(end: count.toDouble()),
        builder: (BuildContext context, value, Widget? child) {
          //这里的value就是上面的count
          final whole = value ~/ 1;
          final decimal = value - whole;
          // debugPrint('$whole - $decimal');
          return Stack(
            children: [
              Positioned(
                top: constrains.maxHeight - constrains.maxHeight * decimal,//100 -> 0
                child: Center(
                  child: Text(
                    '${whole + 1}',
                    // newTime,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: newTime.length > 2
                            ? constrains.maxHeight - 20
                            : constrains.maxHeight,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              Positioned(
                top: -constrains.maxHeight * decimal,//0 -> -100
                child: Center(
                  child: Text(
                    '$whole',
                    // oldTime,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: oldTime.length > 2
                            ? constrains.maxHeight - 20
                            : constrains.maxHeight,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }));
  }
}
