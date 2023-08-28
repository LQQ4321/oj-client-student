import 'package:flutter/material.dart';
import 'package:student/components/body.dart';
import 'package:student/data/dataFive.dart';
import 'package:student/data/dataFour.dart';
import 'package:student/data/dataThree.dart';
import 'package:student/data/myProvider.dart';

class RankBody extends StatelessWidget {
  const RankBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isRequest = ChangeNotifierProvider.of<RankModel>(context).isRequest;
    late List<PlayerInfo> playerList;
    if (isRequest) {
      playerList = ChangeNotifierProvider.of<RankModel>(context).playerList;
    }
    return isRequest
        ? Container(
            child: ListView.builder(
                itemCount: playerList.length,
                itemExtent: 60,
                itemBuilder: (BuildContext context, int index) {
                  return PlayerCell(
                    playerInfo: playerList[index],
                    playId: index,
                  );
                }),
          )
        : const NotData();
  }
}

class PlayerCell extends StatelessWidget {
  const PlayerCell({Key? key, required this.playerInfo, required this.playId})
      : super(key: key);
  final PlayerInfo playerInfo;
  final int playId;

  @override
  Widget build(BuildContext context) {
    //以problemNameList为参照物，因为playerList有一些选手的题目是没有提交过的，所以会缺少一些题目的信息
    List<String> problemNameList =
        ChangeNotifierProvider.of<ProblemsModel>(context).getProblemNameList();
    return Container(
      height: 80,
      color: playId % 2 == 0 ? Colors.black12 : Colors.black26,
      child: Row(
        children: [
          Container(
            width: 80,
            child: Center(
              child: Text(playerInfo.rank),
            ),
          ),
          Expanded(
              child: Column(
            children: [
              Expanded(
                  flex: 1,
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                                '${playerInfo.studentNumber} - ${playerInfo.studentName}')),
                        Container(
                          width: 200,
                          child: Row(
                            children: List.generate(2, (index) {
                              return Expanded(
                                  flex: 1,
                                  child: Text(index == 0
                                      ? playerInfo.acProblemCount
                                      : playerInfo.penaltyTime));
                            }),
                          ),
                        )
                      ],
                    ),
                  )),
              Expanded(
                  flex: 2,
                  child: Container(
                    child: Row(
                      children: List.generate(problemNameList.length, (index) {
                        return ProblemCell(
                            problemName: problemNameList[index],
                            problemId: index,
                            problemStatusList: playerInfo.problemStatusList);
                      }),
                    ),
                  ))
            ],
          ))
        ],
      ),
    );
  }
}

class ProblemCell extends StatelessWidget {
  const ProblemCell(
      {Key? key,
      required this.problemName,
      required this.problemId,
      required this.problemStatusList})
      : super(key: key);
  final String problemName;
  final int problemId;
  final List<ProblemStatus> problemStatusList;

  @override
  Widget build(BuildContext context) {
    String text = String.fromCharCode(problemId+65);
    Color problemColor = Colors.black54;
    for (var element in problemStatusList) {
      if (element.problemName == problemName) {
        text = '${element.submitCount} - ${element.lastSubmitTime}';
        problemColor = StatusModel.switchColor(element.status);
      }
    }
    return Expanded(
        flex: 1,
        child: Card(
          color: problemColor,
          clipBehavior: Clip.hardEdge,
          child: Center(
            child: Text(text),
          ),
        ));
  }
}
