import os
import strutils

import nim_chesspkg/board
import nim_chesspkg/piece
import nim_chesspkg/game
import nim_chesspkg/utils

when isMainModule:
  var g = game.fromFen("4r1rk/5K1b/7R/R7/8/8/8/8 w - - 0 1")
  echo $g.board
  echo ""
  echo "Evaluation: " & $g.board.evaluate
  echo ""
  #echo $g.search(4)
  echo ""
  echo $g.searchAB(5)
