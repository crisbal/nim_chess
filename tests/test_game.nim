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

suite "isAttacked":
  test "pawn attacks // white pawn attacking diagonally":
    var board = board.fromFenPiecePlacement("8/8/8/8/3n4/2P5/8/8")
    let knightPos = positionFromAlgebric("d4")
    check isAttacked(board, knightPos, PieceColor.white) == true

  test "pawn attacks // white pawn NOT attacking straight ahead":
    var board = board.fromFenPiecePlacement("8/8/8/3n4/3P4/8/8/8")
    let knightPos = positionFromAlgebric("d5")
    check isAttacked(board, knightPos, PieceColor.white) == false

  test "pawn attacks // black pawn attacking diagonally":
    var board = board.fromFenPiecePlacement("8/8/5p2/4N3/8/8/8/8")
    let knightPos = positionFromAlgebric("e5")
    check isAttacked(board, knightPos, PieceColor.black) == true

  test "pawn attacks // black pawn NOT attacking straight ahead":
    var board = board.fromFenPiecePlacement("8/8/4p3/4N3/8/8/8/8")
    let knightPos = positionFromAlgebric("e5")
    check isAttacked(board, knightPos, PieceColor.black) == false

  test "pawn attacks // both diagonals":
    var board = board.fromFenPiecePlacement("8/8/8/8/3n4/2P1P3/8/8")
    let knightPos = positionFromAlgebric("d4")
    check isAttacked(board, knightPos, PieceColor.white) == true

  test "pawn attacks // no wrap-around at board edge":
    var board = board.fromFenPiecePlacement("8/8/8/8/7n/P7/8/8")
    let knightPos = positionFromAlgebric("h4")
    check isAttacked(board, knightPos, PieceColor.white) == false

  test "knight attacks // all 8 possible knight moves":
    var board = board.fromFenPiecePlacement("8/8/8/3N4/8/8/8/8")
    # Knight on d5 attacks these squares
    check isAttacked(board, positionFromAlgebric("c7"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("e7"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("b6"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("f6"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("b4"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("f4"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("c3"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("e3"), PieceColor.white) == true

  test "knight attacks // does NOT attack adjacent squares":
    var board = board.fromFenPiecePlacement("8/8/8/3N4/8/8/8/8")
    check isAttacked(board, positionFromAlgebric("d6"), PieceColor.white) == false
    check isAttacked(board, positionFromAlgebric("e5"), PieceColor.white) == false
    check isAttacked(board, positionFromAlgebric("d4"), PieceColor.white) == false
    check isAttacked(board, positionFromAlgebric("c5"), PieceColor.white) == false

  test "knight attacks // no wrap-around at board edge":
    var board = board.fromFenPiecePlacement("7N/8/8/8/8/8/8/8")
    check isAttacked(board, positionFromAlgebric("a7"), PieceColor.white) == false
    check isAttacked(board, positionFromAlgebric("b8"), PieceColor.white) == false

  test "rook attacks // horizontal and vertical lines":
    var board = board.fromFenPiecePlacement("8/8/8/3R4/8/8/8/8")
    # Vertical attacks
    check isAttacked(board, positionFromAlgebric("d1"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("d4"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("d8"), PieceColor.white) == true
    # Horizontal attacks
    check isAttacked(board, positionFromAlgebric("a5"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("h5"), PieceColor.white) == true

  test "rook attacks // does NOT attack diagonals":
    var board = board.fromFenPiecePlacement("8/8/8/3R4/8/8/8/8")
    check isAttacked(board, positionFromAlgebric("c6"), PieceColor.white) == false
    check isAttacked(board, positionFromAlgebric("e6"), PieceColor.white) == false
    check isAttacked(board, positionFromAlgebric("b3"), PieceColor.white) == false

  test "rook attacks // blocked by piece":
    var board = board.fromFenPiecePlacement("8/8/8/3R4/3p4/8/8/8")
    check isAttacked(board, positionFromAlgebric("d4"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("d3"), PieceColor.white) == false
    check isAttacked(board, positionFromAlgebric("d2"), PieceColor.white) == false
    check isAttacked(board, positionFromAlgebric("d1"), PieceColor.white) == false

  test "bishop attacks // diagonal lines":
    var board = board.fromFenPiecePlacement("8/8/8/3B4/8/8/8/8")
    # All four diagonals
    check isAttacked(board, positionFromAlgebric("a2"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("f7"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("a8"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("g2"), PieceColor.white) == true

  test "bishop attacks // does NOT attack orthogonals":
    var board = board.fromFenPiecePlacement("8/8/8/3B4/8/8/8/8")
    check isAttacked(board, positionFromAlgebric("d1"), PieceColor.white) == false
    check isAttacked(board, positionFromAlgebric("d8"), PieceColor.white) == false
    check isAttacked(board, positionFromAlgebric("a5"), PieceColor.white) == false
    check isAttacked(board, positionFromAlgebric("h5"), PieceColor.white) == false

  test "bishop attacks // blocked by piece":
    var board = board.fromFenPiecePlacement("8/8/8/3B4/2p5/8/8/8")
    check isAttacked(board, positionFromAlgebric("c4"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("b3"), PieceColor.white) == false
    check isAttacked(board, positionFromAlgebric("a2"), PieceColor.white) == false

  test "queen attacks // combines rook and bishop":
    var board = board.fromFenPiecePlacement("8/8/8/3Q4/8/8/8/8")
    # Horizontal and vertical (rook moves)
    check isAttacked(board, positionFromAlgebric("d1"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("a5"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("h5"), PieceColor.white) == true
    # Diagonals (bishop moves)
    check isAttacked(board, positionFromAlgebric("a2"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("g8"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("a8"), PieceColor.white) == true

  test "queen attacks // blocked by piece":
    var board = board.fromFenPiecePlacement("8/8/8/3Q4/3p4/8/8/8")
    check isAttacked(board, positionFromAlgebric("d4"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("d3"), PieceColor.white) == false

  test "king attacks // all 8 adjacent squares":
    var board = board.fromFenPiecePlacement("8/8/8/3K4/8/8/8/8")
    check isAttacked(board, positionFromAlgebric("c5"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("d6"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("e6"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("e5"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("e4"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("d4"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("c4"), PieceColor.white) == true
    check isAttacked(board, positionFromAlgebric("c6"), PieceColor.white) == true

  test "king attacks // does NOT attack two squares away":
    var board = board.fromFenPiecePlacement("8/8/8/3K4/8/8/8/8")
    check isAttacked(board, positionFromAlgebric("d7"), PieceColor.white) == false
    check isAttacked(board, positionFromAlgebric("d3"), PieceColor.white) == false
    check isAttacked(board, positionFromAlgebric("a5"), PieceColor.white) == false
    check isAttacked(board, positionFromAlgebric("f5"), PieceColor.white) == false

  test "king attacks // no wrap-around at board edge":
    var board = board.fromFenPiecePlacement("7K/8/8/8/8/8/8/8")
    check isAttacked(board, positionFromAlgebric("a8"), PieceColor.white) == false
    check isAttacked(board, positionFromAlgebric("a7"), PieceColor.white) == false

  test "empty square // can check if empty squares are attacked":
    var board = board.fromFenPiecePlacement("8/8/8/3R4/8/8/8/8")
    # Empty square d3 should be attacked by rook on d5
    check isAttacked(board, positionFromAlgebric("d3"), PieceColor.white) == true

  test "multiple attackers // square attacked by multiple pieces":
    var board = board.fromFenPiecePlacement("8/8/8/2B5/3n4/8/3R4/8")
    let targetPos = positionFromAlgebric("d4")
    # Attacked by both white bishop (c5) and white rook (d2)
    check isAttacked(board, targetPos, PieceColor.white) == true

  test "no attackers // square not under attack":
    var board = board.fromFenPiecePlacement("8/8/8/3R4/8/8/8/8")
    check isAttacked(board, positionFromAlgebric("e3"), PieceColor.white) == false

  test "opposite color // black pieces attacking":
    var board = board.fromFenPiecePlacement("8/8/8/3r4/8/8/8/8")
    check isAttacked(board, positionFromAlgebric("d1"), PieceColor.black) == true
    check isAttacked(board, positionFromAlgebric("a5"), PieceColor.black) == true

  test "complex position // realistic scenario":
    var board = board.fromFenPiecePlacement("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
    # e3 is attacked by white king and white bishop
    check isAttacked(board, positionFromAlgebric("e2"), PieceColor.white) == true
    # e6 is attacked by black king and black bishop
    check isAttacked(board, positionFromAlgebric("e7"), PieceColor.black) == true

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
