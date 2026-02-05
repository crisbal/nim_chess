import unittest

import ../src/nim_chesspkg/board
import ../src/nim_chesspkg/piece
import ../src/nim_chesspkg/game
import ../src/nim_chesspkg/move

# suite "isChecked/isCheckmated":
#   test "starting position":
#     var board = board.fromFenPiecePlacement(board.STARTING_PIECES_FEN)
#     check isChecked(board, PieceColor.black) == false
#     check isChecked(board, PieceColor.white) == false

#   test "pawn checking king":
#     var board = board.fromFenPiecePlacement("k7/1P6/8/8/8/8/8/7K")
#     check isChecked(board, PieceColor.black) == true
#     check isCheckmated(board, PieceColor.black) == false
#     check isChecked(board, PieceColor.white) == false

#   test "queen gang":
#     var board = board.fromFenPiecePlacement("Kq6/qq6/8/8/8/8/8/7k")
#     check isChecked(board, PieceColor.black) == false
#     check isChecked(board, PieceColor.white) == true
#     check isCheckmated(board, PieceColor.white) == true

suite "generateMoves":
  test "starting position // pawn movement":
    var game = game.fromFen(game.STARTING_FEN)
    let moves = generateMoves(game)
    for letter in 'a' .. 'h':
      check moves.contains(newMove(positionFromAlgebric($letter & "2"), positionFromAlgebric($letter & "3"), Quiet))
      check moves.contains(newMove(positionFromAlgebric($letter & "2"), positionFromAlgebric($letter & "4"), DoublePawnPush))
  test "starting position // knight movement":
    var game = game.fromFen(game.STARTING_FEN)
    let moves = generateMoves(game)
    check moves.contains(newMove(positionFromAlgebric("b1"), positionFromAlgebric("a3"), Quiet))
    check moves.contains(newMove(positionFromAlgebric("b1"), positionFromAlgebric("c3"), Quiet))
    check moves.contains(newMove(positionFromAlgebric("g1"), positionFromAlgebric("f3"), Quiet))
    check moves.contains(newMove(positionFromAlgebric("g1"), positionFromAlgebric("h3"), Quiet))
  test "starting position // no bishop movement":
    var game = game.fromFen(game.STARTING_FEN)
    let moves = generateMoves(game)
    check not moves.contains(newMove(positionFromAlgebric("c1"), positionFromAlgebric("b2"), Quiet))
    check not moves.contains(newMove(positionFromAlgebric("c1"), positionFromAlgebric("a3"), Quiet))
    check not moves.contains(newMove(positionFromAlgebric("f1"), positionFromAlgebric("e2"), Quiet))
    check not moves.contains(newMove(positionFromAlgebric("f1"), positionFromAlgebric("g2"), Quiet))
  # TODO: starting position // no queen, no king, no rook movement

  test "no pawns // king movement":
    var game = game.fromFen("rnbqkbnr/8/8/8/8/8/8/RNBQKBNR w KQkq - 0 1")
    let moves = generateMoves(game)
    # King is not allowed to move into check from black queen
    check not moves.contains(newMove(positionFromAlgebric("e1"), positionFromAlgebric("d2"), Quiet))
    check moves.contains(newMove(positionFromAlgebric("e1"), positionFromAlgebric("e2"), Quiet))
    check moves.contains(newMove(positionFromAlgebric("e1"), positionFromAlgebric("f2"), Quiet))

  test "no pawns // rook movement":
    var game = game.fromFen("rnbqkbnr/8/8/8/8/8/8/RNBQKBNR w KQkq - 0 1")
    let moves = generateMoves(game)
    for row in 2 .. 7:
      check moves.contains(newMove(positionFromAlgebric("a1"), positionFromAlgebric("a" & $row), Quiet))
      check moves.contains(newMove(positionFromAlgebric("h1"), positionFromAlgebric("h" & $row), Quiet))
    # Row 8 has black pieces, so these are captures
    check moves.contains(newMove(positionFromAlgebric("a1"), positionFromAlgebric("a8"), Captures))
    check moves.contains(newMove(positionFromAlgebric("h1"), positionFromAlgebric("h8"), Captures))

  test "no pawns // bishop movement":
    var game = game.fromFen("rnbqkbnr/8/8/8/8/8/8/RNBQKBNR w KQkq - 0 1")
    let moves = generateMoves(game)
    # short diagonal
    check moves.contains(newMove(positionFromAlgebric("c1"), positionFromAlgebric("b2"), Quiet))
    check moves.contains(newMove(positionFromAlgebric("c1"), positionFromAlgebric("a3"), Quiet))
    # long diagonal
    check moves.contains(newMove(positionFromAlgebric("c1"), positionFromAlgebric("d2"), Quiet))
    check moves.contains(newMove(positionFromAlgebric("c1"), positionFromAlgebric("e3"), Quiet))
    check moves.contains(newMove(positionFromAlgebric("c1"), positionFromAlgebric("f4"), Quiet))
    check moves.contains(newMove(positionFromAlgebric("c1"), positionFromAlgebric("g5"), Quiet))
    check moves.contains(newMove(positionFromAlgebric("c1"), positionFromAlgebric("h6"), Quiet))

    # short diagonal
    check moves.contains(newMove(positionFromAlgebric("f1"), positionFromAlgebric("g2"), Quiet))
    check moves.contains(newMove(positionFromAlgebric("f1"), positionFromAlgebric("h3"), Quiet))
    # long diagonal
    check moves.contains(newMove(positionFromAlgebric("f1"), positionFromAlgebric("e2"), Quiet))
    check moves.contains(newMove(positionFromAlgebric("f1"), positionFromAlgebric("d3"), Quiet))
    check moves.contains(newMove(positionFromAlgebric("f1"), positionFromAlgebric("c4"), Quiet))
    check moves.contains(newMove(positionFromAlgebric("f1"), positionFromAlgebric("b5"), Quiet))
    check moves.contains(newMove(positionFromAlgebric("f1"), positionFromAlgebric("a6"), Quiet))

  # TODO: no pawns // queen movement
  # TODO: no pawns // knight movement

  test "castling // white king short castle":
    var game = game.fromFen("4k3/8/8/8/8/8/8/4K2R w K - 0 1")
    let moves = generateMoves(game)
    check moves.contains(newMove(positionFromAlgebric("e1"), positionFromAlgebric("g1"), KingCastle))

  test "castling // white king long castle":
    var game = game.fromFen("4k3/8/8/8/8/8/8/R3K3 w Q - 0 1")
    let moves = generateMoves(game)
    check moves.contains(newMove(positionFromAlgebric("e1"), positionFromAlgebric("c1"), QueenCastle))

  test "castling // black king short castle":
    var game = game.fromFen("4k2r/8/8/8/8/8/8/4K3 b k - 0 1")
    let moves = generateMoves(game)
    check moves.contains(newMove(positionFromAlgebric("e8"), positionFromAlgebric("g8"), KingCastle))

  test "castling // black king long castle":
    var game = game.fromFen("r3k3/8/8/8/8/8/8/4K3 b q - 0 1")
    let moves = generateMoves(game)
    check moves.contains(newMove(positionFromAlgebric("e8"), positionFromAlgebric("c8"), QueenCastle))

  # TODO: implement castling check validation
  # test "castling // can't castle if in check":
  #   var game = game.fromFen("4k3/4q3/8/8/8/8/8/4K2R w K - 0 1")
  #   let moves = generateMoves(game)
  #   check not moves.contains(newMove(positionFromAlgebric("e1"), positionFromAlgebric("g1"), KingCastle))

  # test "castling // can't castle if path under attack":
  #   var game = game.fromFen("4k3/5q2/8/8/8/8/8/4K2R w K - 0 1")
  #   let moves = generateMoves(game)
  #   check not moves.contains(newMove(positionFromAlgebric("e1"), positionFromAlgebric("g1"), KingCastle))

  test "castling // can't castle if no rights":
    var game = game.fromFen("4k3/8/8/8/8/8/8/4K2R w - - 0 1")
    let moves = generateMoves(game)
    check not moves.contains(newMove(positionFromAlgebric("e1"), positionFromAlgebric("g1"), KingCastle))
