import os
import strutils

import nim_chesspkg/board
import nim_chesspkg/piece
import nim_chesspkg/game
import nim_chesspkg/utils

when isMainModule:
  # var b = board.empty()
  # b[0] = piece.piece(PieceType.knight, PieceColor.black)
  # b[1] = piece.piece(PieceType.knight, PieceColor.white)
  # b[2] = piece.piece(PieceType.knight, PieceColor.black)
  # b[3] = piece.piece(PieceType.knight, PieceColor.white)
  # echo $b
  let args =  commandLineParams()
  let depth: uint = uint(parseInt(args[0]))
  let fen: string = args[1]
  var g = game.fromFen(fen)
  var b = g.board

  var turn = g.turn
  if len(args) > 2:
    for move in args[2].split(" "):
      b = playMove(b, moveFromString(move))
      turn = !turn
  # echo $g.board
  #[ let moves = generatePseudolegalMoves(g.board, g.turn)
  echo $moves
  for move in moves:
    echo $move ]#
  #[ var validMoves = generatePseudolegalMoves(g.board, PieceColor.white)
  echo $validMoves
  for move in validMoves:
    echo $move ]#

  #[ var validMoves = generateMoves(g.board, PieceColor.white)
  echo $validMoves
  for move in validMoves:
    echo $move

  echo "" 
  echo g.board.search(PieceColor.white, 3) ]#
  #echo g.board.search(PieceColor.black, 1) 
  discard b.dperft(depth, turn)
