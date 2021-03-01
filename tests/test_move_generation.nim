import unittest

import nim_chesspkg/board
import nim_chesspkg/piece

suite "move generation":
    test "pawn movement double":
        discard

suite "findKing":
    test "case 1":
        let board = board.fromFemPiecePlacement("K7/8/8/8/8/8/8/8")
        check findKing(board, PieceColor.white) == positionFromString("a8")
    test "case 2":
        let board = board.fromFemPiecePlacement("Kk6/8/8/8/8/8/8/8")
        check findKing(board, PieceColor.black) == positionFromString("b8")
        check findKing(board, PieceColor.white) == positionFromString("a8")

suite "isChecked":
    test "starting position":
        let board = board.fromFemPiecePlacement(board.STARTING_PIECES_FEM)
        check isChecked(board, PieceColor.black) == false
        check isChecked(board, PieceColor.white) == false

    test "pawn checking king":
        let board = board.fromFemPiecePlacement("k7/1P6/8/8/8/8/8/7K")
        check isChecked(board, PieceColor.black) == true
        check isChecked(board, PieceColor.white) == false
    
    test "queen gang":
        let board = board.fromFemPiecePlacement("Kq6/qq6/8/8/8/8/8/7k")
        check isChecked(board, PieceColor.black) == false
        check isChecked(board, PieceColor.white) == true