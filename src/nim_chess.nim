# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import nim_chesspkg/board
import nim_chesspkg/game

when isMainModule:
  # var b = board.empty()
  # b[0] = piece.piece(PieceType.knight, PieceColor.black)
  # b[1] = piece.piece(PieceType.knight, PieceColor.white)
  # b[2] = piece.piece(PieceType.knight, PieceColor.black)
  # b[3] = piece.piece(PieceType.knight, PieceColor.white)
  # echo $b

  var g = game.fromFen("8/8/1q3q2/8/3B4/8/5K2/8 w - - 0 1")
  echo $g.board
  #[ let moves = generatePseudolegalMoves(g.board, g.turn)
  echo $moves
  for move in moves:
    echo $move ]#
  
  let validMoves = generateMoves(g.board, g.turn)
  echo $validMoves
  for move in validMoves:
    echo $move
