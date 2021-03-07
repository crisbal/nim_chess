import unittest
import sequtils

import nim_chesspkg/board
import nim_chesspkg/piece

suite "board":
  test "empty":
    var b = empty()
    check b.allIt(type(it) == PieceType.none)

  test "fen_placement_starting":
    var b = fromFenPiecePlacement("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
    check b == [
      piece(PieceType.rook, PieceColor.black), piece(PieceType.knight, PieceColor.black), piece(PieceType.bishop, PieceColor.black), piece(PieceType.queen, PieceColor.black), piece(PieceType.king, PieceColor.black), piece(PieceType.bishop, PieceColor.black), piece(PieceType.knight, PieceColor.black), piece(PieceType.rook, PieceColor.black),
      piece(PieceType.pawn, PieceColor.black), piece(PieceType.pawn, PieceColor.black), piece(PieceType.pawn, PieceColor.black), piece(PieceType.pawn, PieceColor.black), piece(PieceType.pawn, PieceColor.black), piece(PieceType.pawn, PieceColor.black), piece(PieceType.pawn, PieceColor.black), piece(PieceType.pawn, PieceColor.black),
      0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0,
      piece(PieceType.pawn, PieceColor.white), piece(PieceType.pawn, PieceColor.white), piece(PieceType.pawn, PieceColor.white), piece(PieceType.pawn, PieceColor.white), piece(PieceType.pawn, PieceColor.white), piece(PieceType.pawn, PieceColor.white), piece(PieceType.pawn, PieceColor.white), piece(PieceType.pawn, PieceColor.white),
      piece(PieceType.rook, PieceColor.white), piece(PieceType.knight, PieceColor.white), piece(PieceType.bishop, PieceColor.white), piece(PieceType.queen, PieceColor.white), piece(PieceType.king, PieceColor.white), piece(PieceType.bishop, PieceColor.white), piece(PieceType.knight, PieceColor.white), piece(PieceType.rook, PieceColor.white),
    ]

  test "fen_placement_e4":
    var b = fromFenPiecePlacement("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR")
    check b == [
      piece(PieceType.rook, PieceColor.black), piece(PieceType.knight, PieceColor.black), piece(PieceType.bishop, PieceColor.black), piece(PieceType.queen, PieceColor.black), piece(PieceType.king, PieceColor.black), piece(PieceType.bishop, PieceColor.black), piece(PieceType.knight, PieceColor.black), piece(PieceType.rook, PieceColor.black),
      piece(PieceType.pawn, PieceColor.black), piece(PieceType.pawn, PieceColor.black), piece(PieceType.pawn, PieceColor.black), piece(PieceType.pawn, PieceColor.black), piece(PieceType.pawn, PieceColor.black), piece(PieceType.pawn, PieceColor.black), piece(PieceType.pawn, PieceColor.black), piece(PieceType.pawn, PieceColor.black),
      0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, piece(PieceType.pawn, PieceColor.white), 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0,
      piece(PieceType.pawn, PieceColor.white), piece(PieceType.pawn, PieceColor.white), piece(PieceType.pawn, PieceColor.white), piece(PieceType.pawn, PieceColor.white), 0, piece(PieceType.pawn, PieceColor.white), piece(PieceType.pawn, PieceColor.white), piece(PieceType.pawn, PieceColor.white),
      piece(PieceType.rook, PieceColor.white), piece(PieceType.knight, PieceColor.white), piece(PieceType.bishop, PieceColor.white), piece(PieceType.queen, PieceColor.white), piece(PieceType.king, PieceColor.white), piece(PieceType.bishop, PieceColor.white), piece(PieceType.knight, PieceColor.white), piece(PieceType.rook, PieceColor.white),
    ]

suite "position":
  test "position to string":
    check repr(Position(0)) == "a8"
    check repr(Position((BOARD_HEIGHT * BOARD_HEIGHT)-1)) == "h1"

  test "position from string":
    check positionFromString("a8") == Position(0)
    check positionFromString("b8") == Position(1)
    check positionFromString("h8") == Position(7)
    check positionFromString("a7") == Position(8)
    check positionFromString("h7") == Position(8+7)
    check positionFromString("a1") == Position(BOARD_WIDTH*7)
    check positionFromString("h1") == Position((BOARD_HEIGHT*BOARD_WIDTH)-1)
    check repr(positionFromString("g3")) == "g3"
    check repr(positionFromString("f1")) == "f1"

suite "move":
  test "move to string":
    check $(positionFromString("a8"), positionFromString("b8")) == "a8b8"
    check $(positionFromString("a1"), positionFromString("f4")) == "a1f4"

  test "move from string":
    check moveFromString("a8h1") == (positionFromString("a8"), positionFromString("h1"))
    check moveFromString("f8b3") == (positionFromString("f8"), positionFromString("b3"))