import os
import strutils

import nim_chesspkg/board
import nim_chesspkg/piece
import nim_chesspkg/game
import nim_chesspkg/utils
import nim_chesspkg/move
when isMainModule:
  let params = commandLineParams()
  var fen = STARTING_FEN
  if len(params) > 0:
    fen = params[0]
  
  var g = game.fromFen(fen)

  if len(params) > 1:
    for moveString in params[1..params.high]:
      let move = moveFromString(moveString)
      echo "Playing " & $move
      discard g.playMove(move)

  echo $g.board
  echo ""
  echo "Evaluation: " & $g.board.evaluate
  echo ""
  echo $g.searchAB(5)
