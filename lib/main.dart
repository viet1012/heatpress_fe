import 'package:flutter/material.dart';

import 'Dashboard_IOT/dashboardIOT_screen.dart';

Future<void> main() async {
  runApp(MyApp());
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Dashboard Heat Guide',
      debugShowCheckedModeBanner: false,
      // home: DashboardScreen(),
      home: DashboardIOTScreen(),
      //DashboardScreen(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
