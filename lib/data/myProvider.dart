import 'package:flutter/material.dart';

//一个通用的InheritedWidget，保存需要跨组件共享的状态
class InheritedProvider<T> extends InheritedWidget {
  InheritedProvider({required this.data, required Widget child})
      : super(child: child);
  final T data;

  @override
  bool updateShouldNotify(InheritedProvider<T> oldWidget) {
    //在此简单返回true，则每次更新都会调用依赖其的子孙节点的‘didChangeDependencies’
    return true;
  }
}

class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {
  ChangeNotifierProvider({Key? key, required this.data, required this.child});
  final Widget child;
  final T data;
  static T of<T>(BuildContext context, {bool listen = true}) {
    // final type = _typeOf<InheritedProvider<T>>();
    final provider = listen
        ? context.dependOnInheritedWidgetOfExactType<InheritedProvider<T>>()
        : context
        .getElementForInheritedWidgetOfExactType<InheritedProvider<T>>()
        ?.widget as InheritedProvider<T>;
    // final provider =
    //     context.dependOnInheritedWidgetOfExactType<InheritedProvider<T>>();
    return provider!.data;
  }

  @override
  _ChangeNotifierProviderState<T> createState() =>
      _ChangeNotifierProviderState<T>();
}

class _ChangeNotifierProviderState<T extends ChangeNotifier>
    extends State<ChangeNotifierProvider<T>> {
  void update() {
    //  如果数据发生变化(model类调用了notifyListeners)，重新构建InheritedProvider
    setState(() {});
  }

  @override
  void didUpdateWidget(ChangeNotifierProvider<T> oldWidget) {
    //  当Provider更新时，如果新旧数据不"=="，则解绑旧数据监听，同时添加新数据监听
    if (widget.data != oldWidget.data) {
      oldWidget.data.removeListener(update);
      widget.data.addListener(update);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    //给model添加监听器
    widget.data.addListener(update);
    super.initState();
  }

  @override
  void dispose() {
    //移除model的监听器
    widget.data.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedProvider(data: widget.data, child: widget.child);
  }
}

class MyConsumer<T> extends StatelessWidget {
  const MyConsumer({Key? key, required this.builder}) : super(key: key);
  final Widget Function(BuildContext context, T? value) builder;

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      ChangeNotifierProvider.of<T>(context),
    );
  }
}

// class MyConsumer<T> extends StatefulWidget {
//   MyConsumer({Key? key, required this.builder}) : super(key: key);
//   final Widget Function(BuildContext context, T? value) builder;
//   @override
//   _MyConsumerState<T> createState() => _MyConsumerState<T>();
// }
//
// class _MyConsumerState<T> extends State<MyConsumer> {
//   @override
//   Widget build(BuildContext context) {
//     return widget.builder(context, ChangeNotifierProvider.of<T>(context));
//   }
// }
