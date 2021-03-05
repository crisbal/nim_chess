import strutils

import piece
import board

type
    Game* = object
        board*: Board
        turn*: PieceColor
        halfmove_clock*: int
        fullmove_number*: int

proc fromFen *(fen: string): Game =
    var parts = fen.split(" ")
    if len(parts) != 6:
        raise newException(ValueError, "Invalid FEM")

    # piece placement
    var game_board = board.fromFenPiecePlacement(parts[0])

    # active color
    var turn = if parts[1] == "w": PieceColor.white else: PieceColor.black

    # TODO: castling
    # TODO: enpassant

    var halfmove_clock = parseInt(parts[4])
    var fullmove_number = parseInt(parts[5])

    return Game(board: game_board, turn: turn, halfmove_clock: halfmove_clock, fullmove_number: fullmove_number)

proc newGame *(): Game =
    return fromFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")

proc playMove *(game: var Game, move: Move) =
    game.board = playMove(game.board, move)
    game.turn = !game.turn

proc search *(game: Game, depth: uint8 = 4): Move =
    return game.board.search(game.turn, depth)