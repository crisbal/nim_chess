# simple interface with an UCI
import strutils

import nim_chesspkg/board
import nim_chesspkg/piece
import nim_chesspkg/game
import nim_chesspkg/utils

var log = open("/tmp/uci.log", fmAppend)

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
            g = newGame()

        if line.startsWith("position "):
            let parts: seq[string] = line.split(" ")
            assert parts[1] == "startpos"
            if len(parts) > 2:
                assert parts[2] == "moves"
                let moves = parts[3..parts.high]
                let lastMove = moves[moves.high]
                g.playMove(moveFromString(lastMove))

        if line.startsWith("go "):
            var bestMove = g.search(3)
            echo "bestmove " & $bestMove
            g.playMove(bestMove)