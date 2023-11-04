import 'dart:math';

import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class Connect4 extends StatefulWidget {
  final Function changeAppBar;

  const Connect4({super.key, required this.changeAppBar});

  @override
  State<Connect4> createState() => _Connect4State();
}

class _Connect4State extends State<Connect4> {
  int gridRows = 6;
  int gridColumns = 7;
  List<List<int>> connectFourGrid = [[]];

  int? hoverRow;
  int? hoverCol;

  bool playerOneTurn = true;

  String arrowDir = '';

  @override
  initState() {
    super.initState();
    connectFourGrid = List.generate(gridRows, (i) => List.filled(gridColumns, 0));
  }

  double calculateDistance(double x1, double y1, double x2, double y2) {
    double deltaX = x2 - x1;
    double deltaY = y2 - y1;
    return sqrt(deltaX * deltaX + deltaY * deltaY);
  }

  handleTap(int row, int col) async {
    print('tapped: $row, $col');
    print('arrowDir: ' + arrowDir);
    // place piece at bottom of column
    if (connectFourGrid[row][col] != 0) {
      return;
    }
    String direction = arrowDir;
    if (direction.isEmpty) {
      direction = await checkOrientation();
    }
    if (row == 0 && (direction == 'd' || direction.isEmpty)) {
      // drop token down
      for (var i = 0; i < gridRows; i++) {
        if (connectFourGrid[i][col] == 0) {
          connectFourGrid[i][col] = playerOneTurn ? 1 : 2;
          setState(() {});
          await Future.delayed(const Duration(milliseconds: 10));
          connectFourGrid[i][col] = 0;
          row = i;
        } else {
          break;
        }
      }
    } else if (row == gridRows - 1 && (direction == 'u' || direction.isEmpty)) {
      // drop token up lol
      for (var i = gridRows - 1; i >= 0; i--) {
        if (connectFourGrid[i][col] == 0) {
          connectFourGrid[i][col] = playerOneTurn ? 1 : 2;
          setState(() {});
          await Future.delayed(Duration(milliseconds: 10));
          connectFourGrid[i][col] = 0;
          row = i;
        } else {
          break;
        }
      }
    } else if (col == 0 && (direction == 'r' || direction.isEmpty)) {
      //drop token to right lol
      for (var i = 0; i < gridColumns; i++) {
        if (connectFourGrid[row][i] == 0) {
          connectFourGrid[row][i] = playerOneTurn ? 1 : 2;
          setState(() {});
          await Future.delayed(Duration(milliseconds: 10));
          connectFourGrid[row][i] = 0;
          col = i;
        } else {
          break;
        }
      }
    } else if (col == gridColumns - 1 && (direction == 'l' || direction.isEmpty)) {
      print('yaa');
      //drop token to left lol
      for (var i = gridColumns - 1; i >= 0; i--) {
        if (connectFourGrid[row][i] == 0) {
          connectFourGrid[row][i] = playerOneTurn ? 1 : 2;
          setState(() {});
          await Future.delayed(Duration(milliseconds: 10));
          connectFourGrid[row][i] = 0;
          col = i;
        } else {
          break;
        }
      }
    } else {
      print('no');
      return;
    }
    if (playerOneTurn) {
      connectFourGrid[row][col] = 1;
    } else {
      connectFourGrid[row][col] = 2;
    }
    bool won = checkForFourInARow();
    print('won: ' + won.toString());
    if (won) {
      // show alert dialog
      setState(() {});
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Player ${playerOneTurn ? 1 : 2} won!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Play Again'),
              ),
            ],
          );
        },
      );
      connectFourGrid = List.generate(gridRows, (i) => List.filled(gridColumns, 0));
      playerOneTurn = true;
      hoverCol = null;
      hoverRow = null;
      arrowDir = '';
    } else {
      playerOneTurn = !playerOneTurn;
    }

    widget.changeAppBar(
        color: playerOneTurn ? Colors.red : Colors.yellow, title: playerOneTurn ? 'Red\'s Turn' : 'Yellow\'s Turn');
    // setState(() {});
  }

  bool checkForFourInARow() {
    // check for four in a row
    int checkingFor = playerOneTurn ? 1 : 2;

    int inARow = 0;
    for (var i = gridRows - 1; i >= 0; i--) {
      for (var j = gridColumns - 1; j >= 0; j--) {
        if (connectFourGrid[i][j] == checkingFor) {
          inARow++;
          if (inARow == 4) {
            return true;
          }
        } else {
          inARow = 0;
        }
      }
    }
    // check for four in a column
    inARow = 0;
    for (var i = gridColumns - 1; i >= 0; i--) {
      for (var j = gridRows - 1; j >= 0; j--) {
        if (connectFourGrid[j][i] == checkingFor) {
          inARow++;
          if (inARow == 4) {
            return true;
          }
        } else {
          inARow = 0;
        }
      }
    }
    // check for four in a diagonal
    inARow = 0;
    for (var i = 0; i < gridRows - 3; i++) {
      for (var j = 3; j < gridColumns; j++) {
        if (connectFourGrid[i][j] == (playerOneTurn ? 1 : 2) &&
            connectFourGrid[i + 1][j - 1] == (playerOneTurn ? 1 : 2) &&
            connectFourGrid[i + 2][j - 2] == (playerOneTurn ? 1 : 2) &&
            connectFourGrid[i + 3][j - 3] == (playerOneTurn ? 1 : 2)) {
          return true;
        }
      }
      for (var j = 0; j < gridColumns - 3; j++) {
        if (connectFourGrid[i][j] == (playerOneTurn ? 1 : 2) &&
            connectFourGrid[i + 1][j + 1] == (playerOneTurn ? 1 : 2) &&
            connectFourGrid[i + 2][j + 2] == (playerOneTurn ? 1 : 2) &&
            connectFourGrid[i + 3][j + 3] == (playerOneTurn ? 1 : 2)) {
          return true;
        }
      }
    }

    return false;
  }

  // Move all pieces in a direction
  gravity(direction) async {
    if (direction == 'u') {
      // Move all pieces up
      for (var r = 1; r < gridRows; r++) {
        for (var c = gridColumns - 1; c >= 0; c--) {
          if (connectFourGrid[r][c] != 0) {
            int moveNum = connectFourGrid[r][c];
            connectFourGrid[r][c] = 0;
            int checkRow = r - 1;
            while (connectFourGrid[checkRow][c] == 0 && checkRow > 0) {
              connectFourGrid[checkRow][c] = moveNum;
              setState(() {});
              await Future.delayed(Duration(milliseconds: 10));
              connectFourGrid[checkRow][c] = 0;

              checkRow--;
            }
            if (connectFourGrid[checkRow][c] != 0) {
              checkRow++;
            }
            connectFourGrid[checkRow][c] = moveNum;
          }
        }
      }
    } else if (direction == 'd') {
      // Move all pieces down
      for (var r = gridRows - 2; r >= 0; r--) {
        for (var c = gridColumns - 1; c >= 0; c--) {
          if (connectFourGrid[r][c] != 0) {
            int moveNum = connectFourGrid[r][c];
            connectFourGrid[r][c] = 0;
            int checkRow = r + 1;
            while (connectFourGrid[checkRow][c] == 0 && checkRow < gridRows - 1) {
              connectFourGrid[checkRow][c] = moveNum;
              setState(() {});
              await Future.delayed(Duration(milliseconds: 10));
              connectFourGrid[checkRow][c] = 0;

              checkRow++;
            }
            if (connectFourGrid[checkRow][c] != 0) {
              checkRow--;
            }
            connectFourGrid[checkRow][c] = moveNum;
          }
        }
      }
    } else if (direction == 'l') {
      // Move all pieces left
      for (var c = 1; c < gridColumns; c++) {
        for (var r = 0; r < gridRows; r++) {
          if (connectFourGrid[r][c] != 0) {
            int moveNum = connectFourGrid[r][c];
            connectFourGrid[r][c] = 0;
            int checkCol = c - 1;
            while (connectFourGrid[r][checkCol] == 0 && checkCol > 0) {
              connectFourGrid[r][checkCol] = moveNum;
              setState(() {});
              await Future.delayed(Duration(milliseconds: 10));
              connectFourGrid[r][checkCol] = 0;

              checkCol--;
            }
            if (connectFourGrid[r][checkCol] != 0) {
              checkCol++;
            }
            connectFourGrid[r][checkCol] = moveNum;
          }
        }
      }
    } else if (direction == 'r') {
      // Move all pieces right
      for (var c = gridColumns - 2; c >= 0; c--) {
        for (var r = 0; r < gridRows; r++) {
          if (connectFourGrid[r][c] != 0) {
            int moveNum = connectFourGrid[r][c];
            connectFourGrid[r][c] = 0;
            int checkCol = c + 1;
            while (connectFourGrid[r][checkCol] == 0 && checkCol < gridColumns - 1) {
              connectFourGrid[r][checkCol] = moveNum;
              setState(() {});
              await Future.delayed(Duration(milliseconds: 10));
              connectFourGrid[r][checkCol] = 0;

              checkCol++;
            }
            if (connectFourGrid[r][checkCol] != 0) {
              checkCol--;
            }
            connectFourGrid[r][checkCol] = moveNum;
          }
        }
      }
    }
    setState(() {});
  }

  Future<String> checkOrientation() async {
    print('checkOrientation');
    try {
      final orientation = await NativeDeviceOrientationCommunicator().orientation(useSensor: true);
      print(orientation);
      if (orientation == NativeDeviceOrientation.portraitDown) {
        return 'u';
      } else if (orientation == NativeDeviceOrientation.portraitUp) {
        return 'd';
      } else if (orientation == NativeDeviceOrientation.landscapeLeft) {
        return 'l';
      } else if (orientation == NativeDeviceOrientation.landscapeRight) {
        return 'r';
      }
    } catch (err) {
      print(err);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width - 88;
    double screenHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height;
    // TODO: Factor in padding of each thingy
    double cellWidth = ((screenWidth * 0.75 / gridColumns).floor()).toDouble();
    double cellHeight = (screenHeight * 0.75 / gridRows).floor().toDouble();
    double cellSize = cellHeight < cellWidth ? cellHeight : cellWidth;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(playerOneTurn ? 'Red\'s Turn' : 'Yellow\'s Turn'),
      //   backgroundColor: playerOneTurn ? Colors.red : Colors.yellow,
      // ),
      body: Row(children: [
        Expanded(
          child: Container(
            color: Colors.blue,
            child: ListView.builder(
                itemCount: gridRows,
                itemBuilder: (context, rowIndex) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var colIndex = 0; colIndex < gridColumns; colIndex++)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              handleTap(rowIndex, colIndex);
                            },
                            child: MouseRegion(
                              onHover: (event) {
                                // print(rowIndex);
                                if (rowIndex == 0) {
                                  arrowDir = 'd';
                                  if (colIndex == 0) {
                                    final mouseX = event.localPosition.dx;
                                    final mouseY = event.localPosition.dy;
                                    // print('mousePosition: ' + mousePosition.toString());

                                    arrowDir = calculateDistance(0, cellSize, mouseX, mouseY) <
                                            calculateDistance(cellSize, 0, mouseX, mouseY)
                                        ? 'r'
                                        : 'd';
                                  } else if (colIndex == gridColumns - 1) {
                                    // print('rightcols');
                                    final mouseX = event.localPosition.dx;
                                    final mouseY = event.localPosition.dy;
                                    // print('mousePosition: ' + mousePosition.toString());

                                    arrowDir = calculateDistance(0, 0, mouseX, mouseY) <
                                            calculateDistance(cellSize, cellSize, mouseX, mouseY)
                                        ? 'd'
                                        : 'l';
                                    // print('arrowDir: ' + arrowDir);
                                  }
                                  hoverCol = colIndex;
                                  hoverRow = 0;
                                } else if (rowIndex == gridRows - 1) {
                                  arrowDir = 'u';

                                  if (colIndex == 0) {
                                    final mouseX = event.localPosition.dx;
                                    final mouseY = event.localPosition.dy;
                                    // print('mousePosition:');
                                    arrowDir = calculateDistance(0, 0, mouseX, mouseY) <
                                            calculateDistance(cellSize, cellSize, mouseX, mouseY)
                                        ? 'r'
                                        : 'u';
                                  } else if (colIndex == gridColumns - 1) {
                                    // print('rightcols');
                                    final mouseX = event.localPosition.dx;
                                    final mouseY = event.localPosition.dy;

                                    arrowDir = calculateDistance(0, cellSize, mouseX, mouseY) <
                                            calculateDistance(cellSize, 0, mouseX, mouseY)
                                        ? 'u'
                                        : 'l';
                                    // print('arrowDir: ' + arrowDir);
                                  }
                                  hoverCol = colIndex;
                                  hoverRow = rowIndex;
                                } else if (colIndex == 0) {
                                  arrowDir = 'r';
                                  hoverCol = 0;
                                  hoverRow = rowIndex;
                                } else if (colIndex == gridColumns - 1) {
                                  arrowDir = 'l';
                                  hoverCol = gridColumns - 1;
                                  hoverRow = rowIndex;
                                } else {
                                  hoverCol = null;
                                  hoverRow = null;
                                  arrowDir = '';
                                }
                                setState(() {});
                              },
                              onExit: (event) {
                                // print('exited');
                                hoverCol = null;
                                hoverRow = null;
                                arrowDir = '';
                                setState(() {});
                              },
                              child: CellWidget(
                                  size: cellSize,
                                  contains: connectFourGrid[rowIndex][colIndex],
                                  showArrow: colIndex == hoverCol && rowIndex == hoverRow ? arrowDir : '',
                                  turnColor: playerOneTurn ? Colors.red : Colors.yellow),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
          ),
        ),
        Column(
          children: [
            Text('Grav', style: TextStyle(color: Colors.black)),
            IconButton(
                onPressed: () {
                  gravity('u');
                },
                icon: Icon(Icons.keyboard_arrow_up)),
            IconButton(
                onPressed: () {
                  gravity('d');
                },
                icon: Icon(Icons.keyboard_arrow_down)),
            IconButton(
                onPressed: () {
                  gravity('l');
                },
                icon: Icon(Icons.keyboard_arrow_left)),
            IconButton(
                onPressed: () {
                  gravity('r');
                },
                icon: Icon(Icons.keyboard_arrow_right)),
          ],
        )
      ]),
    );
  }
}

class CellWidget extends StatelessWidget {
  final double size;
  final Color turnColor;
  final int contains;
  final String showArrow;

  const CellWidget(
      {super.key, required this.size, required this.contains, this.showArrow = '', this.turnColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    IconData arrowIcon = Icons.keyboard_arrow_down;
    // print(showArrow);
    if (showArrow == 'r') {
      arrowIcon = Icons.keyboard_arrow_right;
    } else if (showArrow == 'l') {
      arrowIcon = Icons.keyboard_arrow_left;
    } else if (showArrow == 'u') {
      arrowIcon = Icons.keyboard_arrow_up;
    }
    return Container(
        width: size, // Adjust to your cell size
        height: size,
        decoration: BoxDecoration(
          color: contains == 2 ? Colors.yellow : (contains == 1 ? Colors.red : Colors.white),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: contains != 0 || showArrow == '' ? null : Icon(arrowIcon, color: turnColor, size: 100),
        ));
  }
}
