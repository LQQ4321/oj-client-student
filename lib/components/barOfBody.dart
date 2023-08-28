import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:student/data/dataTwo.dart';
import 'package:student/data/myProvider.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
          boxShadow: const [
            BoxShadow(
                color: Colors.black45,
                offset: Offset(1.0, 1.0),
                blurRadius: 2.0)
          ]),
      margin: const EdgeInsets.all(5.0),
      child: WindowTitleBarBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [userCell(), BusinessButtons(), WindowButtons()],
        ),
      ),
    );
  }
}

class userCell extends StatelessWidget {
  const userCell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String studentNumber =
        ChangeNotifierProvider.of<BodyModel>(context).studentNumber;
    String studentName =
        ChangeNotifierProvider.of<BodyModel>(context).studentName;
    return Container(
      margin: const EdgeInsets.only(left: 30),
      width: 120,
      child: Column(
        children: [
          Text(
            studentName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
          Text(
            studentNumber,
            style: const TextStyle(fontSize: 14),
          )
        ],
      ),
    );
  }
}

class BusinessButtons extends StatelessWidget {
  const BusinessButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> buttonTexts = ['home', 'problem', 'status', 'news', 'rank'];
    return Container(
      width: 500,
      child: Row(
        children: List.generate(buttonTexts.length, (index) {
          int buttonId =
              ChangeNotifierProvider.of<BodyModel>(context).curButtonId;
          // String contestName =
          //     ChangeNotifierProvider.of<BodyModel>(context).contestName;
          // String contestId =
          //     ChangeNotifierProvider.of<BodyModel>(context).contestId;
          return Expanded(
              flex: 1,
              child: ElevatedButton(
                  onPressed: () {
                    ChangeNotifierProvider.of<BodyModel>(context)
                        .switchButtonId(index);
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero)),
                    minimumSize: MaterialStateProperty.all(
                        const Size(80, double.infinity)),
                    backgroundColor: MaterialStateColor.resolveWith((states) =>
                        index != buttonId
                            ? Colors.black12
                            : Colors.purple[100]!),
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => Colors.transparent),
                    shadowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.transparent),
                  ),
                  child: Text(
                    buttonTexts[index],
                    style: const TextStyle(color: Colors.black),
                  )));
        }),
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306),
    mouseOver: const Color(0xFFF6A00C),
    mouseDown: const Color(0xFF805306),
    iconMouseOver: const Color(0xFF805306),
    iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
