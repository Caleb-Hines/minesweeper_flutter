import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

import '../classes/tile.dart';

class Minesweeper extends StatefulWidget {
  const Minesweeper({Key? key}) : super(key: key);

  @override
  State<Minesweeper> createState() => _MinesweeperState();
}

class _MinesweeperState extends State<Minesweeper> {
  int tilesAcross = 13;//13;
  int tilesDown = 9;//9;
  String difficulty = 'easy';

  double minTileSize = 38;
  double maxTileSize = 60;

  late int numBombs;
  List<List<Tile>> grid = [];
  bool gameFinished = false;

  Border tileBorder = const Border(
    left: BorderSide(
      color: Color(0xff8070f5),
      width: 3.0,
    ),
    top: BorderSide(
      color: Color(0xff8070f5),
      width: 3.0,
    ),
    right: BorderSide(
      color: Color(0xff090330),
      width: 3.0,
    ),
    bottom: BorderSide(
      color: Color(0xff090330),
      width: 3.0,
    ),
  );
  Border revealedBorder = const Border(
    left: BorderSide(
      color: Color(0xff5541f1),
      width: 2.0,
    ),
    top: BorderSide(
      color: Color(0xff5541f1),
      width: 2.0,
    ),
    right: BorderSide(
      color: Color(0xff5541f1),
      width: 2.0,
    ),
    bottom: BorderSide(
      color: Color(0xff5541f1),
      width: 2.0,
    ),
  );

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      html.document.onContextMenu.listen((event) => event.preventDefault());
    }

    switch (difficulty) {
      case 'easy':
        numBombs = ((tilesAcross * tilesDown) / 8.2).floor();
        break;
      case 'medium':
        numBombs = ((tilesAcross * tilesDown) / 6.6).floor();
        break;
      case 'hard':
        numBombs = ((tilesAcross * tilesDown) / 5.5).floor();
        break;
      default:
        numBombs = ((tilesAcross * tilesDown) / 7.5).floor();
    }

    initGrid();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // initGrid();
  }

  initGrid() {
    print('initGrid');
    gameFinished = false;

    grid = List<List<Tile>>.generate(
      tilesAcross,
      (i) => List.generate(
        tilesDown,
        (j) {
          return Tile();
        },
        growable: false,
      ),
    );

    print('grid built');

    // print(grid);

    // grid.forEach((row) {
    //   print(row);
    // });

    var rng = Random();
    for (int i = 0; i < numBombs;) {
      int bombI = rng.nextInt(tilesAcross);
      int bombJ = rng.nextInt(tilesDown);

      if (!grid[bombI][bombJ].isBomb) {
        grid[bombI][bombJ].isBomb = true;
        i++;
      }
    }

    // print('added bombs');
    // print(grid[1][2].isBomb);
    // print(grid[1][3].isBomb);
    // grid[1][2].isBomb = true;
    // print(grid[1][2].isBomb);
    // print(grid[1][3].isBomb);
    // grid.forEach((row){
    //   print(row);
    // });

    setAdjacent();
    grid.forEach(print);
    setState(() {});
  }

  // Sets the numbers of bombs adjacent to each tile
  setAdjacent() {
    print('setAdjacent');
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        for (int checkI = i - 1; checkI < i + 2; checkI++) {
          for (int checkJ = j - 1; checkJ < j + 2; checkJ++) {
            if (checkI >= 0 &&
                checkJ >= 0 &&
                checkI < tilesAcross &&
                checkJ < tilesDown &&
                !(checkI == i && checkJ == j)) {
              Tile tile = grid[checkI][checkJ];
              if (tile.isBomb) {
                grid[i][j].adjacentBombs++;
              }
            }
          }
        }
      }
    }
    print('setAdjacent done');
  }

  setAllRevealed() {
    for (List row in grid) {
      for (Tile tile in row) {
        tile.isRevealed = true;
      }
    }
  }

  checkGameWon() {
    bool won = true;
    for (List<Tile> row in grid) {
      for (Tile tile in row) {
        if (!tile.isRevealed && !tile.isBomb) {
          print('nah');
          print(row.indexOf(tile));
          print(grid.indexOf(row));
          won = false;
          break;
        }
      }
    }
    if (won) {
      complete();
    }
  }

  tileTapped(Tile tile, int i, int j) async {
    if (!gameFinished && !tile.isFlagged) {
      tile.isClicked = true;

      if (tile.isBomb) {
        complete(won: false);
        return;
      }

      if (tile.adjacentBombs == 0) {
        revealAdjacentZeros(i, j);
      }

      setState(() {
        tile.isRevealed = true;
      });

      checkGameWon();
    }
  }

  // inefficient
  revealAdjacentZeros(i, j) {
    // console.log('revealZeros: ' + i +  ", " + j);
    for (int revealI = i - 1; revealI < i + 2; revealI++) {
      for (int revealJ = j - 1; revealJ < j + 2; revealJ++) {
        if (revealI >= 0 &&
            revealJ >= 0 &&
            revealI < tilesAcross &&
            revealJ < tilesDown &&
            !(revealI == i && revealJ == j)) {
          Tile tile = grid[revealI][revealJ];
          if (!tile.isRevealed) {
            tile.isRevealed = true;
            if (tile.adjacentBombs == 0) {
              revealAdjacentZeros(revealI, revealJ);
            }
          }
        }
      }
    }
  }

  complete({won = true}) {
    setAllRevealed();
    setState(() {
      gameFinished = true;
    });
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            content: Text('You ${won ? 'won!' : 'lost!'}'),
            actions: [
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  toggleFlagged(Tile tile) {
    if (!tile.isRevealed) {
      setState(() {
        tile.isFlagged = !tile.isFlagged;
      });
    }
  }

  bool panEnabled = false;
  double bottomPadding = 0;

  @override
  Widget build(BuildContext context) {
    // initGrid();
    print('building mines');

    print(MediaQuery.of(context).padding.top + kToolbarHeight);

    double width = MediaQuery.of(context).size.width;
    double pageHeight = MediaQuery.of(context).size.height;
    print('screenHeight ' + pageHeight.toString());
    pageHeight -=
        MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom + kToolbarHeight + bottomPadding;
    print('pageHeight ' + pageHeight.toString());

    bool xOverflow = false;
    bool yOverflow = false;

    double _tileSize = width / grid[0].length;
    if (_tileSize < minTileSize) {
      _tileSize = minTileSize;
      xOverflow = true;
    } else if (_tileSize > maxTileSize) {
      _tileSize = maxTileSize;
    }

    print('tile size: ' + (_tileSize).toString());
    print('grid height: ' + (_tileSize * grid.length).toString());

    if (_tileSize * grid.length > pageHeight) {
      yOverflow = true;
    }

    if (xOverflow || yOverflow) {
      print('panEnabled');
      panEnabled = true;
    }

    print("_tileSize: " + _tileSize.toString());

    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Container(
          color: Color(0xffd5cffc),
          child: InteractiveViewer(
            panEnabled: panEnabled,
            scaleEnabled: panEnabled,
            constrained: false,
            boundaryMargin: EdgeInsets.all(1000),
            minScale: .02,
            maxScale: 2,
            child:

                // SingleChildScrollView(
                //   physics: NeverScrollableScrollPhysics(),
                // scrollDirection: Axis.horizontal,
                // //
                // child:

                Container(
              height: _tileSize * grid.length,
              width: _tileSize * grid[0].length,
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: tilesAcross,
                  itemBuilder: (ctx, i) {
                    List<Tile> row = grid[i];
                    List<Widget> rowItems = [];

                    for (int j = 0; j < row.length; j++) {
                      Tile tile = row[j];

                      String display = '';
                      Color bgColor = Theme.of(context).primaryColor;

                      bool useRevealedBorber = true;

                      if (!tile.isRevealed) {
                        useRevealedBorber = false;
                        if (tile.isFlagged) {
                          display = 'f';
                        } else {
                          display = '';
                        }
                      } else if (tile.isBomb) {
                        display = 'B';
                      } else {
                        if (tile.adjacentBombs > 0) {
                          display = tile.adjacentBombs.toString();
                        } else {
                          bgColor = Color(0xffaaa0f8);
                          // bgColor = Colors.grey[300]!;
                        }
                      }

                      rowItems.add(GestureDetector(
                          onSecondaryTap: () {
                            toggleFlagged(tile);
                          },
                          onTap: () {
                            tileTapped(tile, i, j);
                          },
                          onLongPress: () {
                            toggleFlagged(tile);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                border: useRevealedBorber ? revealedBorder : tileBorder,
                                color: bgColor,
                              ),
                              width: _tileSize,
                              child: Center(
                                  child: Text(
                                display,
                                style: Theme.of(context).textTheme.bodyText2,
                              )))));
                    }

                    return SizedBox(
                      height: _tileSize,
                      child: Row(
                        children: rowItems,
                      ),
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
