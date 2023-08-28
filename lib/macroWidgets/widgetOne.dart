import 'package:flutter/material.dart';

class MyDialogs {
  static Future<dynamic> showMyDialog(
      BuildContext context, Widget widget) async {
    return showDialog<dynamic>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(content: widget);
        });
  }

  static Future<dynamic> hintMessage(BuildContext context, String promptMessage,
      {bool isOneButton = true}) {
    return showMyDialog(context, Builder(builder: (context) {
      return SizedBox(
        width: 500,
        height: 150,
        child: Column(
          children: [
            Text(promptMessage),
            const Padding(padding: EdgeInsets.only(bottom: 60)),
            Row(
                mainAxisAlignment: isOneButton
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceBetween,
                children: List.generate(isOneButton ? 1 : 2, (index) {
                  final String? text;
                  if (isOneButton || index == 1) {
                    text = "confirm";
                  } else {
                    text = "cancel";
                  }
                  return ElevatedButton(
                      onPressed: () {
                        if (text == "cancel") {
                          Navigator.pop(context, false);
                        } else {
                          Navigator.pop(context, true);
                        }
                      },
                      style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(const Size(100, 50))),
                      child: Text(text));
                }).toList())
          ],
        ),
      );
    }));
  }

  static Future<dynamic> fillField(
      BuildContext context, List<String> promptMessages) {
    return showMyDialog(context, Builder(builder: (context) {
      TextEditingController textEditingController = TextEditingController();
      return Container(
        width: 500,
        height: 300,
        child: Column(
          children: <Widget>[
                TextField(
                  controller: textEditingController,
                ),
              ] +
              <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  height: 100,
                  child: Row(
                    children: List.generate(2, (index) {
                      return ElevatedButton(
                          onPressed: () {
                            if (index == 0) {
                              Navigator.pop(context, 'null');
                            } else {
                              Navigator.pop(
                                  context, textEditingController.text);
                            }
                          },
                          style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(
                                  const Size(120, 50)),
                              backgroundColor: MaterialStateColor.resolveWith(
                                  (states) => index == 0
                                      ? Colors.redAccent
                                      : Colors.blueAccent)),
                          child: Text(index == 0 ? "cancel" : "confirm"));
                    }),
                  ),
                )
              ],
        ),
      );
    }));
  }
}
