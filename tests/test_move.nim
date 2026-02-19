import unittest

import ../src/nim_chesspkg/board
import ../src/nim_chesspkg/move

suite "position":
  test "position to string":
    check toAlgebraic(Position(0)) == "a8"
    check toAlgebraic(Position((BOARD_HEIGHT * BOARD_HEIGHT) - 1)) == "h1"

  test "position from string":
    check positionFromAlgebric("a8") == Position(0)
    check positionFromAlgebric("b8") == Position(1)
    check positionFromAlgebric("h8") == Position(7)
    check positionFromAlgebric("a7") == Position(8)
    check positionFromAlgebric("h7") == Position(8 + 7)
    check positionFromAlgebric("a1") == Position(BOARD_WIDTH * 7)
    check positionFromAlgebric("h1") == Position((BOARD_HEIGHT * BOARD_WIDTH) - 1)
    check toAlgebraic(positionFromAlgebric("g3")) == "g3"
    check toAlgebraic(positionFromAlgebric("f1")) == "f1"

suite "move":
  test "move to string":
    check $newMove(positionFromAlgebric("a8"), positionFromAlgebric("b8")) == "a8b8"
    check $newMove(positionFromAlgebric("a1"), positionFromAlgebric("f4")) == "a1f4"

  test "move from string":
    check moveFromLongAlgebric("a8h1") == newMove(positionFromAlgebric("a8"), positionFromAlgebric("h1"))
    check moveFromLongAlgebric("f8b3") == newMove(positionFromAlgebric("f8"), positionFromAlgebric("b3"))

suite "moveFromLongAlgebric":
  test "simple 4-char move (no separator)":
    let m = moveFromLongAlgebric("e2e4")
    check m.source == positionFromAlgebric("e2")
    check m.target == positionFromAlgebric("e4")
    check m.kind == Quiet

  test "pawn move with dash separator":
    let m = moveFromLongAlgebric("e2-e4")
    check m.source == positionFromAlgebric("e2")
    check m.target == positionFromAlgebric("e4")
    check m.kind == Quiet

  test "pawn capture with x separator":
    let m = moveFromLongAlgebric("e4xd5")
    check m.source == positionFromAlgebric("e4")
    check m.target == positionFromAlgebric("d5")
    check m.kind == Captures

  test "knight move with piece symbol":
    let m = moveFromLongAlgebric("Ng1-f3")
    check m.source == positionFromAlgebric("g1")
    check m.target == positionFromAlgebric("f3")
    check m.kind == Quiet

  test "knight capture with piece symbol":
    let m = moveFromLongAlgebric("Nf3xe5")
    check m.source == positionFromAlgebric("f3")
    check m.target == positionFromAlgebric("e5")
    check m.kind == Captures

  test "bishop move":
    let m = moveFromLongAlgebric("Bc1-f4")
    check m.source == positionFromAlgebric("c1")
    check m.target == positionFromAlgebric("f4")
    check m.kind == Quiet

  test "rook move":
    let m = moveFromLongAlgebric("Ra1-a7")
    check m.source == positionFromAlgebric("a1")
    check m.target == positionFromAlgebric("a7")
    check m.kind == Quiet

  test "queen move":
    let m = moveFromLongAlgebric("Qd1-h5")
    check m.source == positionFromAlgebric("d1")
    check m.target == positionFromAlgebric("h5")
    check m.kind == Quiet

  test "king move":
    let m = moveFromLongAlgebric("Ke1-e2")
    check m.source == positionFromAlgebric("e1")
    check m.target == positionFromAlgebric("e2")
    check m.kind == Quiet

  test "pawn promotion to queen":
    let m = moveFromLongAlgebric("e7-e8Q")
    check m.source == positionFromAlgebric("e7")
    check m.target == positionFromAlgebric("e8")
    check m.kind == QueenPromotion

  test "pawn promotion to knight":
    let m = moveFromLongAlgebric("a7-a8N")
    check m.source == positionFromAlgebric("a7")
    check m.target == positionFromAlgebric("a8")
    check m.kind == KnightPromotion

  test "pawn promotion to rook":
    let m = moveFromLongAlgebric("h7-h8R")
    check m.source == positionFromAlgebric("h7")
    check m.target == positionFromAlgebric("h8")
    check m.kind == RookPromotion

  test "pawn promotion to bishop":
    let m = moveFromLongAlgebric("b7-b8B")
    check m.source == positionFromAlgebric("b7")
    check m.target == positionFromAlgebric("b8")
    check m.kind == BishopPromotion

  test "pawn capture with promotion to queen":
    let m = moveFromLongAlgebric("e7xd8Q")
    check m.source == positionFromAlgebric("e7")
    check m.target == positionFromAlgebric("d8")
    check m.kind == QueenPromoCapture

  test "pawn capture with promotion to knight":
    let m = moveFromLongAlgebric("a7xb8N")
    check m.source == positionFromAlgebric("a7")
    check m.target == positionFromAlgebric("b8")
    check m.kind == KnightPromoCapture

  test "pawn capture with promotion to rook":
    let m = moveFromLongAlgebric("h7xg8R")
    check m.source == positionFromAlgebric("h7")
    check m.target == positionFromAlgebric("g8")
    check m.kind == RookPromoCapture

  test "pawn capture with promotion to bishop":
    let m = moveFromLongAlgebric("b7xa8B")
    check m.source == positionFromAlgebric("b7")
    check m.target == positionFromAlgebric("a8")
    check m.kind == BishopPromoCapture

  test "piece move without separator":
    let m = moveFromLongAlgebric("Ng1f3")
    check m.source == positionFromAlgebric("g1")
    check m.target == positionFromAlgebric("f3")
    check m.kind == Quiet

  test "pawn promotion without separator":
    let m = moveFromLongAlgebric("e7e8Q")
    check m.source == positionFromAlgebric("e7")
    check m.target == positionFromAlgebric("e8")
    check m.kind == QueenPromotion

  test "white kingside castling":
    let m = moveFromLongAlgebric("e1g1")
    check m.source == positionFromAlgebric("e1")
    check m.target == positionFromAlgebric("g1")
    check m.kind == KingCastle

  test "white queenside castling":
    let m = moveFromLongAlgebric("e1c1")
    check m.source == positionFromAlgebric("e1")
    check m.target == positionFromAlgebric("c1")
    check m.kind == QueenCastle

  test "black kingside castling":
    let m = moveFromLongAlgebric("e8g8")
    check m.source == positionFromAlgebric("e8")
    check m.target == positionFromAlgebric("g8")
    check m.kind == KingCastle

  test "black queenside castling":
    let m = moveFromLongAlgebric("e8c8")
    check m.source == positionFromAlgebric("e8")
    check m.target == positionFromAlgebric("c8")
    check m.kind == QueenCastle
