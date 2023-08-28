import 'package:flutter/material.dart';
import 'package:student/data/dataThree.dart';
import 'package:student/data/dataTwo.dart';
import 'package:student/data/myProvider.dart';
import 'package:student/macroWidgets/widgetOne.dart';

class LoginRoute extends StatelessWidget {
  const LoginRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> hints = ['student number', 'password', 'url', 'login'];
    List<TextEditingController> controllers =
        List.generate(3, (index) => TextEditingController());
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
              child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  opacity: 0.5,
                  image: AssetImage('assets/images/picture0.jpg'),
                  fit: BoxFit.cover),
            ),
          )),
          Positioned.fill(
              child: Center(
            child: Container(
              width: 350,
              height: 220,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white70,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black45,
                        offset: Offset(1.0, 1.0),
                        blurRadius: 4.0)
                  ]),
              child: Column(
                children: List.generate(hints.length, (index) {
                  if (index == 3) {
                    return Expanded(
                        flex: 2,
                        child: ElevatedButton(
                            onPressed: () async {
                              //为了方便debug
                              // controllers[0].text = '2007310431';
                              // controllers[1].text = '123456';
                              // controllers[2].text = '1#1';
                              for (int i = 0; i < controllers.length; i++) {
                                //不能为空，字符串不能含有空格
                                if (controllers[i].text == "" ||
                                    controllers[i].text.contains(' ')) {
                                  MyDialogs.hintMessage(
                                      context, 'format error');
                                  return;
                                }
                              }
                              bool flag =
                                  await ChangeNotifierProvider.of<BodyModel>(
                                          context)
                                      .login(
                                          controllers[0].text,
                                          controllers[1].text,
                                          controllers[2].text);

                              if (!flag) {
                                MyDialogs.hintMessage(context, 'login fail');
                                return;
                              }
                              String contestId =
                                  ChangeNotifierProvider.of<BodyModel>(context,listen: false)
                                      .contestId;
                              //如果后台修改了比赛时间，客户端这里没有及时同步的功能，仍然会用第一次得到的比赛时间
                              ChangeNotifierProvider.of<HomeModel>(context)
                                  .getContestTime(contestId);
                            },
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                    const Size(150, 45))),
                            child: Text(hints[index])));
                  }
                  return Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextField(
                          controller: controllers[index],
                          decoration: InputDecoration(hintText: hints[index]),
                        ),
                      ));
                }),
              ),
            ),
          ))
        ],
      ),
    );
  }
}
