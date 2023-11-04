import 'package:flutter/material.dart';

class SideDrawer extends StatefulWidget {
  final Function refreshMain;

  const SideDrawer({Key? key, required this.refreshMain}) : super(key: key);

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              'Minesweeper',
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.refreshMain(game: 'minesweeper');
              },
              child: Text('Minesweeper')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.refreshMain(game: 'connect_4');
              },
              child: Text('Connect 4')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.refreshMain();
              },
              child: Text('Restart')),
        ],
      ),
    );
  }
}
