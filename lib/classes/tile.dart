


import 'package:flutter/material.dart';

class Tile {
  bool isBomb;
  bool isFlagged;
  bool isRevealed;
  bool isClicked;
  int adjacentBombs;

  Tile({this.isBomb=false, this.isFlagged=false, this.isRevealed=false, this.isClicked=false, this.adjacentBombs=0});

  @override
  String toString() {
    if (isBomb) {
      return 'B';
    }
    return adjacentBombs.toString();
  }
}