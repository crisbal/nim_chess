import unittest

import ../src/nim_chesspkg/game
import ../src/nim_chesspkg/utils

# Perft test positions from https://www.chessprogramming.org/Perft_Results

suite "Perft - Initial Position":
  # rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
  const INITIAL_FEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

  test "depth 1":
    var g = game.fromFen(INITIAL_FEN)
    check perft(g, 1) == 20

  test "depth 2":
    var g = game.fromFen(INITIAL_FEN)
    check perft(g, 2) == 400

  test "depth 3":
    var g = game.fromFen(INITIAL_FEN)
    check perft(g, 3) == 8902

  test "depth 4":
    var g = game.fromFen(INITIAL_FEN)
    check perft(g, 4) == 197281

  test "depth 5":
    var g = game.fromFen(INITIAL_FEN)
    check perft(g, 5) == 4865609

suite "Perft - Position 2 (Kiwipete)":
  # r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -
  const KIWIPETE_FEN = "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1"

  test "depth 1":
    var g = game.fromFen(KIWIPETE_FEN)
    check perft(g, 1) == 48

  test "depth 2":
    var g = game.fromFen(KIWIPETE_FEN)
    check perft(g, 2) == 2039

  test "depth 3":
    var g = game.fromFen(KIWIPETE_FEN)
    check perft(g, 3) == 97862

  test "depth 4":
    var g = game.fromFen(KIWIPETE_FEN)
    check perft(g, 4) == 4085603

  test "depth 5":
    var g = game.fromFen(KIWIPETE_FEN)
    check perft(g, 5) == 193690690

suite "Perft - Position 3":
  # 8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1
  const POSITION3_FEN = "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1"

  test "depth 1":
    var g = game.fromFen(POSITION3_FEN)
    check perft(g, 1) == 14

  test "depth 2":
    var g = game.fromFen(POSITION3_FEN)
    check perft(g, 2) == 191

  test "depth 3":
    var g = game.fromFen(POSITION3_FEN)
    check perft(g, 3) == 2812

  test "depth 4":
    var g = game.fromFen(POSITION3_FEN)
    check perft(g, 4) == 43238

  test "depth 5":
    var g = game.fromFen(POSITION3_FEN)
    check perft(g, 5) == 674624

suite "Perft - Position 4":
  # r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1
  const POSITION4_FEN = "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1"

  test "depth 1":
    var g = game.fromFen(POSITION4_FEN)
    check perft(g, 1) == 6

  test "depth 2":
    var g = game.fromFen(POSITION4_FEN)
    check perft(g, 2) == 264

  test "depth 3":
    var g = game.fromFen(POSITION4_FEN)
    check perft(g, 3) == 9467

  test "depth 4":
    var g = game.fromFen(POSITION4_FEN)
    check perft(g, 4) == 422333

  test "depth 5":
    var g = game.fromFen(POSITION4_FEN)
    check perft(g, 5) == 15833292

suite "Perft - Position 4 Mirrored":
  # r2q1rk1/pP1p2pp/Q4n2/bbp1p3/Np6/1B3NBn/pPPP1PPP/R3K2R b KQ - 0 1
  const POSITION4_MIRRORED_FEN = "r2q1rk1/pP1p2pp/Q4n2/bbp1p3/Np6/1B3NBn/pPPP1PPP/R3K2R b KQ - 0 1"

  test "depth 1":
    var g = game.fromFen(POSITION4_MIRRORED_FEN)
    check perft(g, 1) == 6

  test "depth 2":
    var g = game.fromFen(POSITION4_MIRRORED_FEN)
    check perft(g, 2) == 264

  test "depth 3":
    var g = game.fromFen(POSITION4_MIRRORED_FEN)
    check perft(g, 3) == 9467

  test "depth 4":
    var g = game.fromFen(POSITION4_MIRRORED_FEN)
    check perft(g, 4) == 422333

  test "depth 5":
    var g = game.fromFen(POSITION4_MIRRORED_FEN)
    check perft(g, 5) == 15833292

suite "Perft - Position 5":
  # rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8
  const POSITION5_FEN = "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8"

  test "depth 1":
    var g = game.fromFen(POSITION5_FEN)
    check perft(g, 1) == 44

  test "depth 2":
    var g = game.fromFen(POSITION5_FEN)
    check perft(g, 2) == 1486

  test "depth 3":
    var g = game.fromFen(POSITION5_FEN)
    check perft(g, 3) == 62379

  test "depth 4":
    var g = game.fromFen(POSITION5_FEN)
    check perft(g, 4) == 2103487

  test "depth 5":
    var g = game.fromFen(POSITION5_FEN)
    check perft(g, 5) == 89941194

suite "Perft - Position 6":
  # r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10
  const POSITION6_FEN = "r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10"

  test "depth 1":
    var g = game.fromFen(POSITION6_FEN)
    check perft(g, 1) == 46

  test "depth 2":
    var g = game.fromFen(POSITION6_FEN)
    check perft(g, 2) == 2079

  test "depth 3":
    var g = game.fromFen(POSITION6_FEN)
    check perft(g, 3) == 89890

  test "depth 4":
    var g = game.fromFen(POSITION6_FEN)
    check perft(g, 4) == 3894594

  test "depth 5":
    var g = game.fromFen(POSITION6_FEN)
    check perft(g, 5) == 164075551
