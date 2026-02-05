import unittest
import sequtils

import ../src/nim_chesspkg/board
import ../src/nim_chesspkg/piece

suite "board":
  test "empty":
    var b = empty()
    check b.allIt(type(it) == PieceType.none)

  test "fen_placement_starting":
    var b = fromFenPiecePlacement("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
    check b[0] == piece(PieceType.rook, PieceColor.black)
    check b[7] == piece(PieceType.rook, PieceColor.black)
    check b[56] == piece(PieceType.rook, PieceColor.white)
    check b[63] == piece(PieceType.rook, PieceColor.white)

  test "fen_placement_e4":
    var b = fromFenPiecePlacement("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR")
    check b[36] == piece(PieceType.pawn, PieceColor.white)
    check b[52] == Piece(0)

suite "findKing":
  test "white king at a8":
    var board = fromFenPiecePlacement("K7/8/8/8/8/8/8/8")
    check findKing(board, PieceColor.white) == positionFromAlgebric("a8")

  test "both kings":
    var board = fromFenPiecePlacement("Kk6/8/8/8/8/8/8/8")
    check findKing(board, PieceColor.black) == positionFromAlgebric("b8")
    check findKing(board, PieceColor.white) == positionFromAlgebric("a8")
