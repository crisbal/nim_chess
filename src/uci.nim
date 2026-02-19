# simple interface with an UCI
import strutils
import system

import nim_chesspkg/board
import nim_chesspkg/piece
import nim_chesspkg/game
import nim_chesspkg/move
import nim_chesspkg/utils

var log = open("/tmp/uci.log", fmAppend)
# system.stderr = log

var game_started = false
var g: Game
when isMainModule:
  var line = ""
  while stdin.readLine(line):
    log.writeLine(line)
    log.flushFile()
    if line == "uci":
      echo "id name nim_chess"
      echo "id author crisbal"
      echo "uciok"

    if line == "isready":
      echo "readyok"

    if line == "quit" or line == "stop":
      break

    if line == "ucinewgame":
      game_started = false  # Reset for new game
      continue

    if line.startsWith("position "):
      let parts: seq[string] = line.split(" ")
      var i_moves = parts.find("moves")
      if i_moves < 0:
        i_moves = parts.high + 1

      # Always parse position
      if parts[1] == "startpos":
        g = game.fromFen(STARTING_FEN)
      else:
        let fen_setup = parts[2 .. (i_moves - 1)]
        g = game.fromFen(fen_setup.join(" "))

      game_started = true

      # Apply ALL moves in sequence
      if i_moves <= parts.high:
        let moves = parts[i_moves + 1 .. parts.high]
        log.writeLine("Applying moves: " & $moves)
        for moveStr in moves:
          let move = moveFromLongAlgebric(moveStr)
          discard playMove(g, move)
        log.writeLine("Final board:")
        log.writeLine($g.board)

    if line.startsWith("go "):
      const DEPTH = 6
      let result = g.searchAB(6)

      # Output UCI info line
      echo "info depth ", DEPTH, " score cp ", result.score, " nodes ", result.nodes

      # Output best move
      echo "bestmove ", result.bestMove

      # Apply move to internal board
      discard playMove(g, result.bestMove)

      log.writeLine("Best move: " & $result.bestMove & " (score: " & $result.score & ")")
