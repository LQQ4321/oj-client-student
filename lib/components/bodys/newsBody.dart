import 'package:flutter/material.dart';
import 'package:student/components/body.dart';
import 'package:student/data/dataFour.dart';
import 'package:student/data/dataTwo.dart';
import 'package:student/data/myProvider.dart';
import 'package:student/macroWidgets/widgetOne.dart';

class NewsBody extends StatelessWidget {
  const NewsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<OneMessage> messageList =
        ChangeNotifierProvider.of<MessageModel>(context).messageList;
    String studentNumber =
        ChangeNotifierProvider.of<BodyModel>(context).studentNumber;
    String contestName =
        ChangeNotifierProvider.of<BodyModel>(context).contestName;
    final ScrollController scrollController = ScrollController();
    // scrollController.animateTo(offset, duration: const Duration(seconds: 1), curve: Curves.easeInOut)
    int itemId = 0;
    return Scaffold(
      body: messageList.isNotEmpty
          ? Center(
              child: Container(
                margin: const EdgeInsets.only(left: 100, right: 100),
                child: ListView.builder(
                    controller: scrollController,
                    itemCount: messageList.length,
                    itemExtent: 100,
                    itemBuilder: (BuildContext context, int index) {
                      return NewsCell(oneMessage: messageList[index]);
                    }),
              ),
            )
          : const NotData(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String res = await MyDialogs.fillField(context, ['']);
          if (res.isEmpty || res == 'null') {
            return;
          }
          bool flag = await ChangeNotifierProvider.of<MessageModel>(context)
              .insertSelfMessage(res, contestName, studentNumber);
          String hintText = "send info fail";
          if (flag) {
            hintText = 'send info succeed';
          }
          MyDialogs.hintMessage(context, hintText);
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}

class NewsCell extends StatelessWidget {
  const NewsCell({Key? key, required this.oneMessage}) : super(key: key);
  final OneMessage oneMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 3),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
          boxShadow: const [
            BoxShadow(
                color: Colors.black45,
                offset: Offset(1.0, 1.0),
                blurRadius: 2.0)
          ]),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: oneMessage.senderType == "manager"
                ? const Icon(Icons.manage_accounts_rounded)
                : const Icon(Icons.person_outline),
          ),
          Expanded(child: Text(oneMessage.text))
        ],
      ),
    );
  }
}
