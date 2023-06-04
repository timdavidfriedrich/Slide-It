import 'package:flutter/material.dart';

class Global {
  static GlobalKey<NavigatorState> navigatorState = GlobalKey<NavigatorState>();

  static get context => Global.navigatorState.currentContext!;
  static get key => Global.navigatorState;

  static void pop() => Global.navigatorState.currentState!.pop();
}
