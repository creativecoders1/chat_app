import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // Define routes mapping
  final Map<String, Widget Function(BuildContext)> _routes = {
    "/login": (context) => const LoginPage(),
    "/home": (context) => const HomePage(),
  };

  // Provide the navigator key
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  // Provide routes
  Map<String, Widget Function(BuildContext)> get routes => _routes;

  // Push to the specified route
  void pushNamed(String routeName) {
    if (_navigatorKey.currentState != null) {
      _navigatorKey.currentState?.pushNamed(routeName);
    } else {
      debugPrint('Navigator key is null! Could not push route: $routeName');
    }
  }

  // Replace the current route with the specified route
  void pushReplacementNamed(String routeName) {
    if (_navigatorKey.currentState != null) {
      _navigatorKey.currentState?.pushReplacementNamed(routeName);
    } else {
      debugPrint('Navigator key is null! Could not replace route: $routeName');
    }
  }

  // Pop the current route
  void goBack() {
    if (_navigatorKey.currentState != null &&
        _navigatorKey.currentState!.canPop()) {
      _navigatorKey.currentState?.pop();
    } else {
      debugPrint('Navigator key is null or cannot pop!');
    }
  }
}
