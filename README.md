# nim_chess

A chess library for Nim.

![CI Status](https://github.com/crisbal/nim_chess/actions/workflows/main.yml/badge.svg)

## What's implemented right now

* Board representation
* FEN Board loading
* Legal move generation
    * No castling
    * No en-passant
    * No promotion
* Iterative search
    * Unoptimized negamax
    * Alpha-beta negamax
        * Rudimentary move ordering
* `perft` e `dperft`
* Very primitive UCI interface

Note: performance is very bad now