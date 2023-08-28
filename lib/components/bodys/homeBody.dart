import 'dart:async';

import 'package:flutter/material.dart';
import 'package:student/data/dataThree.dart';
import 'package:student/data/myProvider.dart';
import 'package:student/components/body.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}




//滚榜情况分类
//1 如果当前选手的题目没有pending，直接scrollController.animateTo向前移动一个选手的距离，
//  如果当前屏幕已经移动到最前面，则特殊处理一下
//2 如果当前选手有pending的题目
//2-1 如果运行错误，则遵循情况1
//2-2 如果运行正确，则该名选手的框框向前移动到指定位置，而且在移动的过程中应该覆盖它前面的选手的框框，
//    与此同时，它前面的选手的框框也应该一起向下移动一个选手的距离