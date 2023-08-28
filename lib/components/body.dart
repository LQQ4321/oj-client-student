import 'package:flutter/material.dart';
import 'package:student/components/barOfBody.dart';
import 'package:student/components/bodys/newsBody.dart';
import 'package:student/components/bodys/rankBody.dart';
import 'package:student/components/bodys/statusBody.dart';
import 'package:student/components/bodys/homeBody.dart';
import 'package:student/data/dataFive.dart';
import 'package:student/data/dataSix.dart';
import 'package:student/data/dataThree.dart';
import 'package:student/data/dataTwo.dart';
import 'package:student/data/myProvider.dart';
import 'package:student/macroWidgets/widgetOne.dart';

class BodyRoute extends StatefulWidget {
  const BodyRoute({Key? key}) : super(key: key);

  @override
  State<BodyRoute> createState() => _BodyRouteState();
}

class _BodyRouteState extends State<BodyRoute> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          const MyAppBar(),
          Expanded(child: Builder(
            builder: (BuildContext context) {
              int curButtonId =
                  ChangeNotifierProvider.of<BodyModel>(context).curButtonId;
              if (curButtonId == 0) {
                return ChangeNotifierProvider(data: ListTest(), child: const Home());
                // return const Home();
              } else if (curButtonId == 1) {
                return const ProblemBody();
              } else if (curButtonId == 2) {
                return const StatusBody();
              } else if (curButtonId == 3) {
                return const NewsBody();
              } else if (curButtonId == 4) {
                return const RankBody();
              }
              return const Placeholder();
            },
          ))
        ],
      ),
    );
  }
}



class ProblemBody extends StatelessWidget {
  const ProblemBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      bool flag = ChangeNotifierProvider.of<ProblemsModel>(context).isRequest;
      int curProblemId =
          ChangeNotifierProvider.of<ProblemsModel>(context).curProblemId;
      List<Problem> problemList =
          ChangeNotifierProvider.of<ProblemsModel>(context).problemList;
      if (!flag || problemList.isEmpty) {
        //未成功请求到数据，显示无数据
        return const NotData();
      }
      return Center(
        child: Container(
          margin: const EdgeInsets.only(top: 3, left: 10, right: 10),
          child: Column(
            children: [
              Container(
                //进度条
                color: Colors.purple[50],
                height: 50,
                child: Container(),
              ),
              Expanded(
                  child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 50,
                    child: ListView.builder(
                        itemExtent: 50,
                        itemCount: problemList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            color: ChangeNotifierProvider.of<ProblemsModel>(
                                            context)
                                        .curProblemId ==
                                    index
                                ? Colors.green[100]
                                : Colors.white70,
                            clipBehavior: Clip.hardEdge,
                            child: InkWell(
                              splashColor: Colors.blue.withAlpha(30),
                              onTap: () async {
                                ChangeNotifierProvider.of<ProblemsModel>(
                                        context)
                                    .switchProblemId(index);
                              },
                              child: Center(
                                child: Text(String.fromCharCode(index + 65)),
                              ),
                            ),
                          );
                        }),
                  ),
                  Expanded(child: ProblemForm())
                ],
              ))
            ],
          ),
        ),
      );
    });
  }
}

class ProblemForm extends StatelessWidget {
  const ProblemForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int id = ChangeNotifierProvider.of<ProblemsModel>(context).curProblemId;
    Problem problem =
        ChangeNotifierProvider.of<ProblemsModel>(context).problemList[id];
    String studentNumber =
        ChangeNotifierProvider.of<BodyModel>(context).studentNumber;
    //下面的代码是为了获取题目通过率的
    bool rankIsRequest =
        ChangeNotifierProvider.of<RankModel>(context).isRequest;
    late List<ProblemPassRate> passRateList;
    //只有请求成功后才能赋值，否则就是将一个未初始化的成员赋值给一个变量
    if (rankIsRequest) {
      passRateList = ChangeNotifierProvider.of<RankModel>(context).passRateList;
    } else {
      List<Problem> problemList =
          ChangeNotifierProvider.of<ProblemsModel>(context).problemList;
      passRateList = List.generate(problemList.length, (index) {
        return ProblemPassRate(
            problemName: problemList[index].problemName,
            totalCount: '0',
            acCount: '0');
      });
    }
    String parseProblem() {
      for (int i = 0; i < passRateList.length; i++) {
        if (passRateList[i].problemName == problem.problemName) {
          return '${passRateList[i].totalCount} / ${passRateList[i].acCount}';
        }
      }
      return '0 / 0';
    }

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
          boxShadow: const [
            BoxShadow(
                color: Colors.black45,
                offset: Offset(1.0, 1.0),
                blurRadius: 2.0)
          ]),
      child: Column(
        children: [
          Container(
            height: 120,
            child: Row(
              children: [
                Expanded(
                    flex: 5,
                    child: Card(
                        color: Colors.purple[50],
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          splashColor: Colors.blue.withAlpha(30),
                          onTap: () async {},
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                problem.problemName,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                              Text('time limit : ${problem.time} ms'),
                              Text('memory limit : ${problem.memory} MB'),
                              Text(
                                  'file submission limit : ${problem.maxSubmitFileSize} KB')
                            ],
                          ),
                        ))),
                Expanded(
                    flex: 2,
                    child: Card(
                        color: Colors.purple[50],
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                            splashColor: Colors.blue.withAlpha(30),
                            onTap: () async {},
                            child: Center(
                                child: Text(
                              parseProblem(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 24),
                            ))))),
                Container(
                  //题目信息和两个按钮
                  width: 120,
                  child: Column(
                    children: List.generate(2, (index) {
                      return Expanded(
                          flex: 1,
                          child: Card(
                              color: Colors.white70,
                              clipBehavior: Clip.hardEdge,
                              child: InkWell(
                                splashColor: Colors.blue.withAlpha(30),
                                onTap: () async {
                                  if (index == 0) {
                                    bool flag = await ChangeNotifierProvider.of<
                                            ProblemsModel>(context)
                                        .downloadProblemFiles(id, 'pdf');
                                    if (!flag) {
                                      MyDialogs.hintMessage(
                                          context, 'download problem fail');
                                    }
                                  } else if (index == 1) {
                                    List<String> res =
                                        await ChangeNotifierProvider.of<
                                                ProblemsModel>(context)
                                            .submitPreprocessing(id);
                                    if (res.length > 1) {
                                      res.add(studentNumber);
                                      bool flag = await MyDialogs.hintMessage(
                                          context, 'Are you sure to submit ?',
                                          isOneButton: false);
                                      if (!flag) {
                                        return;
                                      }
                                      String status =
                                          await ChangeNotifierProvider.of<
                                                  ProblemsModel>(context)
                                              .formalSubmission(res, id);
                                      MyDialogs.hintMessage(context, status);
                                      return;
                                    }
                                    MyDialogs.hintMessage(context, res[0]);
                                  }
                                },
                                child: Center(
                                    child: Text(
                                        index == 0 ? "problem" : "submit")),
                              )));
                    }),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: Center(
            child: Container(
              width: 500,
              child: ListView.builder(
                  itemExtent: 40,
                  itemCount: problem.exampleList.length,
                  itemBuilder: (BuildContext context, int exampleId) {
                    return Row(
                        children: List.generate(
                      2,
                      (index) {
                        return Expanded(
                            flex: 1,
                            child: Card(
                                color: Colors.white70,
                                clipBehavior: Clip.hardEdge,
                                child: InkWell(
                                  splashColor: Colors.blue.withAlpha(30),
                                  onTap: () async {
                                    String option = index == 0 ? 'in' : 'out';
                                    ChangeNotifierProvider.of<ProblemsModel>(
                                            context)
                                        .downloadProblemFiles(id, option,
                                            exampleId:
                                                problem.exampleList[exampleId]);
                                  },
                                  child: Center(
                                      child: Text(index == 0
                                          ? 'in${exampleId + 1}.txt'
                                          : "out${exampleId + 1}.txt")),
                                )));
                      },
                    ));
                  }),
            ),
          ))
        ],
      ),
    );
  }
}

class NotData extends StatelessWidget {
  const NotData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "No data currently exists",
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
      ),
    );
  }
}
