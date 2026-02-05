import os
import strutils

import nim_chesspkg/board
import nim_chesspkg/piece
import nim_chesspkg/game
import nim_chesspkg/move
import nim_chesspkg/utils

when isMainModule:
  let args = commandLineParams()
  let depth: uint = uint(parseInt(args[0]))
  let fen: string = args[1]
  var g = game.fromFen(fen)
  var b = g.board

  echo utils.perft(g, depth)
