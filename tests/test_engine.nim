import unittest
import strutils
import os
import ../src/nim_chesspkg/game
import ../src/nim_chesspkg/move
import ../src/nim_chesspkg/board

suite "Engine Mate in One":
  test "mate in one positions":
    let csvPath = "tests/assets/mate-in-one-fens.csv"
    check fileExists(csvPath)

    let content = readFile(csvPath)
    let lines = content.splitLines()

    for line in lines[0..<500]:
      if line.strip() == "": continue
      let parts = line.split(',')
      if parts.len < 2: continue

      let fen = parts[0]
      let expectedMove = parts[1].strip()

      checkpoint("FEN: " & fen)
      var game = fromFen(fen)
      let result = searchAB(game, 2) # Using depth 2 to be safe

      let actualMove = $(result.bestMove)

      checkpoint("Expected: " & expectedMove & ", Got: " & actualMove)

      # We compare the move strings.
      # Note: CSV uses lowercase for promotion, our $ also uses lowercase now.
      check actualMove == expectedMove
