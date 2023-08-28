import 'package:flutter/material.dart';
import 'package:student/components/body.dart';
import 'package:student/data/dataFour.dart';
import 'package:student/data/myProvider.dart';

class StatusBody extends StatelessWidget {
  const StatusBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isRequest = ChangeNotifierProvider.of<StatusModel>(context).isRequest;
    if (!isRequest) {
      return const NotData();
    }
    //不能把下面的代码放到获取isRequest之前，因为isRequest == false表示submitList还没有初始化
    List<OneSubmitInfo> submitList =
        ChangeNotifierProvider.of<StatusModel>(context).submitList;
    if (submitList.isEmpty) {
      return const NotData();
    }
    return Center(
      child: Container(
        margin: const EdgeInsets.only(left: 100, right: 100),
        child: ListView.builder(
            itemCount: submitList.length,
            itemExtent: 40,
            itemBuilder: (BuildContext context, int index) {
              return OneSubmitCell(
                oneSubmitInfo: submitList[index],
              );
            }),
      ),
    );
  }
}

class OneSubmitCell extends StatelessWidget {
  const OneSubmitCell({Key? key, required this.oneSubmitInfo})
      : super(key: key);
  final OneSubmitInfo oneSubmitInfo;

  @override
  Widget build(BuildContext context) {
    List<String> list = [
      oneSubmitInfo.problemName,
      oneSubmitInfo.curStatus,
      oneSubmitInfo.language,
      oneSubmitInfo.submitTime
    ];
    return Container(
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
              flex: index == 0 ? 3 : 2,
              child: Card(
                  color: index == 1
                      ? StatusModel.switchColor(list[index])
                      : Colors.purple[50],
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      onTap: () async {},
                      child: Center(
                          child: Text(
                        list[index],
                      )))));
        }),
      ),
    );
  }
}
