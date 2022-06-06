import 'package:flutter/material.dart';
import 'package:minesweeper/screens/minesweeper.dart';
import 'package:minesweeper/side_drawer.dart';
import 'package:minesweeper/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  refreshMain() {
    if (mounted) {
      setState((){});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minesweeper',
      theme: myTheme,
      home:
      Scaffold(
          drawer: SideDrawer(refreshMain: refreshMain),
          appBar: AppBar(title: Text('Minesweeper'),),
          body: Minesweeper(key: UniqueKey()),
      ),
    );
  }
}