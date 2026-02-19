# nim_chess

A chess engine written in Nim.

![CI Status](https://github.com/crisbal/nim_chess/actions/workflows/main.yml/badge.svg)

## What's implemented right now

* Board representation
* FEN Board loading
* Legal move generation (Castling, En-passant, Promotion)
* Iterative search at fixed depth
    * Alpha-beta negamax
        * Rudimentary move ordering (basic heuristics, no history table or killer moves)
        * Very basic board evaluation (material only)
    * Quiescence search
    * Not yet implemented:
      * cache or transposition tables
      * parallelization
      * pruning techniques (null move, futility, etc.)
      * endgame tablebases
      * opening book
      * advanced evaluation (piece-square tables, mobility, king safety, etc.)
* `perft` e `dperft`
  * With tests for various positions
* Very primitive UCI interface, but able to play against other engines via supported chess GUIs

Note: performance is not great,

## Playing against the engine

You can play against the engine using any chess GUI that supports the UCI protocol (e.g., Arena, Scid vs PC, etc.). To do this:

1. Compile the engine with the UCI flag:
   ```bash
   nim c -d:release --rangeChecks:off --boundChecks:off src/uci.nim
   ```
2. Open your chess GUI and add the compiled engine as a new UCI engine.
3. Start a new game against the engine and enjoy!
