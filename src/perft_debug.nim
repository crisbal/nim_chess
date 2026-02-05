import os
import strutils

import nim_chesspkg/board
import nim_chesspkg/piece
import nim_chesspkg/game
import nim_chesspkg/move
import nim_chesspkg/utils

when isMainModule:
  let args = commandLineParams()

  if args.len < 2:
    echo "Usage: perft_debug <depth> <fen> [divide]"
    echo "  depth: search depth"
    echo "  fen: position in FEN notation"
    echo "  divide: optional flag to use divide/dperft mode"
    quit(1)

  let depth: uint = uint(parseInt(args[0]))
  let fen: string = args[1]
  let useDivide: bool = args.len >= 3 and args[2] == "divide"

  var g = game.fromFen(fen)
  var b = g.board

  if useDivide:
    discard utils.divide(g, depth)
  else:
    echo utils.perft(g, depth)
