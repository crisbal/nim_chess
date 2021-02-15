# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import nim_chesspkg/board
import nim_chesspkg/piece
import nim_chesspkg/game

when isMainModule:
  # var b = board.empty()
  # b[0] = piece.piece(PieceType.knight, PieceColor.black)
  # b[1] = piece.piece(PieceType.knight, PieceColor.white)
  # b[2] = piece.piece(PieceType.knight, PieceColor.black)
  # b[3] = piece.piece(PieceType.knight, PieceColor.white)
  # echo $b

  var g = game.fromFen("rnbqkbnr/pppppppp/8/8/8/4pP2/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
  echo $g.board
  var moves = g.generate_moves()
  for move in moves:
    echo $move
