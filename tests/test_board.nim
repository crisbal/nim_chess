import unittest
import sequtils

import nim_chesspkg/board
import nim_chesspkg/piece

suite "board":
  test "empty":
    var b = empty()
    check b.allIt(type(it) == PieceType.none)

  test "fem_placement_starting":
    var b = from_fem_piece_placement("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
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

  test "fem_placement_e4":
    var b = from_fem_piece_placement("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR")
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