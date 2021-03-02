# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import nim_chesspkg/board
import nim_chesspkg/game
import nim_chesspkg/piece

when isMainModule:
  # var b = board.empty()
  # b[0] = piece.piece(PieceType.knight, PieceColor.black)
  # b[1] = piece.piece(PieceType.knight, PieceColor.white)
  # b[2] = piece.piece(PieceType.knight, PieceColor.black)
  # b[3] = piece.piece(PieceType.knight, PieceColor.white)
  # echo $b

  var g = game.fromFen("k7/1P6/8/8/8/8/8/7K w - - 0 1")
  echo $g.board
  #[ let moves = generatePseudolegalMoves(g.board, g.turn)
  echo $moves
  for move in moves:
    echo $move ]#

  let validMoves = generateMoves(g.board, PieceColor.black)
  echo $validMoves
  for move in validMoves:
    echo $move

  echo g.board.evaluate()