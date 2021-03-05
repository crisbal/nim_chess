import os
import strutils

import nim_chesspkg/board
import nim_chesspkg/piece
import nim_chesspkg/game
import nim_chesspkg/utils

when isMainModule:
  var g = game.fromFen("rnq1kbnr/pbpppppp/1p6/1PP5/3P4/8/4PPPP/RNBQKBNR w KQk - 1 12")
  echo $g.board.evaluate()
  echo $g.search(3)
