import unittest

import nim_chesspkg/board
import nim_chesspkg/piece

suite "move generation":
    test "pawn movement double":
        discard

suite "findKing":
    test "case 1":
        var board = board.fromFenPiecePlacement("K7/8/8/8/8/8/8/8")
        check findKing(board, PieceColor.white) == positionFromString("a8")
    test "case 2":
        var board = board.fromFenPiecePlacement("Kk6/8/8/8/8/8/8/8")
        check findKing(board, PieceColor.black) == positionFromString("b8")
        check findKing(board, PieceColor.white) == positionFromString("a8")

suite "isChecked/isCheckmated":
    test "starting position":
        var board = board.fromFenPiecePlacement(board.STARTING_PIECES_FEM)
        check isChecked(board, PieceColor.black) == false
        check isChecked(board, PieceColor.white) == false

    test "pawn checking king":
        var board = board.fromFenPiecePlacement("k7/1P6/8/8/8/8/8/7K")
        check isChecked(board, PieceColor.black) == true
        check isCheckmated(board, PieceColor.black) == false
        check isChecked(board, PieceColor.white) == false

    test "queen gang":
        var board = board.fromFenPiecePlacement("Kq6/qq6/8/8/8/8/8/7k")
        check isChecked(board, PieceColor.black) == false
        check isChecked(board, PieceColor.white) == true
        check isCheckmated(board, PieceColor.white) == true