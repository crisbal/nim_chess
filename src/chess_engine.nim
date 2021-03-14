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
            continue

        if line.startsWith("position "):
            let parts: seq[string] = line.split(" ")
            var i_moves = parts.find("moves")
            if i_moves < 0:
                i_moves = parts.high + 1

            if not game_started:
                game_started = true
                if parts[1] == "startpos":
                    g = game.fromFen(STARTING_FEN)
                else:
                    let fen_setup = parts[2..(i_moves - 1)]
                    g = game.fromFen(fen_setup.join(" "))

            let moves = parts[i_moves..parts.high]
            if len(moves) > 1:
                assert moves[0] == "moves"
                let moves = moves[1..moves.high]
                log.writeLine($moves)
                let lastMove = moves[moves.high]
                discard g.playMove(moveFromString(lastMove))
                log.writeLine($g.board)

        if line.startsWith("go "):
            var bestMove = g.searchAB(5)
            echo "bestmove " & $bestMove
            discard g.playMove(bestMove)