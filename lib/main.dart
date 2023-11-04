import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minesweeper/screens/connect_4.dart';
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

  String game = '';

  var minesweeperKey = UniqueKey();
  var c4Key = UniqueKey();
  Color appBarColor = myTheme.primaryColor;
  String appBarTitle = 'Select a game';

  refreshMain({String? game}) {
    if (mounted) {
      minesweeperKey = UniqueKey();
      c4Key = UniqueKey();
      setState(() {
        if (game != null) {
          this.game = game;
        }
      });
    }
  }

  changeAppBar({Color? color, String? title}) {
    if (mounted) {
      setState(() {
        if (color != null) {
          appBarColor = color;
        }
        if (title != null) {
          appBarTitle = title;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'Minesweeper',
      theme: myTheme,
      home: Scaffold(
          drawer: SideDrawer(refreshMain: refreshMain),
          appBar: AppBar(
            title: Text(appBarTitle),
            backgroundColor: appBarColor,
          ),
          body: (game.isEmpty)
              ? Center(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              game = 'minesweeper';
                              appBarTitle = 'Minesweeper';
                            });
                          },
                          child: Text('Minesweeper')),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              game = 'connect_4';
                              appBarTitle = 'Connect 4';
                              appBarColor = Colors.red;
                            });
                          },
                          child: Text('Connect 4')),
                    ),
                  ],
                ))
              : () {
                  switch (game) {
                    case 'minesweeper':
                      return Minesweeper(key: minesweeperKey);
                    case 'connect_4':
                      return Connect4(key: c4Key, changeAppBar: changeAppBar);
                    default:
                      return Text('No game');
                  }
                }()),
    );
  }
}
